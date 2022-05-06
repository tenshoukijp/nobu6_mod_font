/////////////////////////////////////////////////////
//                 sbitRW, ttfname, sbitExtract
/////////////////////////////////////////////////////

TrueTypeフォントを操作するツール群です。

sbitRW      : 埋め込まれているビットマップを上書きする
ttfname     : TrueTypeフォントの名前などを変更する
sbitExtract : 埋め込まれているビットマップをBDFで取り出す

詳細は HomePageを参照してください。


【sbitRW 使い方】
    コンソールから、
    sbitRW msgothic.ttf 7x14.bdf
    のように
    TrueTypeフォントファイルと BDFフォントファイルを指定します。

    ・BDFは ISO-8859-1, JIX0201.1976, JISX0208.1983に対応しています。
    ・TrueTypeフォントにビットマップがない場合は、何もしません。

【ttfname 使い方】
    TrueTypeフォントを ttfname.exeにドラッグドロップするか、
    コマンドラインから
    ttfname.exe msgothic.ttf
    のように TrueTypeフォントを指定します。
    ダイアログが出るので、名前を変更してOKボタンで上書きします。

【sbitExtract】
    コンソールから、
    sbitExtract -o 12 msgothic.ttf
    と 抜き出すサイズを指定して実行すると、
      MS_Gothic-12-ISO8859-1.bdf
      MS_Gothic-12-JISX0201.1976-0.bdf
      MS_Gothic-12-JISX0208.1983-0.bdf
    のように３つのファイルで出力されます

【動作環境】
    Windows95以降

【他】
    このプログラムはフリーソフトです。
    配布は自由に行って構いません。

    本プログラムを利用して発生した如何なる損害についても、
    一切の責任を負いかねます。

/////////////////////////////////////////////////////
HomePage : http://www003.upp.so-net.ne.jp/kish/
Mail     : k-ishii@wb4.so-net.ne.jp
