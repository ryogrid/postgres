@echo off

set PATH=%PATH%;..\preproc
ecpg %*

REM always return 0 for test purposes
exit /b 0