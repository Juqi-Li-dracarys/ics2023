
#include <device/map.h>
#include <stdbool.h>
#include <debug.h>

#define CH_OFFSET 0

static uint8_t *serial_base = NULL;

static void serial_putc(char ch) {
  putc(ch, stderr);
}

static void serial_io_handler(uint32_t offset, int len, bool is_write) {
  if (is_write) serial_putc(serial_base[0]);
  return;
}

void init_serial() {
  serial_base = new_space(8);
  add_mmio_map("serial", CONFIG_SERIAL_MMIO, serial_base, 8, serial_io_handler);
}
