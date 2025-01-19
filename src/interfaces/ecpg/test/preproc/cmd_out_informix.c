/*-------------------------------------------------------------------------
 *
 * cmd_out_informix --- assistance program for ecpg syntax error detecting
 *                      with pg_regress
 * 
 * This code is released under the terms of the PostgreSQL License.
 *
 * Portions Copyright (c) 1996-2025, PostgreSQL Global Development Group
 * Portions Copyright (c) 1994, Regents of the University of California
 *
 * src/interfaces/ecpg/test/cmd_out_informix.c
 *
 *-------------------------------------------------------------------------
 */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>
#include <fcntl.h>
#include "cmd_out_util.h"

#define BINARY_PATH "../preproc/ecpg"
#define EXEC_MODE_OPTION1 "-C"
#define EXEC_MODE_OPTION2 "INFORMIX"
#define PGC_FILE_NAME "preproc/notice_informix.pgc"

int main(void) {
	exec_ecpg(EXEC_MODE_OPTION1, EXEC_MODE_OPTION2, PGC_FILE_NAME, (char *)NULL);
}
