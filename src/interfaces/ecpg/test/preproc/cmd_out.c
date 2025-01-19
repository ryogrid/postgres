/*-------------------------------------------------------------------------
 *
 * cmd_out          --- assistance program for ecpg syntax error detecting
 *                      with pg_regress
 * 
 * This code is released under the terms of the PostgreSQL License.
 *
 * Portions Copyright (c) 1996-2025, PostgreSQL Global Development Group
 * Portions Copyright (c) 1994, Regents of the University of California
 *
 * src/interfaces/ecpg/test/cmd_out.c
 *
 *-------------------------------------------------------------------------
 */

#include <stdlib.h>
#include "cmd_out_util.h"

// binary path is "../preproc/ecpg"

#define PGC_FILE_NAME "preproc/notice.pgc"

int main(void) {
	return exec_ecpg(PGC_FILE_NAME, (char *)NULL);
}