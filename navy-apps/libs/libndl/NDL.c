#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/time.h>
#include <sys/types.h>    
#include <sys/stat.h>    
#include <fcntl.h>
#include <assert.h>

// control the canvas
#define CENTRAL 1

// FILE pointer
static int event_fp = -1;
static int info_fp = -1;
static int fb_fp = -1;

static int evtdev = -1;
static int fbdev = -1;

// 画布尺寸
static int screen_w = 0;
static int screen_h = 0;
// 画布起始坐标
static int canvas_x = 0;
static int canvas_y = 0;
// 屏幕尺寸
static int max_width = 0;
static int max_height = 0;


// return system time in ms
uint32_t NDL_GetTicks() {
  struct timeval tv = {0};
  gettimeofday(&tv, NULL);
  return (uint32_t)((uint32_t)tv.tv_sec * 1000 + (uint32_t)tv.tv_usec / 1000);
}

// open and read keyboard
int NDL_PollEvent(char *buf, int len) {
  assert(buf);
  if(event_fp == -1) {
    event_fp = open("/dev/events", 0, 0);
  }
  return (read(event_fp, buf, len)) ? 1 : 0;
}

// 打开一张 w*h 大小的画布
void NDL_OpenCanvas(int *w, int *h) {
  assert(w != NULL && h != NULL);
  if(info_fp == -1) {
    info_fp = open("/proc/dispinfo", 0, 0);
  }
  if(fb_fp == -1) {
    fb_fp = open("/dev/fb", 0, 0);
  }
  char buf[50] = {0};
  if(read(info_fp, buf, 50)) {
    sscanf(buf, "WIDTH:%d\nHEIGHT:%d\n", &max_width, &max_height);
  }
  *w = (*w <= max_width && *w > 0) ? *w : max_width;
  *h = (*h <= max_height && *h > 0) ? *h : max_height;
  // 画布大小
  screen_w = *w; 
  screen_h = *h;
  // 画布居中
#ifdef CENTRAL
  // reset the central
  canvas_x = (max_width / 2) - (screen_w / 2);
  canvas_y = (max_height / 2) - (screen_h / 2);
#endif
  printf("screen width:%d  height:%d\n", max_width, max_height);
  printf("canvas width:%d  height:%d\n", screen_w, screen_h);
  
  // ignore it for now
  if (getenv("NWM_APP")) {
    int fbctl = 4;
    fbdev = 5;
    char buf[64];
    int len = sprintf(buf, "%d %d", screen_w, screen_h);
    // let NWM resize the window and create the frame buffer
    write(fbctl, buf, len);
    while (1) {
      // 3 = evtdev
      int nread = read(3, buf, sizeof(buf) - 1);
      if (nread <= 0) continue;
      buf[nread] = '\0';
      if (strcmp(buf, "mmap ok") == 0) break;
    }
    close(fbctl);
  }
  return;
}

// 面向画布，输出图形
void NDL_DrawRect(uint32_t *pixels, int x, int y, int w, int h) {
  // 注意是以像素为单位(32 位)
  assert(pixels);
  int x_r = x + canvas_x;
  int y_r = y + canvas_y;
  int x_max = screen_w + canvas_x >= max_width ? max_width : screen_w + canvas_x;
  int y_max = screen_h + canvas_y >= max_height ? max_height : screen_h + canvas_y;
  int len = w + x_r < x_max ? w : x_max - x_r;
  for(int j = 0; j < h && y_r + j < y_max; j++) {
    // 按行写入
    lseek(fb_fp, ((y_r + j) * max_width + x_r) * 4, SEEK_SET);
    write(fb_fp, (void *)pixels, len * 4);
    pixels = pixels + len;
  }
  return;
}

void NDL_OpenAudio(int freq, int channels, int samples) {
}

void NDL_CloseAudio() {
}

int NDL_PlayAudio(void *buf, int len) {
  return 0;
}

int NDL_QueryAudio() {
  return 0;
}

int NDL_Init(uint32_t flags) {
  if (getenv("NWM_APP")) {
    evtdev = 3;
  }
  return 0;
}

void NDL_Quit() {
}
