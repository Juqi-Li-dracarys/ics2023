#ifndef __PROC_H__
#define __PROC_H__

#include <common.h>
#include <memory.h>

#define STACK_SIZE (8 * PGSIZE)

typedef union {
  // 上下文栈区内容
  uint8_t stack[STACK_SIZE] PG_ALIGN;
  struct {
    // 栈顶指针
    Context *cp;
    AddrSpace as;
    // we do not free memory, so use `max_brk' to determine when to call _map()
    uintptr_t max_brk;
  };
} PCB;

extern PCB *current;

void naive_uload(PCB *pcb, const char *filename);
uintptr_t context_kload(PCB *pcb, void (*entry)(void *), void *arg);
uintptr_t context_uload(PCB *pcb, const char *filename, char *const argv[], char *const envp[]);


#endif
