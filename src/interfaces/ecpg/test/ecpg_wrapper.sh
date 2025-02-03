#!/bin/sh

PATH=../preproc/ecpg:$PATH
ecpg "$@"

# always return 0 for testing purposes
exit 0