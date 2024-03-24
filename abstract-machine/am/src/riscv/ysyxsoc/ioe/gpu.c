/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-03-24 14:48:04 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-03-24 14:48:29
 */

#include <am.h>
#include <klib-macros.h>
#include <ysyxsoc.h>

#define SYNC_ADDR (VGACTL_ADDR + 4)

void __am_gpu_init() {

}

void __am_gpu_config(AM_GPU_CONFIG_T *cfg) {

}

void __am_gpu_fbdraw(AM_GPU_FBDRAW_T *ctl) {

}

void __am_gpu_status(AM_GPU_STATUS_T *status) {
  status->ready = false;
}