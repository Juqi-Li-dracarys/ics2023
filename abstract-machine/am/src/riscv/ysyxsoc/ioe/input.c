/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-03-24 14:36:47 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-03-24 16:03:51
 */


#include <am.h>
#include <klib-macros.h>
#include <ysyxsoc.h>
#include <klib.h>


void __am_input_keybrd(AM_INPUT_KEYBRD_T *kbd) {
    uint8_t data = *(volatile char *)(PS2_BASE);
    if(data != 0xf0) {
        printf("down: %p\n", data);
    }
    else {
        data = *(volatile char *)(PS2_BASE);
        printf("up: %p\n", data);
    }
    
    kbd->keycode = 0;
    kbd->keydown = 0;
    return;
}
