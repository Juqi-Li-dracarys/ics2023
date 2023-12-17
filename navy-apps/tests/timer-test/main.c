#include <unistd.h>
#include <stdio.h>
#include <sys/time.h>
#include <stdint.h>

int main() {
  struct timeval tv = {0};
  gettimeofday(&tv, NULL);
  uint64_t last_time = tv.tv_usec;
  while(1) {
    gettimeofday(&tv, NULL);
    if(tv.tv_sec - last_time >= 500000) {
      printf("hello word.\n");
      last_time = tv.tv_usec;
    }
  }
  return 0;
}
