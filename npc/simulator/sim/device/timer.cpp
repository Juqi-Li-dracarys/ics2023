
#include <device/map.h>
#include <stdbool.h>
#include <time.h>

static uint32_t *rtc_port_base = NULL;

static void rtc_io_handler(uint32_t offset, int len, bool is_write) {
  // to avoid error
  // assert(offset == 0 || offset == 4);
  // 注意，这里 offset = 4 读高32位时不会更新
  // 防止数据重复更新
  if (!is_write && offset == 0) {
    uint64_t us = get_time();
    rtc_port_base[0] = (uint32_t)us;
    rtc_port_base[1] = us >> 32;
  }
}

void init_timer() {
  rtc_port_base = (uint32_t *)new_space(32);
  add_mmio_map("rtc", CONFIG_RTC_MMIO, rtc_port_base, 32, rtc_io_handler);
}
