/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-01-18 20:54:49 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-03-21 19:10:03
 */

#include <am.h>
#include <ysyxsoc.h>
#include <klib.h>

int main(const char *args);

// 堆区
Area heap = RANGE(&_heap_start, SRAM_END);

// Makefile 参数
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

// 芯片固化信息
static void chip_info() {
    volatile uint32_t value;
    asm volatile ("csrr %0, mvendorid" : "=r" (value));
    printf("Author: %c%c%c%c", (char)(value >> 24), (char)(value >> 16), (char)(value >> 8), (char)(value));
    asm volatile ("csrr %0, marchid" : "=r" (value));
    printf("%d\n", value);
    return;
}


void _trm_init() {
  // boot loader
  if (&_data_start != &_data_load_start) {
    memcpy(&_data_start, &_data_load_start, (size_t)&_data_size);
  }
  chip_info();
  printf("program load finish.\n");
  int ret = main(mainargs);
  halt(ret);
}
