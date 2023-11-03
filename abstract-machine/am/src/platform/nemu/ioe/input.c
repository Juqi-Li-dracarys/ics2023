#include <am.h>
#include <nemu.h>

#define KEYDOWN_MASK 0x8000

void __am_input_keybrd(AM_INPUT_KEYBRD_T *kbd) {
  uint32_t read_data = inl(KBD_ADDR);
  kbd->keydown = (bool)(read_data & (uint32_t)0x00008000);
  kbd->keycode = read_data;
}
