/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-03-08 08:52:48 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-03-09 15:58:31
 */


// 输出第一个字符
#define UART_BASE  0x10000000
#define FLASH_BASE 0x30000000
#define UART_TX    0


void _start() {

  *(volatile char *)(UART_BASE + UART_TX) = 'h';
  *(volatile char *)(UART_BASE + UART_TX) = 'e' ;
  *(volatile char *)(UART_BASE + UART_TX) = 'l' ;
  *(volatile char *)(UART_BASE + UART_TX) = 'l' ;
  *(volatile char *)(UART_BASE + UART_TX) = 'o' ;
  *(volatile char *)(UART_BASE + UART_TX) = ',' ;
  *(volatile char *)(UART_BASE + UART_TX) = 'S' ;
  *(volatile char *)(UART_BASE + UART_TX) = 'o' ;
  *(volatile char *)(UART_BASE + UART_TX) = 'C' ;
  *(volatile char *)(UART_BASE + UART_TX) = '!' ;
  *(volatile char *)(UART_BASE + UART_TX) = '\n';

   asm volatile(
    "mv a0, %0\n\t"
    "ebreak"
    : 
    :"r"(0)
  );
  // shoud not reach here
  while (1);
}