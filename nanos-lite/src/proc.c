#include <proc.h>

#define MAX_NR_PROC 4

// 其他进程
static PCB pcb[MAX_NR_PROC] __attribute__((used)) = {};
// 初始进程
static PCB pcb_boot = {};

// 当前进程指针
PCB *current = NULL;

void switch_boot_pcb() {
  current = &pcb_boot;
}

// 内核线程
void hello_fun(void *arg) {
  int j = 1;
  while (1) {
    for (int volatile i = 0; i < 100000; i++);
    Log("Hello World from kernel thread with arg '%p' for the %dth time!", (uintptr_t)arg, j);
    j++;
    yield();
  }
}

void init_proc() {

  char *argv[2] = {"--skip", NULL};
  char *envp[2] = {NULL};

  Log("Initializing processes...");
  switch_boot_pcb();

  // 从内核线程开始执行
  context_kload(&pcb[0], hello_fun, (void *)1L);
  context_uload(&pcb[1], "/bin/hello", argv, envp);
  yield();

  // Log("Jump to entry = %p", entry);
  // ((void(*)())entry) ();
}

Context* schedule(Context *prev) {
  // 保存当前上下文的栈顶指针
  current->cp = prev;
  // 切换到另外一个进程
  current = (current == &pcb[0] ? &pcb[1] : &pcb[0]);
  // 返回另一个进程的栈顶指针
  return current->cp;
}
