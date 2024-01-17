#ifndef __RISCV_REG_H__
#define __RISCV_REG_H__

#include <common.h>
#include <sim.h>

extern uint32_t *cpu_gpr;
extern uint32_t *cpu_mstatus;
extern uint32_t *cpu_mtvec; 
extern uint32_t *cpu_mepc;
extern uint32_t *cpu_mcause;

extern const char *regs[];

static inline int check_reg_idx(int idx) {
  IFDEF(CONFIG_RT_CHECK, assert(idx >= 0 && idx < MUXDEF(CONFIG_RVE, 16, 32)));
  return idx;
}

static inline int check_csr_idx(int idx) {
  IFDEF(CONFIG_RT_CHECK, assert(idx >= 0 && idx < 4));
  return idx;
}

// refer to gpr and csr in cpu
#define gpr(idx) (sim_cpu.gpr[check_reg_idx(idx)])
#define csr(idx) (word_t)*((word_t *)&(sim_cpu.csr) + check_csr_idx(idx))

static inline const char* reg_name(int idx) {
  extern const char* regs[];
  return regs[check_reg_idx(idx)];
}

static inline const char* csr_name(int idx) {
  extern const char* regs[];
  return regs[check_csr_idx(idx) + MUXDEF(CONFIG_RVE, 16, 32)];
}

#endif
