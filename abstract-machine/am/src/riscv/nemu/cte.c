#include <am.h>
#include <riscv/riscv.h>
#include <klib.h>

static Context* (*user_handler)(Event, Context*) = NULL;

// 整个跳转流程如下：
// 1. init 时将跳转地址插入 mtvec，并设置好 handler 函数
// 2. 执行到 ecall 时跳转到 mtvec，即 __am_asm_trap
// 3. 在 __am_asm_trap 完成上下文切换后，跳转至 __am_irq_handle
// 4. 解析本次 event 类型，后跳转到 handler 函数
// 5. 在 handler 函数中根据类型，执行对应操作

Context* __am_irq_handle(Context *c) {
  if (user_handler) {
    Event ev = {0};
    // judge the event type accroding to $a7
    switch (c->gpr[17]) {
      case 0xffffffff: ev.event = EVENT_YIELD; c->mepc = c->mepc + 4; break;
      default: {
        if(c->gpr[17] >= 0 && c->gpr[17] <= 20) {
          ev.event = EVENT_SYSCALL;
        }
        else {
          ev.event = EVENT_ERROR;
        }
        break;
      }
    }
    c = user_handler(ev, c);
    assert(c != NULL);
  }
  return c;
}

extern void __am_asm_trap(void);

bool cte_init(Context*(*handler)(Event, Context*)) {
  // initialize exception entry
  // we load the exception entry into mtvec
  asm volatile("csrw mtvec, %0" : : "r"(__am_asm_trap));
  
  // register event handler
  user_handler = handler;

  return true;
}

Context *kcontext(Area kstack, void (*entry)(void *), void *arg) {
  return NULL;
}

void yield() {
#ifdef __riscv_e
  asm volatile("li a5, -1; ecall");
#else
  asm volatile("li a7, -1; ecall");
#endif
}

bool ienabled() {
  return false;
}

void iset(bool enable) {
}
