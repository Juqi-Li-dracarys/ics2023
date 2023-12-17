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

// virtual file system

size_t serial_write(const void *buf, size_t offset, size_t len) {
  char *ptr = (char *)buf;
  for(int i = 0; i < len; i++) {
    putch(ptr[i]);
  }
  return len;
}

size_t events_read(void *buf, size_t offset, size_t len) {
  if(io_read(AM_INPUT_CONFIG).present == true) {
    AM_INPUT_KEYBRD_T ev = io_read(AM_INPUT_KEYBRD);
    if(ev.keycode == AM_KEY_NONE) return 0;
    else {
      if(ev.keydown) {
        return snprintf((char *)buf, len, "kd: %s\n", keyname[ev.keycode]);
      }
      else {
        return snprintf((char *)buf, len, "ku: %s\n", keyname[ev.keycode]);
      }
    }
  }
  else return 0;
}

size_t dispinfo_read(void *buf, size_t offset, size_t len) {
  if(io_read(AM_GPU_CONFIG).present == true) {
    return snprintf((char *)buf, len, "WIDTH:%d\nHEIGHT:%d\n", io_read(AM_GPU_CONFIG).height, io_read(AM_GPU_CONFIG).width);
  }
  return 0;
}

size_t fb_write(const void *buf, size_t offset, size_t len) {
  return 0;
}

void init_device() {
  Log("Initializing devices...");
  ioe_init();
}
