/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-03-08 08:52:48 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-03-08 10:00:01
 */


// 输出第一个字符
#define UART_BASE  0x10000000
#define UART_TX    0

void _start() {
  *(volatile char *)(UART_BASE + UART_TX) = 'A' ;
  *(volatile char *)(UART_BASE + UART_TX) = '\n';
  while (1);
}