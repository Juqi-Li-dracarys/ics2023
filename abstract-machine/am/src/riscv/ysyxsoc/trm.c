/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-01-18 20:54:49 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-03-23 16:48:12
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

// 转化学号到 16 进制
uint32_t value_hex(uint32_t a) {
    // 如果a为0，直接返回0
    if (a == 0) {
        return 0;
    }
    uint32_t result = 0;
    uint32_t multiplier = 1; // 用于乘以16的幂
    // 逐位计算十六进制值
    while (a > 0) {
        result += (a % 10) * multiplier; // 取余数并乘以对应的16的幂
        a /= 10; // 更新a，相当于除以16取整
        multiplier *= 16; // 更新乘数，相当于乘以10
    }
    return result;
}

// 芯片固化信息
// 开启 difftest 后需要注释本函数
static void chip_info() {
    volatile uint32_t i;
    volatile uint32_t j;
    volatile uint32_t value;
    uint32_t hex_value;
    asm volatile ("csrr %0, mvendorid" : "=r" (value));
    printf("CREATOR: %c%c%c%c", (char)(value >> 24), (char)(value >> 16), (char)(value >> 8), (char)(value));
    asm volatile ("csrr %0, marchid" : "=r" (value));
    printf("%d\n", value);
    // SEG display
    hex_value = value_hex(value);
    for(i = 0; i < 4; i++) {
        *(volatile char *)(SEG_BASE + i) = hex_value & 0xFF;
        hex_value = hex_value >> 8;
    }
    // LED twinkle
    while(*(volatile uint16_t *)(SWITCH_BASE) != 0x1) {
        *(volatile uint16_t *)(LED_BASE) = 0x0;
        j = 10000;
        while (j-- > 0);
        *(volatile uint16_t *)(LED_BASE) = 0xFFFF;
        j = 10000;
        while (j-- > 0);
    }
    return;
}

// 注意 Boot loader 不能调用库函数
// 同时多个 section 的复制需要分开
// 一级加载
void fsbt() {
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
    // copy ssbt code to sdram
    uint8_t *dst = (uint8_t *)(&_ssbt_start);
    uint8_t *src = (uint8_t *)(&_ssbt_load_start);
    for (size_t i = 0; i < (size_t)&_ssbt_size; i++) {
      dst[i] = src[i];
    }
    // jump to addr mapping sdram to excute ssbt
    *(volatile uint16_t *)(LED_BASE) = *(volatile uint16_t *)(LED_BASE) >> 4 | 0xF000; 
    ssbt();
}


// 二级加载
void ssbt() {
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
    // text
    uint8_t *dst = (uint8_t *)(&_text_start);
    uint8_t *src = (uint8_t *)(&_text_load_start); 
    for (size_t i = 0; i < (size_t)&_text_size; i++) {
      dst[i] = src[i];
    }
    // finish text load
    *(volatile uint16_t *)(LED_BASE) = *(volatile uint16_t *)(LED_BASE) >> 4 | 0xF000; 
    // read only data 
    dst = (uint8_t *)(&_rodata_start);
    src = (uint8_t *)(&_rodata_load_start); 
    for (size_t i = 0; i < (size_t)&_rodata_size; i++) {
      dst[i] = src[i];
    }
    // finish rodara load
    *(volatile uint16_t *)(LED_BASE) = *(volatile uint16_t *)(LED_BASE) >> 4 | 0xF000; 
    // data
    dst = (uint8_t *)(&_data_start);
    src = (uint8_t *)(&_data_load_start); 
    for (size_t i = 0; i < (size_t)&_data_size; i++) {
      dst[i] = src[i];
    }
    // finish data load
     *(volatile uint16_t *)(LED_BASE) = *(volatile uint16_t *)(LED_BASE) >> 4 | 0xF000; 
    // jump to the entry
    _trm_init();
}

// entry
void _trm_init() {
  chip_info();
  printf("program start running, heap:%p\n", heap.start);
  int ret = main(mainargs);
  halt(ret);
}


