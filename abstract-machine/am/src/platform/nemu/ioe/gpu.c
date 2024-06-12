#include <am.h>
#include <nemu.h>

#define SYNC_ADDR (VGACTL_ADDR + 4)
#define PIX_WIDTH 2

volatile uint16_t x_max = 0;
volatile uint16_t y_max = 0;

void __am_gpu_init() {

}

void __am_gpu_config(AM_GPU_CONFIG_T *cfg) {

    x_max = inw(VGACTL_ADDR + 2);
    y_max = inw(VGACTL_ADDR);

    *cfg = (AM_GPU_CONFIG_T) {
        .present = true, .has_accel = false,
        .width = x_max, .height = y_max,
        .vmemsz = (x_max * y_max) << PIX_WIDTH
    };
}

void __am_gpu_fbdraw(AM_GPU_FBDRAW_T *ctl) {
  register int i, j, k = 0;
  if (ctl->sync) {
    outl(SYNC_ADDR, 1);
  }
  if (ctl->w == 0 || ctl->h == 0) return;
  for(j = ctl->y; j < ctl->y + ctl->h; j++) {
    for(i = ctl->x; i < ctl->x + ctl->w; i++) {
      if(i >= 0 && i < x_max && j >= 0 && j < y_max && ctl->pixels != NULL) {
        outl(FB_ADDR + ((i + (j * x_max)) * sizeof(uint32_t)), *((uint32_t *)(ctl->pixels) + k));
      }
      k++;
    }
  }
}

void __am_gpu_status(AM_GPU_STATUS_T *status) {
  status->ready = true;
}


