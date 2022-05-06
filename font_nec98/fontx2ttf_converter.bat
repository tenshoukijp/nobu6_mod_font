rem 必要なファイルとフォルダ構成
rem 
rem (作業用フォルダ)\
rem  ├ (このバッチファイル)
rem  ├ breakttc.exe (ttcをttfに分解・変換するツール)
rem  ├ JPNHN16X.98 (文字パターンROMから取得したPC-98半角フォント fontx2形式)
rem  ├ JPNZN16X.98 (文字パターンROMから取得したPC-98全角フォント fontx2形式)
rem  ├ f2b\
rem  │  └ fontx2bdf.exe (fontx2形式をbdf形式に変換するツール)
rem  └ ttftools\ (TrueTypeフォントを操作するツール群)
rem  　  ├ sbitExtract.exe TrueTypeフォントのビットマップをbdf形式で取り出す
rem  　  ├ sbitRW.exe TrueTypeフォントのビットマップにbdfフォントを上書きする
rem  　  └ ttfname.exe TrueTypeフォントの情報(タイトル、バージョン、説明など)を変更する
rem
if not exist breakttc.pl goto error
if not exist JPNHN16X.98 goto error
if not exist JPNZN16X.98 goto error
if not exist f2b\fontx2bdf.exe goto error
if not exist ttftools\sbitExtract.exe goto error
if not exist ttftools\sbitRW.exe goto error
if not exist ttftools\ttfname.exe goto error
rem ---Begin Main---
rem Phase 0
rem Phase 1
copy %windir%\fonts\msgothic.ttc msgothic.ttc
perl breakttc.pl msgothic.ttc
chcp 932
ren msgothic_01.ttf msgothic.ttf
rem Phase 2
copy msgothic.ttf msgothic_h.ttf
copy msgothic.ttf msgothic_z.ttf
ttftools\sbitRW.exe msgothic_h.ttf jpnhn16x.bdf
ttftools\sbitRW.exe msgothic_z.ttf jpnzn16x.bdf
rem Phase 3
ttftools\sbitExtract.exe -o 16 msgothic_h.ttf
ren MS_Gothic-16-JISX0201.1976-0.bdf MS_Gothic_h-16-JISX0201.1976-0.bdf
ttftools\sbitExtract.exe -o 16 msgothic_z.ttf
ren MS_Gothic-16-JISX0208.1983-0.bdf MS_Gothic_z-16-JISX0208.1983-0.bdf
rem 必要であればこの時点でMS_Gothic_z-16-JISX0208.1983-0.bdfの欠損文字を削除 入れ替えを行う。
rem pause
rem Phase 4
ren msgothic.ttf nec98font.ttf
ttftools\sbitRW.exe nec98font.ttf MS_Gothic_h-16-JISX0201.1976-0.bdf
ttftools\sbitRW.exe nec98font.ttf MS_Gothic_z-16-JISX0208.1983-0.bdf
rem Phase 5
del msgothic.ttc
del font*.ttf
del jpnhn16x.bdf
del jpnzn16x.bdf
del MS_Gothic-16-ISO8859-1.bdf
del MS_Gothic-16-JISX0208.1983-0.bdf
del msgothic_h.ttf
del MS_Gothic-16-ISO8859-1.bdf
del MS_Gothic-16-JISX0201.1976-0.bdf
del msgothic_z.ttf
del MS_Gothic_h-16-JISX0201.1976-0.bdf
del MS_Gothic_z-16-JISX0208.1983-0.bdf
@echo ttfname.exeを起動します。
@echo フォント名を他のフォントと重複しないよう、ユニークな名前に修正してください。
ttftools\ttfname.exe nec98font.ttf
rem ---End Main---
goto eof
:error
@echo 必要なファイルが不足しています。
@pause
:eof