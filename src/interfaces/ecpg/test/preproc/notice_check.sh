#!/bin/sh

PATH=../preproc/:$PATH
ecpg -c -o preproc/notice.c preproc/notice.pgc

# always return 0 for testing purposes
exit 0