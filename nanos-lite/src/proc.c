#include <proc.h>

#define MAX_NR_PROC 4

// 其他进程
static PCB pcb[MAX_NR_PROC] __attribute__((used)) = {};
// 初始进程
static PCB pcb_boot = {};

// 当前进程指针
PCB *current = NULL;

void naive_uload(PCB *pcb, const char *filename);

void switch_boot_pcb() {
  current = &pcb_boot;
}


void context_kload(PCB *pcb, void (*entry)(void *), void *arg) {
  pcb->cp = kcontext((Area) {(void *)(pcb->stack), (void *)(pcb + 1)}, entry, arg);
  return;
}

void hello_fun(void *arg) {
  int j = 1;
  while (1) {
    for (int volatile i = 0; i < 100000; i++) ;
    Log("Hello World from Nanos-lite with arg '%p' for the %dth time!", (uintptr_t)arg, j);
    j ++;
    yield();
  }
}

void init_proc() {
  switch_boot_pcb();
  Log("Initializing processes...");
  context_kload(&pcb[0], hello_fun, (void *)1L);
  context_kload(&pcb[1], hello_fun, (void *)1L);
  naive_uload(&pcb[0], NULL);
  // naive_uload(NULL, "/bin/menu");
}

Context* schedule(Context *prev) {
  // 保存当前上下文的栈顶指针
  current->cp = prev;
  // 切换到另外一个进程
  current = (current == &pcb[0] ? &pcb[1] : &pcb[0]);
  // 返回另一个进程的栈顶指针
  return current->cp;
}
