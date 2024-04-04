/***************************************************************************************
* Copyright (c) 2014-2022 Zihao Yu, Nanjing University
*
* NEMU is licensed under Mulan PSL v2.
* You can use this software according to the terms and conditions of the Mulan PSL v2.
* You may obtain a copy of Mulan PSL v2 at:
*          http://license.coscl.org.cn/MulanPSL2
*
* THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
* EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
* MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
*
* See the Mulan PSL v2 for more details.
***************************************************************************************/

#ifndef __ISA_RISCV_H__
#define __ISA_RISCV_H__

#include <common.h>

// VMM offset
#define VA_OFFSET(addr) (addr & 0x00000FFF)         // 页面内的偏移
#define VA_VPN_2(addr)  ((addr >> 12) & 0x000003FF) // 2级页号
#define VA_VPN_1(addr)  ((addr >> 22) & 0x000003FF) // 1级页号
 
#define PA_OFFSET(addr) (addr & 0x00000FFF)         // 提取物理地址的低 12 位，即在页面内的偏移
#define PA_PPN(addr)    ((addr >> 12) & 0x000FFFFF) // 提取物理地址的高 20 位，即物理页号

// OFFSET of msatus
#define MIE_OFFSET  3
#define MPIE_OFFSET 7

// timer interrupt for riscv32， mcause value
#define IRQ_TIMER 0x80000007

// 寄存器代号
enum {
  _mepc, _mstatus,
  _mcause, _mtvec, _satp
};

typedef struct {
  word_t gpr[MUXDEF(CONFIG_RVE, 16, 32)];
  vaddr_t pc;
  // RISCV CSR registers for exception and interruption
  word_t csr[5];
  bool INTR;
} MUXDEF(CONFIG_RV64, riscv64_CPU_state, riscv32_CPU_state);

// decode
typedef struct {
  union {
    uint32_t val;
  } inst;
} MUXDEF(CONFIG_RV64, riscv64_ISADecodeInfo, riscv32_ISADecodeInfo);


// 检查最高位是否开启分页
#define isa_mmu_check(vaddr, len, type)  ((cpu.csr[_satp] & 0x80000000) ? MMU_TRANSLATE : MMU_DIRECT)

#endif
