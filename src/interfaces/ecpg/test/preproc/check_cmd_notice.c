#include <stdlib.h>
#include "check_cmd_notice_util.h"

int main(void) {
	/* PGC_FILE_NAME literal is passed at compile time */
	return exec_ecpg(PGC_FILE_NAME, (char *)NULL);
}