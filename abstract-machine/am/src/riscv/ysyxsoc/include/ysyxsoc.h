#ifndef YSYXSOC_H__
#define YSYXSOC_H__

#include <klib-macros.h>
#include "riscv/riscv.h"


#define UART_BASE  0x10000000
#define UART_TX    0

#define SRAM_BASE  0x0f000000
#define SRAM_SIZE  0x00002000

#define MROM_BASE  0x20000000
#define MROM_SIZE  0x00001000


extern char _pmem_start;

#define PMEM_SIZE (128 * 1024 * 1024)
#define PMEM_END  ((uintptr_t)&_pmem_start + PMEM_SIZE)

#define NEMU_PADDR_SPACE \
  RANGE(&_pmem_start, PMEM_END), \
  RANGE(FB_ADDR, FB_ADDR + 0x200000), \
  RANGE(MMIO_BASE, MMIO_BASE + 0x1000) /* serial, rtc, screen, keyboard */


typedef uintptr_t PTE;

#define PGSIZE    4096

#endif