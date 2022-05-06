#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use POSIX qw( ceil );
use File::Spec::Functions qw( :ALL );

my %OPTION;
GetOptions(
    'help|h|?'   => \$OPTION{help},
    'verbose|v'  => \$OPTION{verbose},
    'quiet|q'    => \$OPTION{quiet},
    'template|t' => \$OPTION{template},
    'index|i'    => \$OPTION{index},
) or die 'Bad options';

if (! $OPTION{template}) {
    if (@ARGV) {
        my (undef, undef, $filename) = splitpath($ARGV[0]);
        $filename =~ s{ [.] .*? \z }{}xmso;
        $OPTION{template} = "${filename}_%02d.ttf";
    }
    else {
        $OPTION{template} = 'font_%02d.ttf';
    }
}

my $handle;
if (@ARGV) {
    open $handle, '<', $ARGV[0]
        or die $!;
    binmode $handle;
}
else {
    $handle = \*STDIN;
}
binmode $handle;

my $ttc_header = read_ttc_header($handle);
my $numFonts = $ttc_header->{numFonts};

my $src_headers = [];
for my $i (0 .. $numFonts - 1) {
    my $offset = tell $handle;
    my $table_offset = $ttc_header->{OffsetTable}->[$i];

#   seek $handle, $table_offset - $offset, 1  or  die $!;
    skip_handle($handle, $table_offset - $offset);

    $src_headers->[$i] = read_header($handle);
}

my $tables = merge_tables($src_headers);

my $dst_headers = [];
for my $i (0 .. $numFonts - 1) {
    $dst_headers->[$i] = trans_header($src_headers->[$i]);
}

my $dst_handles = [];
for my $i (0 .. $numFonts - 1) {
    my $filename = sprintf $OPTION{template}, $i + 1;

    open my $h, '>', $filename
        or die "open: $!";
    binmode $h;

    $dst_handles->[$i] = $h;

    write_header($dst_handles->[$i], $dst_headers->[$i]);
}

copy_bodies_for_fonts($dst_handles, $handle, $tables);

for my $i (0 .. $numFonts - 1) {
    close $dst_handles->[$i];
}

close $handle;

exit;

sub read_ttc_header {
    my ($src)  = @_;
    my $header = {};
    my $buf;

    read $src, $buf, 4
        or die "read: $!";
    $header->{TTCTag} = $buf;

    die "not TTC file"
        unless $header->{TTCTag} eq 'ttcf';

    read $src, $buf, 4
        or die "read: $!";
    ($header->{versionLow},
     $header->{versionHigh})
        = unpack 'nn', $buf;
    $header->{Version} = $header->{versionLow} . '.' . $header->{versionHigh};

    die "unknown version: " . $header->{Version}
        if $header->{Version} != 1.0
        && $header->{Version} != 2.0;

    print {*STDERR} "TTC Version: ", $header->{Version}, "\n"
        if $OPTION{verbose};

    read $src, $buf, 4
        or die "read: $!";
    $header->{numFonts} = unpack 'N', $buf;

    print {*STDERR} "TTC numFonts: ", $header->{numFonts}, "\n"
        if $OPTION{verbose};

    for my $i (0 .. $header->{numFonts} - 1) {
        read $src, $buf, 4
            or die "read: $!";
        $header->{OffsetTable}->[$i] = unpack 'N', $buf;
    }

    $header->{OffsetTable} = [ sort @{ $header->{OffsetTable} } ];

    if ($header->{Version} >= 2.0) {
        read $src, $buf, 4+4+4
            or die "read: $!";
    }

    return $header;
}

sub read_header {
    my ($src)  = @_;
    my $header = {};
    my $buf;

    read $src, $buf, 4  or  die $!;
    $header->{version} = $buf;

    read $src, $buf, 2+2+2+2  or  die $!;
    ($header->{numTables},
     $header->{searchRange},
     $header->{entrySelector},
     $header->{rangeShift})
        = unpack 'nnnn', $buf;

    my $numTables = $header->{numTables};

    $header->{table} = {};
    $header->{tags}  = [];

    while ($numTables -- > 0) {
        read $src, $buf, 4+4+4+4  or  die $!;
        my $tag = substr $buf, 0, 4, '';
        my ($checkSum, $offset, $length)
            = unpack 'NNN', $buf;

        $header->{table}->{$tag}
            = {
                tag      => $tag,
                checkSum => $checkSum,
                offset   => $offset,
                length   => $length,
            };

        push @{ $header->{tags} }, $tag;
    }

    return $header;
}

sub trans_header {
    my $header = clone_header($_[0]);

    $header->{entrySelector}
        = ceil(log $header->{numTables} / log 2);

    $header->{searchRange}
        = (1 << $header->{entrySelector}) * 16;

    $header->{rangeShift}
        = $header->{numTables} * 16
          - $header->{searchRange};

    $header->{tags}
        = [
            sort {
                $header->{table}->{$a}->{offset}
                    <=>
                $header->{table}->{$b}->{offset}
            }
            @{ $header->{tags} }
          ];

    my $length
        = 4+2+2+2+2 + (4+4+4+4) * $header->{numTables};
    $header->{length} = ceil($length / 4) * 4;
    $header->{trail}  = $header->{length} - $length;

    my $offset = $header->{length};
    foreach my $tag (@{ $header->{tags} }) {
        my $table = $header->{table}->{$tag};

        $table->{offset} = $offset;

        $offset += $table->{length};
        $offset += 3 - ($offset + 3) % 4;
    }

    return $header;
}

sub clone_header {
    my ($src) = @_;
#   use Storable qw( dclone );
#   return dclone($_[0]);

    my $dst = { %$src };

    $dst->{tags} = [ @{ $src->{tags} } ];

    $dst->{table} = {};
    while (my ($tag, $table) = each %{ $src->{table} }) {
        $dst->{table}->{$tag} = { %$table };
    }

    return $dst;
}

sub write_header {
    my ($dst, $header) = @_;

    print {$dst} $header->{version};

    print {$dst}
        pack 'nnnn', $header->{numTables},
                     $header->{searchRange},
                     $header->{entrySelector},
                     $header->{rangeShift};

    foreach my $tag (@{ $header->{tags} }) {
        my $table = $header->{table}->{$tag};

        print {$dst} $tag;
        print {$dst}
            pack 'NNN', $table->{checkSum},
                        $table->{offset},
                        $table->{length};
    }

    print {$dst} "\x00" x $header->{trail};
}

sub merge_tables {
    my ($headers) = @_;

    my $table_by_ofs = {};
    my $i = 0;
    foreach my $header (@$headers) {
        foreach my $tag (@{ $header->{tags} }) {
            my $table = $header->{table}->{$tag};
            $table_by_ofs->{$table->{offset}}->{table} = $table;
            push @{ $table_by_ofs->{$table->{offset}}->{id} }, $i;
        }
        $i ++;
    }

    my @tables = map  {
                    {
                        %{ $table_by_ofs->{$_}->{table} },
                        id => $table_by_ofs->{$_}->{id},
                    } 
                 }
                 sort { $a <=> $b }
                 keys %$table_by_ofs;

    return \@tables;
}

sub copy_bodies_for_fonts {
    my ($dst_handles, $src_handle, $tables) = @_;

    my $offset = tell $src_handle;

    foreach my $table (@$tables) {
#       seek $src_handle, $table->{offset} - $offset, 1  or  die $!;
        skip_handle($src_handle, $table->{offset} - $offset);
        $offset = $table->{offset};

        my $data = read_handle($src_handle, $table->{length});
        $offset += $table->{length};

        my $trail = 3 - ($table->{length} + 3) % 4;
        $trail = "\x00" x $trail;

        foreach my $i (@{ $table->{id} }) {
            my $dst_handle = $dst_handles->[$i];

            print {$dst_handle} $data, $trail;
        }
    }
}

sub skip_handle {
    my ($src, $length) = @_;
    my $buf;
    my $unit = 4096;

    die "cannot seek backward: $length"
        if $length < 0;

    while ($length > 0) {
        $unit = $length if $length < $unit;

        read $src, $buf, $unit  or  die $!;

        $length -= $unit;
    }
}

sub read_handle {
    my ($src, $length) = @_;
    my $data;
    my $buf;
    my $unit = 4096;

    while ($length > 0) {
        $unit = $length if $length < $unit;

        read $src, $buf, $unit  or  die $!;
        $data .= $buf;

        $length -= $unit;
    }

    return $data;
}
