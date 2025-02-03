#!/bin/sh

PATH=../preproc/:$PATH
ecpg "$@"

# always return 0 for testing purposes
exit 0