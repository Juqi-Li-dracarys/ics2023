#include <common.h>
#include "syscall.h"

uint32_t SYS_yield() {
  yield();
  return 0;
}

void do_syscall(Context *c) {
  uintptr_t a[4];
  a[0] = c->GPR1;
  switch (a[0]) {
    case 0x01: SYS_yield(); break;
    default: panic("Unhandled syscall ID = %d", a[0]);
  }
}


