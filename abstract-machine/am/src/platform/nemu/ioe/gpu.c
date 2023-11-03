#include <am.h>
#include <nemu.h>

#define SYNC_ADDR (VGACTL_ADDR + 4)

void __am_gpu_init() {

}

void __am_gpu_config(AM_GPU_CONFIG_T *cfg) {
  *cfg = (AM_GPU_CONFIG_T) {
    .present = true, .has_accel = false,
    .width = inw(VGACTL_ADDR + 2), .height = inw(VGACTL_ADDR),
    .vmemsz = 0
  };
}

void __am_gpu_fbdraw(AM_GPU_FBDRAW_T *ctl) {
  // int i, j, k = 0;
  // uint16_t x_max = inw(VGACTL_ADDR + 2);
  // uint16_t y_max = inw(VGACTL_ADDR);
  // if (ctl->sync) {
  //   outl(SYNC_ADDR, 1);
  // }
  // if (ctl->w == 0 || ctl->h == 0) return;
  // for(j = ctl->y; j < ctl->y + ctl->h; j++) {
  //   for(i = ctl->x; i < ctl->x + ctl->w; i++) {
  //     if(i >= 0 && i < x_max && j >= 0 && j < y_max) {
  //       outl(FB_ADDR + i + j * x_max, *((uint32_t *)(ctl->pixels) + k));
  //     }
  //     k++;
  //   }
  // }

  int x = ctl->x, y = ctl->y, w = ctl->w, h = ctl->h;
  if (!ctl->sync && (w == 0 || h == 0)) return;
  uint32_t *pixels = ctl->pixels;
  uint32_t *fb = (uint32_t *)(uintptr_t)FB_ADDR;
  uint32_t screen_w = inl(VGACTL_ADDR) >> 16;
  for (int i = y; i < y+h; i++) {
    for (int j = x; j < x+w; j++) {
      fb[screen_w*i+j] = pixels[w*(i-y)+(j-x)];
    }
  }
  if (ctl->sync) {
    outl(SYNC_ADDR, 1);
  }
}

void __am_gpu_status(AM_GPU_STATUS_T *status) {
  status->ready = true;
}
