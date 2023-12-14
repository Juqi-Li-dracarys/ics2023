#include "syscall.h"

void do_syscall(Context *c) {
  uintptr_t a[4];
  a[0] = c->GPR1;
  // 系统调用号
  switch (a[0]) {
    case SYS_yield: a[3] = sys_yield(); break;
    default: panic("Unhandled syscall ID = %d", a[0]);
  }

}


