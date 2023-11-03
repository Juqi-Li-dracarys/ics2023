#include <am.h>
#include <nemu.h>

#define KEYDOWN_MASK 0x8000

void __am_input_keybrd(AM_INPUT_KEYBRD_T *kbd) {
  uint32_t read_data = inl(KBD_ADDR);
  kbd->keydown = (read_data & KEYDOWN_MASK ? true : false);
  kbd->keycode = read_data & ~KEYDOWN_MASK;
}
