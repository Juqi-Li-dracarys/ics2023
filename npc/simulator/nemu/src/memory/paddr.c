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

#include <memory/host.h>
#include <memory/paddr.h>
#include <isa.h>

static uint8_t flash[CONFIG_FLASH_SIZE] = {};
static uint8_t sram[CONFIG_SRAM_SIZE] = {};
static uint8_t sdram[CONFIG_SDRAM_SIZE] = {};

uint8_t* guest_to_host(paddr_t paddr) { 
  if(in_flash(paddr))
    return flash + paddr - CONFIG_FLASH_MBASE;
  else if(in_sram(paddr))
    return sram + paddr - CONFIG_SRAM_MBASE;
  else if(in_sdram(paddr))
    return sdram + paddr - CONFIG_SDRAM_MBASE;
  return 0;
}

static word_t pmem_read(paddr_t addr, int len) {
  word_t ret = host_read(guest_to_host(addr), len);
  return ret;
}

static void pmem_write(paddr_t addr, int len, word_t data) {
  host_write(guest_to_host(addr), len, data);
  return;
}

void init_mem() {
  uint32_t *p = (uint32_t *)flash;
  int i;
  for (i = 0; i < (int) (CONFIG_FLASH_SIZE / sizeof(p[0])); i ++) {
    p[i] = rand();
  }
}

word_t paddr_read(paddr_t addr, int len) {
  return pmem_read(addr, len);
}

void paddr_write(paddr_t addr, int len, word_t data) {
  pmem_write(addr, len, data); 
  return;
}
