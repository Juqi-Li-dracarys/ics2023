#include "syscall.h"

#define MAX_NUM 100

static s_node *head = NULL;
static uintptr_t size = 0;

void add_strace(uintptr_t type, uintptr_t arg0, uintptr_t arg1, uintptr_t arg2, uintptr_t ret) {
#ifdef STRACE
  if(size < MAX_NUM) {
    s_node *new = (s_node *)malloc(sizeof(s_node));
    new->type = type;
    new->arg_ret[0] = arg0;
    new->arg_ret[1] = arg1;
    new->arg_ret[2] = arg2;
    new->arg_ret[3] = ret;
    new->next = head;
    head = new;
    size++;
  }
#endif
  return;
}

void disp_strace(void) {
#ifdef STRACE
  s_node *temp = head;
  uintptr_t i = 0;
  printf("STRACE:\n");
  while(temp != NULL) {
    printf("[%d]: type: %d, arg0:%p, arg1:%p, arg2:%p, ret:%p\n", size - i, temp->type, temp->arg_ret[0], temp->arg_ret[1], temp->arg_ret[2], temp->arg_ret[3]);
    i++;
    temp = temp->next;
  }
#endif
  return;
}

// 处理各种系统调用号
void do_syscall(Context *c) {
  switch (c->GPR1) {
    case SYS_yield: c->GPRx = sys_yield(); add_strace(SYS_yield, 0, 0, 0, c->GPRx); break;
    case SYS_exit: disp_strace(); sys_exit(c->GPR2); break;
    case SYS_write: c->GPRx = sys_write(c->GPR2, (char *)(c->GPR3), c->GPR4); add_strace(SYS_write, c->GPR2, c->GPR3, c->GPR4, c->GPRx); break;
    case SYS_brk: c->GPRx = sys_brk((uintptr_t *)(c->GPR2), c->GPR3); add_strace(SYS_brk, c->GPR2, c->GPR3, 0, c->GPRx); break;
    default: panic("Unhandled syscall ID = %d", c->GPR1);
  }
}



