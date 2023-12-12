#include <am.h>
#include <riscv/riscv.h>
#include <klib.h>

static Context* (*user_handler)(Event, Context*) = NULL;


Context* __am_irq_handle(Context *c) {
  if (user_handler) {

    for(void* ptr = (void *)c; ptr <= (void *)c + 136; ptr = ptr + 4) {
      printf("0x%08x\n", *((uint32_t *)ptr));
    }

    Event ev = {0};
    switch (c->mcause) {
      default: ev.event = EVENT_ERROR; break;
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
