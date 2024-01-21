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
#include <memory/vaddr.h>
#include <memory/paddr.h>

#define VA_OFFSET(addr) (addr & 0x00000FFF)         // 页面内的偏移
#define VA_VPN_2(addr)  ((addr >> 12) & 0x000003FF) // 2级页号
#define VA_VPN_1(addr)  ((addr >> 22) & 0x000003FF) // 1级页号
 
#define PA_OFFSET(addr) (addr & 0x00000FFF)         //提取物理地址的低 12 位，即在页面内的偏移
#define PA_PPN(addr)    ((addr >> 12) & 0x000FFFFF) //提取物理地址的高 20 位，即物理页号


paddr_t isa_mmu_translate(vaddr_t vaddr, int len, int type) {
  uint32_t VPN_1 = VA_VPN_1((uint32_t)vaddr);
  uint32_t VPN_2 = VA_VPN_2((uint32_t)vaddr);
  // 根据 satp 找到一级页表基地址
  paddr_t *VPB_1 = (paddr_t *)guest_to_host((paddr_t)(cpu.csr[_satp] << 12));
  assert(VPB_1 != NULL);
  // 二级页表
  word_t *VPB_2 = (word_t *)guest_to_host(VPB_1[VPN_1]);
  assert(VPB_2 != NULL);
  // 物理页号 + 页内偏移
  paddr_t paddr = (paddr_t)((VPB_2[VPN_2] & (~0xfff)) | PA_OFFSET((uint32_t)vaddr));
  assert(paddr == vaddr);
  return paddr;
}
