/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-01-18 20:54:49 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-03-09 16:22:05
 */

#include <am.h>
#include <ysyxsoc.h>
#include <klib.h>

int main(const char *args);

// // 链接脚本的标记
// extern char _sram_start;
// extern char _sram_size;
// // extern char _heap_start;

// // SRAM 数据区
// extern char _data_start;
// extern char _data_load_start;
// extern char _data_size;

// #define SRAM_END  ((uintptr_t)&_sram_start + (uintptr_t)&_sram_size)

Area heap = RANGE(&_heap_start, SRAM_END);

// Makefile 参数传递
#ifndef MAINARGS
#define MAINARGS ""
#endif

static const char mainargs[] = MAINARGS;

void putch(char ch) {
  *(volatile char *)(UART_BASE + UART_TX) = ch ;
}

void halt(int code) {
  asm volatile(
    "mv a0, %0\n\t"
    "ebreak"
    : 
    :"r"(code)
  );
  // should not reach here
  while (1);
}


void _trm_init() {
  // boot loader
  if (&_data_start != &_data_load_start) {
    memcpy(&_data_start, &_data_load_start, (size_t)&_data_size);
  }
  // entry
  int ret = main(mainargs);
  halt(ret);
}
