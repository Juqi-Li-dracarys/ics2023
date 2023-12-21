
// Rewrite AM IOE in navy API

#include <ioe.h>

# define NONE 0

// screen size
static uint32_t width = 0;
static uint32_t height = 0;
static SDL_Surface screen = {0};


static void surface_init(SDL_Surface *s, void *pix, size_t w, size_t h) {
  if(s && pix) {
    s->w = w;
    s->h = h;
    s->pixels = pix;
    s->format->BitsPerPixel = 32;
    s->format-> palette = NULL;
    return;
  }
  else panic("NULL ptr.");
}

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
  if(width == 0 && height == 0) {
    NDL_OpenCanvas(&width, &height);
    printf("ok1");
    void *buf = malloc(sizeof(uint32_t) * height * width);
    printf("ok2");
    surface_init(&screen, buf, width, height);
    printf("ok0");
  }
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
  if(ctl->sync == true || ctl->pixels == NULL) {
    SDL_UpdateRect(&screen, 0, 0, 0, 0);
    return;
  }
  else {
    SDL_Surface temp;
    SDL_Rect dstrect;
    dstrect.x = ctl->x;
    dstrect.y = ctl->y;
    surface_init(&temp, ctl->pixels, ctl->w, ctl->h);
    SDL_BlitSurface(&temp, NULL, &screen, &dstrect);
    
  }
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
