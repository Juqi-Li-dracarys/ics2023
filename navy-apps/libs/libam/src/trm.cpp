#include <am.h>

Area heap {
    .start = (void *)0x80000000,
    .end = (void *)0x83000000,
};

void putch(char ch) {
    printf("%c", ch);
    return;
}

void halt(int code) {
    exit(code);
}
