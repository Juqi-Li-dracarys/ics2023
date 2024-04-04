
/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2023-12-28 23:26:29 
 * @Last Modified by:   Juqi Li @ NJU 
 * @Last Modified time: 2023-12-28 23:26:29 
 */

// timer interrupt for riscv32
#define IRQ_TIMER 0x80000007

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
// 6. 回到 __am_asm_trap，再次切换上下文

// Event dispatch function
Context* __am_irq_handle(Context *c) {
  if (user_handler) {
    Event ev = {0};
    // 中断
    if(c->mcause == IRQ_TIMER) {
        ev.event = EVENT_IRQ_TIMER;
    }
    // 异常
    else if(c->mcause == 0xb) {
        switch (c->GPR1) {
        case -1: ev.event = EVENT_YIELD; c->mepc = c->mepc + 4; break;
        default: {
          if(c->GPR1 >= 0 && c->GPR1 <= 19) {
            ev.event = EVENT_SYSCALL;
            c->mepc = c->mepc + 4;
          }
          else {
            ev.event = EVENT_ERROR;
            c->mepc = c->mepc + 4;
          }
          break;
        }
      }
    }
    else {assert(0);}
    c = user_handler(ev, c);
    assert(c != NULL);
  }
  // 切换上下文之后的 context
  // 不一定是之前的 context 指针
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

// 创建内核线程
Context *kcontext(Area kstack, void (*entry)(void *), void *arg) {
  // 内核栈顶部存放 context
  Context *c = (Context *)(kstack.end) - 1;
  c->mepc = (uintptr_t)entry;
  // 在恢复上下文时， MIE 位会为 1
  // enbale the global hardware interrupt
  // c->mstatus = 0xa00001800 | (1 << MPIE_OFFSET);
  c->mstatus = 0xa00001800;
  c->GPR2 = (uintptr_t)arg;
  return c;
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
