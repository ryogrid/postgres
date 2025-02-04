@echo off

PATH=..\preproc\;%PATH%
ecpg -o preproc\notice.c preproc\notice.pgc

REM always return 0 for test purposes
exit /b 0