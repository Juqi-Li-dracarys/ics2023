#include <unistd.h>
#include <stdio.h>
#include <sys/time.h>
#include <stdint.h>

int main() {
  struct timeval tv = {0};
  gettimeofday(&tv, NULL);
  uint64_t last_time = tv.tv_sec;
  printf("%d\n", (uint32_t)(last_time / 1000000));
  while(1) {
    gettimeofday(&tv, NULL);
    if(tv.tv_sec - last_time >= 2) {
      printf("fuck me\n");
      last_time = tv.tv_sec;
    }
  }
  return 0;
}
