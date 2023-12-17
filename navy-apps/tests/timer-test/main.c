#include <unistd.h>
#include <stdio.h>
#include <sys/time.h>


int main() {
  struct timeval tv = {0};
  gettimeofday(&tv, NULL);
  int last_time = tv.tv_usec;
  printf("%d\n", last_time);
  while(1) {
    gettimeofday(&tv, NULL);
    if(tv.tv_usec - last_time >= 100000) {
      printf("fuck me\n");
      last_time = tv.tv_usec;
    }
  }
  return 0;
}
