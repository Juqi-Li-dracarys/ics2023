#ifndef _YSYXSOC_H__
#define _YSYXSOC_H__

#include <klib-macros.h>
#include "riscv/riscv.h"


#define UART_BASE  0x10000000
#define UART_TX    0

// 链接脚本的堆栈
extern char _heap_start;


// 1st boot loader
extern char  _ssbt_start;
extern char  _ssbt_load_start;
extern char  _ssbt_size;

extern char  _text_start;
extern char  _text_load_start;
extern char  _text_size;

extern char  _rodata_start;
extern char  _rodata_load_start;
extern char  _rodata_size;

extern char  _data_start;
extern char  _data_load_start;
extern char  _data_size;

// 片内定时器
#define  CLINT_BASE     0x02000000
#define  MTIME_OFFSET   0x0000bff8
#define  RTC_ADDR       CLINT_BASE + MTIME_OFFSET

typedef uintptr_t PTE;

#define PGSIZE     4096

// end of heap
#define SDRAM_END  0xa8000000

// bootloader
void fsbt()__attribute__((section("_fsbt")));
void ssbt()__attribute__((section("_ssbt")));

void _trm_init();

#endif