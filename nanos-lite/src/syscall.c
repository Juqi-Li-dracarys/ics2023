#include "syscall.h"

void do_syscall(Context *c) {
  // 系统调用号
  switch (c->GPR1) {
    case SYS_yield: c->GPRx = sys_yield(); break;
    case SYS_exit: sys_exit(c->GPR2); break;
    case SYS_write: c->GPRx = sys_write(c->GPR2, (char *)(c->GPR3), c->GPR4); break;
    default: panic("Unhandled syscall ID = %d", c->GPR1);
  }
}



