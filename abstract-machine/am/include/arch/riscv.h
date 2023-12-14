#ifndef ARCH_H__
#define ARCH_H__

#ifdef __riscv_e
#define NR_REGS 16
#else
#define NR_REGS 32
#endif

// orgnize the following code according to trap.s
struct Context {
  uintptr_t gpr[NR_REGS], mcause, mstatus, mepc;
  void *pdir;
};

#ifdef __riscv_e
#define GPR1 gpr[15] // a5
#else
#define GPR1 gpr[17] // a7
#endif

// ARGS_ARRAY ("ecall", "a7", "a0", "a1", "a2", "a0")

#define GPR2 gpr[10] // a0
#define GPR3 gpr[11]
#define GPR4 gpr[12]
#define GPRx gpr[10] // a0

#endif
