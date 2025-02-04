#!/bin/sh

PATH=../preproc/:$PATH
ecpg -o preproc/notice.c preproc/notice.pgc

# always return 0 for testing purposes
exit 0