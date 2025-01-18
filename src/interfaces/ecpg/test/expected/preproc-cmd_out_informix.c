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

#define BINARY_PATH "../preproc/ecpg"
//#define BINARY_PATH "/usr/bin/pwd"
#define EXEC_MODE_OPTION1 "-C"
#define EXEC_MODE_OPTION2 "INFORMIX"
#define PGC_FILE_NAME "preproc/notice_informix.pgc"

int main(void) {
    pid_t pid;
    int status;
    int pipe_stdout[2], pipe_stderr[2];

    // Create pipes for stdout and stderr
    if (pipe(pipe_stdout) == -1 || pipe(pipe_stderr) == -1) {
        perror("pipe");
        exit(2);
    }

    // Fork to create a child process
    pid = fork();

    if (pid < 0) {
        // Fork failed
        fprintf(stderr, "Failed to fork process.\n");
        exit(2);
    } else if (pid == 0) {
        // In the child process

        // Redirect stdout and stderr to the pipes
        dup2(pipe_stdout[1], STDOUT_FILENO);
        dup2(pipe_stderr[1], STDERR_FILENO);

        // Close unused pipe ends
        close(pipe_stdout[0]);
        close(pipe_stdout[1]);
        close(pipe_stderr[0]);
        close(pipe_stderr[1]);

        // Execute the binary with the hardcoded argument
        execl(BINARY_PATH, BINARY_PATH, EXEC_MODE_OPTION1, EXEC_MODE_OPTION2, PGC_FILE_NAME, (char *)NULL);
		//execl(BINARY_PATH, BINARY_PATH, (char *)NULL);

        // This code is only executed if execl fails
        fprintf(stderr, "Failed to execute binary: %s\n", BINARY_PATH);
        exit(2);
    } else {
        // In the parent process

        // Close unused pipe ends
        close(pipe_stdout[1]);
        close(pipe_stderr[1]);

        // Wait for the child process to finish
        if (waitpid(pid, &status, 0) == -1) {
            perror("waitpid");
            exit(2);
        }

        // Output the child process's stdout and stderr if it exited normally
        if (WIFEXITED(status)) {
            int exit_code = WEXITSTATUS(status);
            printf("Child process exited with code %d\n", exit_code);

            // Read and output stdout from the child process
            char buffer[1024];
            ssize_t bytes_read;

            while ((bytes_read = read(pipe_stdout[0], buffer, sizeof(buffer) - 1)) > 0) {
                buffer[bytes_read] = '\0';
                printf("%s", buffer);
            }

            // Read and output stderr from the child process
            while ((bytes_read = read(pipe_stderr[0], buffer, sizeof(buffer) - 1)) > 0) {
                buffer[bytes_read] = '\0';
                fprintf(stderr, "%s", buffer);
            }

            // Close the remaining pipe ends
            close(pipe_stdout[0]);
            close(pipe_stderr[0]);

            return 0;
        } else if (WIFSIGNALED(status)) {
            fprintf(stderr, "Child process was terminated by signal %d\n", WTERMSIG(status));
        } else {
            fprintf(stderr, "Child process terminated abnormally.\n");
        }

        // Close the remaining pipe ends in case of errors
        close(pipe_stdout[0]);
        close(pipe_stderr[0]);

        // Exit code in case of errors
        return 2;
    }
}
