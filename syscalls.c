#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
#include <errno.h>

// Simule un tas mémoire minimal
extern char __end__;  // Défini par le linker script
static char *heap_end;

void _exit(int status) {
    while (1); // boucle infinie ou reset
}


caddr_t _sbrk(int incr) {
    if (heap_end == 0) {
        heap_end = &__end__;
    }
    char *prev_heap_end = heap_end;
    heap_end += incr;
    return (caddr_t)prev_heap_end;
}

__attribute__((weak))
int _read(int file, char *ptr, int len) {
    errno = ENOSYS;
    return -1;
}

int _close(int file) {
    return -1;
}

int _fstat(int file, struct stat *st) {
    st->st_mode = S_IFCHR;
    return 0;
}

int _isatty(int file) {
    return 1;
}

int _lseek(int file, int ptr, int dir) {
    return 0;
}

int _kill(int pid, int sig) {
    errno = EINVAL;
    return -1;
}

int _getpid(void) {
    return 1;
}
