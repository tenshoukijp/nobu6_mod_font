rem �K�v�ȃt�@�C���ƃt�H���_�\��
rem 
rem (��Ɨp�t�H���_)\
rem  �� (���̃o�b�`�t�@�C��)
rem  �� breakttc.exe (ttc��ttf�ɕ����E�ϊ�����c�[��)
rem  �� JPNHN16X.98 (�����p�^�[��ROM����擾����PC-98���p�t�H���g fontx2�`��)
rem  �� JPNZN16X.98 (�����p�^�[��ROM����擾����PC-98�S�p�t�H���g fontx2�`��)
rem  �� f2b\
rem  ��  �� fontx2bdf.exe (fontx2�`����bdf�`���ɕϊ�����c�[��)
rem  �� ttftools\ (TrueType�t�H���g�𑀍삷��c�[���Q)
rem  �@  �� sbitExtract.exe TrueType�t�H���g�̃r�b�g�}�b�v��bdf�`���Ŏ��o��
rem  �@  �� sbitRW.exe TrueType�t�H���g�̃r�b�g�}�b�v��bdf�t�H���g���㏑������
rem  �@  �� ttfname.exe TrueType�t�H���g�̏��(�^�C�g���A�o�[�W�����A�����Ȃ�)��ύX����
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
rem �K�v�ł���΂��̎��_��MS_Gothic_z-16-JISX0208.1983-0.bdf�̌����������폜 ����ւ����s���B
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
@echo ttfname.exe���N�����܂��B
@echo �t�H���g���𑼂̃t�H���g�Əd�����Ȃ��悤�A���j�[�N�Ȗ��O�ɏC�����Ă��������B
ttftools\ttfname.exe nec98font.ttf
rem ---End Main---
goto eof
:error
@echo �K�v�ȃt�@�C�����s�����Ă��܂��B
@pause
:eof