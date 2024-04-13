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

// 关闭中断使能
// 将 mstatus.MIE 保存到 mstatus.MPIE 中, 然后将 mstatus.MIE 位置为 0
void reset_intr() {
//   cpu.csr[_mstatus] = (cpu.csr[_mstatus] & ~(0x1 << MPIE_OFFSET)) | (((cpu.csr[_mstatus] >> MIE_OFFSET) & 0x1) << MPIE_OFFSET) ;
//   cpu.csr[_mstatus] &= ~(1 << MIE_OFFSET);
}

// 开启中断使能
// 将 mstatus.MPIE 还原到 mstatus.MIE 中, 然后将 mstatus.MPIE 位置为 1
void set_intr() { 
//   cpu.csr[_mstatus] = (cpu.csr[_mstatus] & ~(0x1 << MIE_OFFSET)) | (((cpu.csr[_mstatus] >> MPIE_OFFSET) & 0x1) << MIE_OFFSET);
//   cpu.csr[_mstatus] |= (1 << MPIE_OFFSET);
}


word_t isa_raise_intr(word_t NO, vaddr_t epc) {
  // 关闭定时器中断
  // 防止异常处理被打断
  reset_intr();
  cpu.csr[_mepc] = epc;
  cpu.csr[_mcause] = NO;
  // 跳转到指定位置
  return cpu.csr[_mtvec];
}


// 判断是否中断跳转
word_t isa_query_intr() {
  // MIE = 1 且 cpu 中断位启动, 则产生中断信号
  if (cpu.INTR && (cpu.csr[_mstatus] & (1 << MIE_OFFSET))) {
      cpu.INTR = false;
      return IRQ_TIMER;
  }
  return INTR_EMPTY; 
}


