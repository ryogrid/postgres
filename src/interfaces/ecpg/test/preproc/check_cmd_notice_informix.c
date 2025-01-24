#include <stdlib.h>
#include "check_cmd_notice_util.h"

#define EXEC_MODE_OPTION1 "-C"
#define EXEC_MODE_OPTION2 "INFORMIX"

int main(void) {
	/* PGC_FILE_NAME literal is passed at compile time */ 
	return exec_ecpg(EXEC_MODE_OPTION1, EXEC_MODE_OPTION2, PGC_FILE_NAME, (char *)NULL);
}
