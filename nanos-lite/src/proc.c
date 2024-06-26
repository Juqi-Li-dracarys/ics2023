#include <proc.h>

#define MAX_NR_PROC 4

// PCB
static PCB pcb[MAX_NR_PROC] __attribute__((used)) = {};

// 初始PCB(empty)
static PCB pcb_boot = {};

// 当前进程指针
PCB *current = NULL;

void switch_boot_pcb() {
    // empty boot
    current = &pcb_boot;
}

// kernel thread
void hello_fun(void *arg) {
  int j = 1;
  while (1) {
    for (int volatile i = 0; i < 100000; i++);
    printf("\nHello from kernel thread with arg '%p' for the %dth time!\n", (uintptr_t)arg, j);
    j++;
    yield();
  }
}

void init_proc() {

  Log("Initializing processes...");

  // Do naive load
   naive_uload(NULL, "/bin/pal");

    //   char *argv[2] = {"--skip", NULL};
    //   char *envp[2] = {NULL};

    //   switch_boot_pcb();

    //   // 从内核线程开始执行
    //   context_kload(&pcb[0], hello_fun, (void *)1L);
    //   context_uload(&pcb[1], "/bin/pal", argv, envp);
      Log("Load process done...");
}

Context* schedule(Context *prev) {
  // 保存当前上下文的栈顶指针
  current->cp = prev;
  // 切换到另外一个PCB
  current = (current == &pcb[0] ? &pcb[1] : &pcb[0]);
  // 返回另一个PCB的栈顶指针
  return current->cp;
}
