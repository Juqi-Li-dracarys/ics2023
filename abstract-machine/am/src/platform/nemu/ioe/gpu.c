#include <am.h>
#include <nemu.h>

#define SYNC_ADDR (VGACTL_ADDR + 4)

void __am_gpu_init() {

}

void __am_gpu_config(AM_GPU_CONFIG_T *cfg) {
  *cfg = (AM_GPU_CONFIG_T) {
    .present = true, .has_accel = false,
    .width = inw(VGACTL_ADDR + 2), .height = inw(VGACTL_ADDR),
    .vmemsz = inw(VGACTL_ADDR + 2) * inw(VGACTL_ADDR)
  };
}

void __am_gpu_fbdraw(AM_GPU_FBDRAW_T *ctl) {
  uint16_t x_max = inw(VGACTL_ADDR + 2);
  uint16_t y_max = inw(VGACTL_ADDR);
  uint32_t color = *((uint32_t *)(ctl->pixels));
  if (ctl->sync) {
    outl(SYNC_ADDR, 1);
  }
  for(int i = ctl->x; i < ctl->x + ctl->w; i++) {
    for(int j = ctl->y; j < ctl->y + ctl->h; j++) {
      if(i >= 0 && i < x_max && j >= 0 && j < y_max) {
        outl(FB_ADDR + i + j * x_max, color);
      }
    }
  }
}

void __am_gpu_status(AM_GPU_STATUS_T *status) {
  status->ready = true;
}
