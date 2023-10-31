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
#include <cpu/difftest.h>
#include "../local-include/reg.h"

extern const char* regs[];

bool isa_difftest_checkregs(CPU_state *ref_r, vaddr_t pc) {
  for(int i = 0; i < MUXDEF(CONFIG_RVE, 16, 32); i++) {
    if(ref_r->gpr[i] != gpr(i)) {
      printf("difftest fail @PC = 0x%08x, congratulation!\n", pc);
      puts("register map in REF:");
      for(int j = 0; j < 32; j++) {
        printf("%s:0X%08x ",regs[j], ref_r->gpr[j]);
        if((j + 1) % 4 == 0)
        putchar('\n');
      }
      return false;
    }
  }
  if(ref_r->pc != cpu.pc) {
    printf("difftest fail @PC = 0x%08x, congratulation!\n", pc);
    puts("register map in REF:");
    for(int j = 0; j < 32; j++) {
      printf("%s:0X%08x ",regs[j], ref_r->gpr[j]);
      if((j + 1) % 4 == 0)
      putchar('\n');
    }
    return false;
  }
  else {
    return true;
  }
}

void isa_difftest_attach() {
}
