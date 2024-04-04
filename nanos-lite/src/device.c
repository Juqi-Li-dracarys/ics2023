#include <common.h>

#if defined(MULTIPROGRAM) && !defined(TIME_SHARING)
# define MULTIPROGRAM_YIELD() yield()
#else
# define MULTIPROGRAM_YIELD()
#endif

#define NAME(key) \
  [AM_KEY_##key] = #key,

static const char *keyname[256] __attribute__((used)) = {
  [AM_KEY_NONE] = "NONE",
  AM_KEYS(NAME)
};

// screen height and width
static uint32_t max_height = 0;
static uint32_t max_width = 0;

size_t serial_write(const void *buf, size_t offset, size_t len) {
  MULTIPROGRAM_YIELD();
  assert(buf);
  char *ptr = (char *)buf;
  for(int i = 0; i < len; i++) {
    putch(ptr[i]);
  }
  return len;
}

size_t events_read(void *buf, size_t offset, size_t len) {
  assert(buf);
  if(io_read(AM_INPUT_CONFIG).present == true) {
    AM_INPUT_KEYBRD_T ev = io_read(AM_INPUT_KEYBRD);
    if(ev.keycode == AM_KEY_NONE) return 0;
    else {
      if(ev.keydown) {
        return snprintf((char *)buf, len, "kd %s\n", keyname[ev.keycode]);
      }
      else {
        return snprintf((char *)buf, len, "ku %s\n", keyname[ev.keycode]);
      }
    }
  }
  else return 0;
}

size_t dispinfo_read(void *buf, size_t offset, size_t len) {
  assert(buf);
  if(io_read(AM_GPU_CONFIG).present == true) {
    // 注意是像素单位
    max_height = io_read(AM_GPU_CONFIG).height;
    max_width = io_read(AM_GPU_CONFIG).width;
    return snprintf((char *)buf, len, "WIDTH:%d\nHEIGHT:%d\n", max_width, max_height);
  }
  return 0;
}

// 约定以像素为单位写入 GPU，全部写入后显示
// offset len 必须时 4 的倍数
// 该函数面向屏幕，而不是画布
size_t fb_write(const void* buf, size_t offset, size_t len) {
  MULTIPROGRAM_YIELD();
  assert(buf);
  // 换算成像素
  size_t pix_len = 0;
  size_t pix_offset = 0;
  size_t pix_in = 0;
  if (offset % 4 != 0 || len % 4 != 0) {
    return 0;
  }
  else {
    pix_len = len / 4;
    pix_offset = offset / 4;
  }
  uint32_t i = pix_offset % max_width;
  uint32_t j = pix_offset / max_width;

  // printf("pix_len:%d  offset:%d  x:%d  y:%d\n",pix_len, pix_offset, i, j);

  while (pix_in < pix_len && (i < max_width || j < max_height)) {
    // 需要换行
    if (i + pix_len - pix_in > max_width) {
      io_write(AM_GPU_FBDRAW, i, j, (uint32_t *)buf + pix_in, max_width - i, 1, false);
      pix_in = pix_in + max_width - i;
      i = 0; j++;
    }
    // 本行能装下
    else {
      io_write(AM_GPU_FBDRAW, i, j, (uint32_t *)buf + pix_in, pix_len - pix_in, 1, false);
      pix_in = pix_len;
    }
  }
  io_write(AM_GPU_FBDRAW, 0, 0, NULL, 0, 0, true);
  return 4 * pix_in;
}

void init_device() {
  Log("Initializing devices...");
  ioe_init();
}
