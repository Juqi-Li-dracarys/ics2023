#ifndef _YSYXSOC_H__
#define _YSYXSOC_H__

#include <klib-macros.h>
#include "riscv/riscv.h"

// 串口
#define  UART_BASE  0x10000000
#define  UART_TX    0

// GPIO
#define  GPIO_BASE   0x10002000
#define  LED_BASE    GPIO_BASE
#define  SWITCH_BASE GPIO_BASE + 0X4
#define  SEG_BASE    GPIO_BASE + 0X8

// 片内定时器
#define  CLINT_BASE     0x02000000
#define  MTIME_OFFSET   0x0000bff8
#define  RTC_ADDR       CLINT_BASE + MTIME_OFFSET

// end of heap
#define  SDRAM_END   0xa8000000

//堆栈
extern char _heap_start;

// boot loader
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


typedef uintptr_t PTE;

#define PGSIZE     4096

// bootloader
void fsbt()__attribute__((section("_fsbt")));
void ssbt()__attribute__((section("_ssbt")));

void _trm_init();

#endif