#include <unistd.h>
#include <stdio.h>
#include <sys/time.h>


int main() {
  struct timeval tv = {0};
  gettimeofday(&tv, NULL);
  int last_time = tv.tv_sec;
  while(1) {
    gettimeofday(&tv, NULL);
    if(tv.tv_sec - last_time >= 1) {
      printf("fuck me");
      last_time = tv.tv_sec;
    }
  }
  return 0;
}
