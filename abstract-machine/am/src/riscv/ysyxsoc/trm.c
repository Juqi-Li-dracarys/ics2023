/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-01-18 20:54:49 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-03-21 23:44:35
 */

#include <am.h>
#include <ysyxsoc.h>
#include <klib.h>

int main(const char *args);

// 堆区
Area heap = RANGE(&_heap_start, SDRAM_END);

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
    // volatile uint32_t value;
    // asm volatile ("csrr %0, mvendorid" : "=r" (value));
    // printf("Author: %c%c%c%c", (char)(value >> 24), (char)(value >> 16), (char)(value >> 8), (char)(value));
    // asm volatile ("csrr %0, marchid" : "=r" (value));
    // printf("%d\n", value);
    return;
}


// 一级加载
void fsbt() {
    // copy ssbt code to sdram
    uint8_t *dst = (uint8_t *)(&_ssbt_start);
    uint8_t *src = (uint8_t *)(&_ssbt_load_start); 
    for (size_t i = 0; i < (size_t)&_ssbt_size; i++) {
      dst[i] = src[i];
    }
    // jump to sdram addr to excute ssbt
    ssbt();
}

// 二级加载
void ssbt() {
    // copy user's code
    uint8_t *dst = (uint8_t *)(&_code_start);
    uint8_t *src = (uint8_t *)(&_code_load_start); 
    for (size_t i = 0; i < (size_t)&_code_size; i++) {
      dst[i] = src[i];
    }
    // jump to the entry
    _trm_init();
}


// entry
void _trm_init() {
  chip_info();
  printf("program load finish.\n");
  printf("heap:%p", &_heap_start);
  int ret = main(mainargs);
  halt(ret);
}
