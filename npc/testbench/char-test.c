/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-03-08 08:52:48 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-03-17 17:38:46
 */


// 输出第一个字符
#define UART_BASE  0x10000000
#define FLASH_BASE 0x30000000
#define UART_TX    0

#define SDRAM_BASE 0xa0000000

void _start() {

  *(volatile char *)(SDRAM_BASE + 0) = 'h';
  *(volatile char *)(SDRAM_BASE + 1) = 'e' ;
  *(volatile char *)(SDRAM_BASE + 2) = 'l' ;
  *(volatile char *)(SDRAM_BASE + 3) = 'l' ;
  *(volatile char *)(SDRAM_BASE + 4) = 'o' ;
  *(volatile char *)(SDRAM_BASE + 5) = ',' ;
  *(volatile char *)(SDRAM_BASE + 6) = 'S' ;
  *(volatile char *)(SDRAM_BASE + 7) = 'o' ;
  *(volatile char *)(SDRAM_BASE + 8) = 'C' ;
  *(volatile char *)(SDRAM_BASE + 9) = '!' ;
  *(volatile char *)(SDRAM_BASE + 10) = '\n';


  *(volatile char *)(UART_BASE + UART_TX) = *(volatile char *)(SDRAM_BASE + 0);
  *(volatile char *)(UART_BASE + UART_TX) = *(volatile char *)(SDRAM_BASE + 1);
  *(volatile char *)(UART_BASE + UART_TX) = *(volatile char *)(SDRAM_BASE + 2);
  *(volatile char *)(UART_BASE + UART_TX) = *(volatile char *)(SDRAM_BASE + 3);
  *(volatile char *)(UART_BASE + UART_TX) = *(volatile char *)(SDRAM_BASE + 4);
  *(volatile char *)(UART_BASE + UART_TX) = *(volatile char *)(SDRAM_BASE + 5);
  *(volatile char *)(UART_BASE + UART_TX) = *(volatile char *)(SDRAM_BASE + 6);
  *(volatile char *)(UART_BASE + UART_TX) = *(volatile char *)(SDRAM_BASE + 7);
  *(volatile char *)(UART_BASE + UART_TX) = *(volatile char *)(SDRAM_BASE + 8);
  *(volatile char *)(UART_BASE + UART_TX) = *(volatile char *)(SDRAM_BASE + 9);
  *(volatile char *)(UART_BASE + UART_TX) = *(volatile char *)(SDRAM_BASE + 10);
  
  
  asm volatile(
    "mv a0, %0\n\t"
    "ebreak"
    : 
    :"r"(0)
  );
  // shoud not reach here
  while (1);
}
