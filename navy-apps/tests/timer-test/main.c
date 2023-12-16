#include <unistd.h>
#include <stdio.h>
#include <sys/time.h>

struct timeval tv = {0};
struct timezone tz = {0};

int main() {

  gettimeofday(&tv, &tz);
  return 0;
}
