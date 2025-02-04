@echo off

PATH=..\preproc\;%PATH%
ecpg -C INFORMIX -o preproc\notice_informix.c preproc\notice_informix.pgc

REM always return 0 for test purposes
exit /b 0