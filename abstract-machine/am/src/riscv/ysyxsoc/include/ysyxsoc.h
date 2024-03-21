#ifndef _YSYXSOC_H__
#define _YSYXSOC_H__

#include <klib-macros.h>
#include "riscv/riscv.h"


#define UART_BASE  0x10000000
#define UART_TX    0

// 链接脚本的堆栈
extern char _heap_start;

// SRAM 数据区
extern char _data_start;
extern char _data_load_start;
extern char _data_size;

#define  CLINT_BASE     0x02000000
#define  MTIME_OFFSET   0x0000bff8
#define  RTC_ADDR       CLINT_BASE + MTIME_OFFSET

#define  SRAM_END       0x0f000000 + 0x00000020

typedef uintptr_t PTE;

#define PGSIZE    4096

void _trm_init();

// bootloader
void fsbt()__attribute__((section("_fsbt")));
void ssbt()__attribute__((section("_ssbt")));

#endif