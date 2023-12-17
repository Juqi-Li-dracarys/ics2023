#include <unistd.h>
#include <stdio.h>
#include <NDL.h>
#include <stdint.h>

int main() {
  NDL_Init(0);
  uint32_t last_time = NDL_GetTicks();
  uint32_t now_time = NDL_GetTicks();
  while(now_time < 10000) {
    now_time = NDL_GetTicks();
    if(now_time - last_time >= 500) {
      printf("hello word @ %d ms.\n", now_time);
      last_time = now_time;
    }
  }
  NDL_Quit();
  return 0;
}
