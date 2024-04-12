#include "device/map.h"
#include <stdbool.h>
#include <time.h>
static uint32_t *rtc_port_base = NULL;

static void rtc_io_handler(paddr_t offset, int len, bool is_write) {
  assert(!is_write);
  uint64_t us = get_time();
  struct tm* rtc = get_time_tm();
  rtc_port_base[0] = (uint32_t)us;
  rtc_port_base[1] = us >> 32;
}

void init_timer() {
  rtc_port_base = (uint32_t *)new_space(8);
  add_mmio_map("rtc", CONFIG_RTC_MMIO, rtc_port_base, 8, rtc_io_handler);
}
