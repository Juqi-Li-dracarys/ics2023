/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-01-18 22:25:38 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-01-18 22:29:28
 */

#include <am.h>
#include <npc.h>

#define KEYDOWN_MASK 0x8000

void __am_input_keybrd(AM_INPUT_KEYBRD_T *kbd) {
  uint32_t data = inl(KBD_ADDR);
  kbd->keydown = (data & (uint32_t)KEYDOWN_MASK ? true : false);
  kbd->keycode = data & ~(uint32_t)KEYDOWN_MASK;
}
