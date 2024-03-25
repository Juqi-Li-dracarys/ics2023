/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-03-08 08:52:48 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-03-23 18:16:27
 */

#define UART_BASE    0x10000000
#define UART_TX      0
#define UART_DIV_L   0
#define UART_DIV_M   1
#define UART_FCR     2
#define UART_LCR     3
#define UART_MCR     4
#define UART_LSR     5


#define FLASH_BASE 0x30000000
#define SDRAM_BASE 0xa0000000
#define TEST_START 0x0000FFF0
#define TEST_END   0x00010000

void main();

void _start() {

    volatile register int i = 100;

    // init uart 目前只支持 8N1 的串口传输配置

    // • Set the Line Control Register to the desired line control parameters. Set bit 7 to ‘1’ 
    // to allow access to the Divisor Latches.(1000 0011)
    *(volatile char *)(UART_BASE + UART_LCR)   =  0x83;

    // • Set the Divisor Latches, MSB first, LSB next.
    *(volatile char *)(UART_BASE + UART_DIV_M) =  0x00;
    *(volatile char *)(UART_BASE + UART_DIV_L) =  0x02;

    // • Set bit 7 of LCR to ‘0’ to disable access to Divisor Latches. At this time the 
    // transmission engine starts working and data can be sent and received. 
    *(volatile char *)(UART_BASE + UART_LCR)   =  0x03;

    // // • Set the FIFO trigger level. Generally, higher trigger level values produce less 
    // // interrupt to the system, so setting it to 14 bytes is recommended if the system 
    // // responds fast enough. 

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

    while (i-- > 0);

    asm volatile(
        "lui a0,0x0\n\t"
        "ebreak"
    );
    // shoud not reach here
}

