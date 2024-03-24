/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-03-24 11:10:30 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-03-24 11:24:49
 */

#include <am.h>
#include <ysyxsoc.h>

void __am_uart_rx(AM_UART_RX_T *uart_rx) {
    if(*(volatile char *)(UART_BASE + UART_LSR) & 0x01) {
        uart_rx->data =  *(volatile char *)(UART_BASE + UART_RX);
    }
    else {
        uart_rx->data = 0xff;
    }
    return;
}


