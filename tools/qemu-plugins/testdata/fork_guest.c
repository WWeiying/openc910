#include <stdint.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

static volatile uint64_t sink;

__attribute__((noinline)) static void parent_work(void)
{
    for (uint64_t i = 0; i < 200000; ++i) {
        sink += (i * 17) ^ (sink >> 3);
    }
}

__attribute__((noinline)) static void child_work(void)
{
    for (uint64_t i = 0; i < 200000; ++i) {
        sink ^= (i * 29) + (sink << 1);
    }
}

int main(void)
{
    pid_t pid = fork();
    int status = 0;

    if (pid < 0) {
        return 2;
    }
    if (pid == 0) {
        child_work();
        _exit(0);
    }

    parent_work();
    if (waitpid(pid, &status, 0) != pid || !WIFEXITED(status)
        || WEXITSTATUS(status) != 0) {
        return 3;
    }
    puts("fork-ok");
    return 0;
}
