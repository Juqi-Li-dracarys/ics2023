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

#include <isa.h>
#include <reg.h>

const char *regs[] = {
  "$0", "ra", "sp", "gp", "tp", "t0", "t1", "t2",
  "s0", "s1", "a0", "a1", "a2", "a3", "a4", "a5",
  "a6", "a7", "s2", "s3", "s4", "s5", "s6", "s7",
  "s8", "s9", "s10", "s11", "t3", "t4", "t5", "t6",
  "mepc", "mstatus", "mcause", "mtvec", "satp"
};

// print the value of each register
void isa_reg_display() {
  puts("ALL register in nemu:");
  for(int i = 0; i < MUXDEF(CONFIG_RVE, 16, 32) + 5; i++) {
    if(i < MUXDEF(CONFIG_RVE, 16, 32)) printf("%s:0X%016lx ",regs[i], gpr(i));
    else printf("%s:0X%016lx ",regs[i], csr(i - MUXDEF(CONFIG_RVE, 16, 32)));
    if((i + 1) % 4 == 0)
    putchar('\n');
  }
  putchar('\n');
  return ;
}

// return the value of register
word_t isa_reg_str2val(const char *s, bool *success) {
  for(int i = 0; i < MUXDEF(CONFIG_RVE, 16, 32) + 5; i++) {
    if (strcmp(regs[i], s) == 0) {
      *success = 1;
      return i < MUXDEF(CONFIG_RVE, 16, 32) ? gpr(i) : csr(i - MUXDEF(CONFIG_RVE, 16, 32));
    }
  }
  *success = 0;
  return 0;
}
