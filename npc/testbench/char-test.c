/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-03-08 08:52:48 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-03-23 17:30:39
 */


// 输出第一个字符
#define UART_BASE  0x10000000
#define FLASH_BASE 0x30000000
#define UART_TX    0

#define SDRAM_BASE 0xa0000000
#define TEST_START 0x0000FFF0
// #define TEST_START 0x0
#define TEST_END   0x00010000

void _start() {

  *(volatile char *)(UART_BASE) = 'h' ;
  *(volatile char *)(UART_BASE) = 'e' ;
  *(volatile char *)(UART_BASE) = 'l' ;
  *(volatile char *)(UART_BASE) = 'l' ;
  *(volatile char *)(UART_BASE) = 'o' ;
  *(volatile char *)(UART_BASE) = ',' ;
  *(volatile char *)(UART_BASE) = 'S' ;
  *(volatile char *)(UART_BASE) = 'o' ;
  *(volatile char *)(UART_BASE) = 'C' ;
  *(volatile char *)(UART_BASE) = '!' ;
  *(volatile char *)(UART_BASE) = '\n';

  *(volatile char *)(UART_BASE) = 'h' ;
  *(volatile char *)(UART_BASE) = 'h' ;

  asm volatile(
    "mv a0, %0\n\t"
    "ebreak"
    : 
    :"r"(0)
  );
  // shoud not reach here
  while (1);
}
