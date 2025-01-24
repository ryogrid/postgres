#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>
#include <fcntl.h>

/* 
   Function to take variable-length arguments and execute the appropriate function based on
   the number of arguments
*/
int exec_ecpg(const char *first, ...) {
    va_list args;
    /* To store arguments, including the NULL sentinel */
    const char *args_array[5] = {0}; 
    pid_t pid;
    int status;
    int pipe_stdout[2], pipe_stderr[2];
    int arg_num;

    /* Initialize the variable argument list */
    va_start(args, first);

    /* Add the first argument */
    args_array[0] = first;

    /* Collect up to 3 more arguments */
    int i;
    for (i = 1; i < 5; i++) {
        args_array[i] = va_arg(args, const char *);
        if (args_array[i] == NULL) {
            break;
        }
    }
    arg_num = i+1;

    /* Clean up the variable argument list */
    va_end(args);

    /* Create pipes for stdout and stderr */
    if (pipe(pipe_stdout) == -1 || pipe(pipe_stderr) == -1) {
        perror("pipe");
        exit(2);
    }

    /* Fork to create a child process */
    pid = fork();

    if (pid < 0) {
        /* Fork failed */
        fprintf(stderr, "Failed to fork process.\n");
        exit(2);
    } else if (pid == 0) {
        /* In the child process */

        /* Redirect stdout and stderr to the pipes */
        dup2(pipe_stdout[1], STDOUT_FILENO);
        dup2(pipe_stderr[1], STDERR_FILENO);

        /* Close unused pipe ends */
        close(pipe_stdout[0]);
        close(pipe_stdout[1]);
        close(pipe_stderr[0]);
        close(pipe_stderr[1]);

        /* Determine action based on the number of arguments */
        if (arg_num == 2) { /* Two arguments including NULL */
            /* Execute the binary with the hardcoded argument */
            execl(BINARY_PATH, BINARY_PATH, args_array[0], (char *)NULL);        
        } else if (arg_num == 4) { /* three arguments including NULL */
            execl(BINARY_PATH, BINARY_PATH, args_array[0], args_array[1], args_array[2], (char *)NULL); 
        } else {
            fprintf(stderr, "Error: Invalid number of arguments. Expected 2 or 4 arguments (including NULL).\n");
            exit(2);
        }

        /* This code is only executed if execl fails */
        fprintf(stderr, "Failed to execute binary: %s\n", BINARY_PATH);
        exit(2);
    } else {
        /* In the parent process */

        /* Close unused pipe ends */
        close(pipe_stdout[1]);
        close(pipe_stderr[1]);

        /* Wait for the child process to finish */
        if (waitpid(pid, &status, 0) == -1) {
            perror("waitpid");
            exit(2);
        }

        /* Output the child process's stdout and stderr if it exited normally */
        if (WIFEXITED(status)) {
            int exit_code = WEXITSTATUS(status);
            printf("Child process exited with code %d\n", exit_code);

            /* Read and output stdout from the child process */
            char buffer[1024];
            ssize_t bytes_read;

            while ((bytes_read = read(pipe_stdout[0], buffer, sizeof(buffer) - 1)) > 0) {
                buffer[bytes_read] = '\0';
                printf("%s", buffer);
            }

            /* Read and output stderr from the child process */
            while ((bytes_read = read(pipe_stderr[0], buffer, sizeof(buffer) - 1)) > 0) {
                buffer[bytes_read] = '\0';
                fprintf(stderr, "%s", buffer);
            }

            /* Close the remaining pipe ends */
            close(pipe_stdout[0]);
            close(pipe_stderr[0]);

            return 0;
        } else if (WIFSIGNALED(status)) {
            fprintf(stderr, "Child process was terminated by signal %d\n", WTERMSIG(status));
        } else {
            fprintf(stderr, "Child process terminated abnormally.\n");
        }

        /* Close the remaining pipe ends in case of errors */
        close(pipe_stdout[0]);
        close(pipe_stderr[0]);

        /* Exit code in case of errors */
        return 2;
    }
}

