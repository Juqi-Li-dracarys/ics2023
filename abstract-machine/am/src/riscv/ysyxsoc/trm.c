/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-01-18 20:54:49 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-03-23 15:37:03
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
// 开启 difftest 后需要注释
static void chip_info() {
    volatile uint32_t value;
    asm volatile ("csrr %0, mvendorid" : "=r" (value));
    printf("Author: %c%c%c%c", (char)(value >> 24), (char)(value >> 16), (char)(value >> 8), (char)(value));
    asm volatile ("csrr %0, marchid" : "=r" (value));
    printf("%d\n", value);
    *(volatile char *)(0x10002000 + 0x8) = 9 ;
    *(volatile char *)(0x10002000 + 0x8) = 9 ;
    return;
}

// 注意 Boot loader 不能调用库函数
// 同时多个 section 的复制需要分开

// 一级加载
void fsbt() {
    // copy ssbt code to sdram
    uint8_t *dst = (uint8_t *)(&_ssbt_start);
    uint8_t *src = (uint8_t *)(&_ssbt_load_start);
    *(volatile char *)(UART_BASE + UART_TX) = 'f' ;
    *(volatile char *)(UART_BASE + UART_TX) = 's' ;
    *(volatile char *)(UART_BASE + UART_TX) = 'b' ;
    *(volatile char *)(UART_BASE + UART_TX) = 't' ;
    *(volatile char *)(UART_BASE + UART_TX) = ' ' ;
    *(volatile char *)(UART_BASE + UART_TX) = 's' ;
    *(volatile char *)(UART_BASE + UART_TX) = 't' ;
    *(volatile char *)(UART_BASE + UART_TX) = 'a' ;
    *(volatile char *)(UART_BASE + UART_TX) = 'r' ;
    *(volatile char *)(UART_BASE + UART_TX) = 't' ;
    *(volatile char *)(UART_BASE + UART_TX) = '.' ;
    *(volatile char *)(UART_BASE + UART_TX) = '.' ;
    *(volatile char *)(UART_BASE + UART_TX) = '.' ;
    *(volatile char *)(UART_BASE + UART_TX) = '\n' ;
    for (size_t i = 0; i < (size_t)&_ssbt_size; i++) {
      dst[i] = src[i];
    }
    // jump to addr mapping sdram to excute ssbt
    ssbt();
}


// 二级加载
void ssbt() {
    // copy user's code
    uint8_t *dst = (uint8_t *)(&_text_start);
    uint8_t *src = (uint8_t *)(&_text_load_start); 
    *(volatile char *)(UART_BASE + UART_TX) = 's' ;
    *(volatile char *)(UART_BASE + UART_TX) = 's' ;
    *(volatile char *)(UART_BASE + UART_TX) = 'b' ;
    *(volatile char *)(UART_BASE + UART_TX) = 't' ;
    *(volatile char *)(UART_BASE + UART_TX) = ' ' ;
    *(volatile char *)(UART_BASE + UART_TX) = 's' ;
    *(volatile char *)(UART_BASE + UART_TX) = 't' ;
    *(volatile char *)(UART_BASE + UART_TX) = 'a' ;
    *(volatile char *)(UART_BASE + UART_TX) = 'r' ;
    *(volatile char *)(UART_BASE + UART_TX) = 't' ;
    *(volatile char *)(UART_BASE + UART_TX) = '.' ;
    *(volatile char *)(UART_BASE + UART_TX) = '.' ;
    *(volatile char *)(UART_BASE + UART_TX) = '.' ;
    *(volatile char *)(UART_BASE + UART_TX) = '\n' ;
    for (size_t i = 0; i < (size_t)&_text_size; i++) {
      dst[i] = src[i];
    }
    // read only data 
    dst = (uint8_t *)(&_rodata_start);
    src = (uint8_t *)(&_rodata_load_start); 
    for (size_t i = 0; i < (size_t)&_rodata_size; i++) {
      dst[i] = src[i];
    }
    // data
    dst = (uint8_t *)(&_data_start);
    src = (uint8_t *)(&_data_load_start); 
    for (size_t i = 0; i < (size_t)&_data_size; i++) {
      dst[i] = src[i];
    }
    // jump to the entry
    _trm_init();
}

// entry
void _trm_init() {
  chip_info();
  printf("program load finish, heap:%p\n", heap.start);
  int ret = main(mainargs);
  halt(ret);
}


