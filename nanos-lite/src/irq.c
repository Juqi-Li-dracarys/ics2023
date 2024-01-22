#include <common.h>

void do_syscall(Context *c);
Context* schedule(Context *prev);

static Context* do_event(Event e, Context* c) {
  Context* next_context = c;
  switch (e.event) {
    case EVENT_YIELD:     next_context = schedule(c);                           break;
    case EVENT_SYSCALL:   do_syscall(c);                                        break;
    case EVENT_IRQ_TIMER: next_context = schedule(c); Log("IRQ TIMER EVNET\n"); break;
    default: panic("Unhandled event ID = %d", e.event);
  }
  return next_context;
}

void init_irq(void) {
  Log("Initializing interrupt/exception handler...");
  // set do_event as the handler
  cte_init(do_event);
}
