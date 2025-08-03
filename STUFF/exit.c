void exit(int status) {
    while (1) {
        __asm__("bkpt #0");
    }
}
