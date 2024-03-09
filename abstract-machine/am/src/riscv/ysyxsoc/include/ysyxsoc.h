#ifndef YSYXSOC_H__
#define YSYXSOC_H__

#include <klib-macros.h>
#include "riscv/riscv.h"


#define UART_BASE  0x10000000
#define UART_TX    0

// 链接脚本的标记
extern char _sram_start;
extern char _sram_size;
extern char _heap_start;

// SRAM 数据区
extern char _data_start;
extern char _data_load_start;
extern char _data_size;

#define SRAM_END  ((uintptr_t)&_sram_start + (uintptr_t)&_sram_size)


typedef uintptr_t PTE;

#define PGSIZE    4096

#endif