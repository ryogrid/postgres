#!/bin/sh

PATH=../preproc/:$PATH
ecpg -C INFORMIX -o preproc/notice_informix.c preproc/notice_informix.c

# always return 0 for testing purposes
exit 0