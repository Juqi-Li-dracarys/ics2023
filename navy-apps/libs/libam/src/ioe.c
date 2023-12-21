
// Rewrite AM IOE in navy API

#include <ioe.h>

# define NONE 0

// IOE for timer
void __am_timer_init() {
  return;
}

void __am_timer_uptime(AM_TIMER_UPTIME_T *uptime) {
  uptime->us = (uint64_t)(NDL_GetTicks()) * 1000;
  return;
}

void __am_timer_rtc(AM_TIMER_RTC_T *rtc) {
  rtc->second = 0;
  rtc->minute = 0;
  rtc->hour   = 0;
  rtc->day    = 0;
  rtc->month  = 0;
  rtc->year   = 1900;
}

// IOE for GPU
void __am_gpu_init() {
  return;
}

void __am_gpu_config(AM_GPU_CONFIG_T *cfg) {
  uint32_t width = 0;
  uint32_t height = 0;
  NDL_OpenCanvas(&width, &height);
  *cfg = (AM_GPU_CONFIG_T) {
  .present = true, .has_accel = false,
  .width = width, .height = height,
  .vmemsz = width * height * sizeof(uint32_t)
  };
}

void __am_gpu_status(AM_GPU_STATUS_T *status) {
  status->ready = true;
}

void __am_gpu_fbdraw(AM_GPU_FBDRAW_T *ctl) {
  NDL_DrawRect((uint32_t *)ctl->pixels, ctl->x, ctl->y, ctl->w, ctl->h);
}

void __am_input_keybrd(AM_INPUT_KEYBRD_T *kbd) {
  SDL_Event ev;
  if(SDL_PollEvent(&ev) == true) {
    kbd->keydown = ev.type;
    kbd->keycode = ev.key.keysym.sym;
  }
  else kbd->keycode = NONE;
  return;
}

// Not implement below
void __am_audio_init() {

}

void __am_audio_config(AM_AUDIO_CONFIG_T *cfg) {
  cfg->present = false;
}

void __am_audio_ctrl(AM_AUDIO_CTRL_T *ctrl) {
  panic("Not implement");
}

void __am_audio_status(AM_AUDIO_STATUS_T *stat) {
  panic("Not implement");
}

void __am_audio_play(AM_AUDIO_PLAY_T *ctl) {
  panic("Not implement");
}

void __am_disk_config(AM_DISK_CONFIG_T *cfg) {
  cfg->present = false;
}

void __am_disk_status(AM_DISK_STATUS_T *stat) {
  panic("Not implement");
}

void __am_disk_blkio(AM_DISK_BLKIO_T *io) {
  panic("Not implement");
}
