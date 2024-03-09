/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-03-08 08:52:48 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-03-08 17:43:36
 */


// 输出第一个字符
#define UART_BASE  0x10000000
#define UART_TX    0

char x = 104;

void _start() {
  *(volatile char *)(UART_BASE + UART_TX) = x ;
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
  while (1);
}