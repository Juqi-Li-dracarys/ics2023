#include <unistd.h>
#include <stdio.h>
#include <sys/time.h>

struct timeval tv = {0};

int main() {

  gettimeofday(&tv, NULL);
  printf("%d\n", tv.tv_sec);
  return 0;
}
