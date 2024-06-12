#include <am.h>
#include <nemu.h>

#define SYNC_ADDR (VGACTL_ADDR + 4)

void __am_gpu_init() {

}

void __am_gpu_config(AM_GPU_CONFIG_T *cfg) {
  *cfg = (AM_GPU_CONFIG_T) {
    .present = true, .has_accel = false,
    .width = inw(VGACTL_ADDR + 2), .height = inw(VGACTL_ADDR),
    .vmemsz = inw(VGACTL_ADDR + 2) * inw(VGACTL_ADDR) * sizeof(uint32_t)
  };
}

void __am_gpu_fbdraw(AM_GPU_FBDRAW_T *ctl) {
  register int i, j, k = 0;
  register uint16_t x_max = inw(VGACTL_ADDR + 2);
  register uint16_t y_max = inw(VGACTL_ADDR);
  if (ctl->sync) {
    outl(SYNC_ADDR, 1);
  }
  if (ctl->w == 0 || ctl->h == 0) return;
  for(j = ctl->y; j < ctl->y + ctl->h; j++) {
    for(i = ctl->x; i < ctl->x + ctl->w; i++) {
      if(i >= 0 && i < x_max && j >= 0 && j < y_max && ctl->pixels != NULL) {
        outl(FB_ADDR + (i + j * x_max) * sizeof(uint32_t), *((uint32_t *)(ctl->pixels) + k));
      }
      k++;
    }
  }
}

void __am_gpu_status(AM_GPU_STATUS_T *status) {
  status->ready = true;
}
