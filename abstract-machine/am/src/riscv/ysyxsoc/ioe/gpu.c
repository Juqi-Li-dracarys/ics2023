/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-03-24 14:48:04 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-03-24 23:14:23
 */

#include <am.h>
#include <klib-macros.h>
#include <ysyxsoc.h>


void __am_gpu_init() {

}

void __am_gpu_config(AM_GPU_CONFIG_T *cfg) {
    *cfg = (AM_GPU_CONFIG_T) {
        .present = true  , .has_accel = false,
        .width   = VGA_W , .height    = VGA_H,
        .vmemsz  = VGA_W * VGA_H * sizeof(uint32_t)
  };
    return;   
}

void __am_gpu_fbdraw(AM_GPU_FBDRAW_T *ctl) {
    register int i, j, k = 0;
    register uint16_t x_max = VGA_W;
    register uint16_t y_max = VGA_H;
    if (ctl->w == 0 || ctl->h == 0) return;
    for(j = ctl->y; j < ctl->y + ctl->h; j++) {
        for(i = ctl->x; i < ctl->x + ctl->w; i++) {
            if(i >= 0 && i < x_max && j >= 0 && j < y_max && ctl->pixels != NULL) {
                *(volatile uint32_t *)(VGA_BASE + (i + j * x_max) * sizeof(uint32_t)) = *((uint32_t *)(ctl->pixels) + k);
            }
            k++;
        }
    }
}

void __am_gpu_status(AM_GPU_STATUS_T *status) {
    status->ready = false;
}

