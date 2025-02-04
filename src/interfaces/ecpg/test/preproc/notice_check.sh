#!/bin/sh

PATH=../preproc/:$PATH
ecpg -o preproc/notice_informix.c preproc/notice_informix.pgc

# always return 0 for testing purposes
exit 0