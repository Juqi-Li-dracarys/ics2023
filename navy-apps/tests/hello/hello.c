#include <unistd.h>
#include <stdio.h>

int main() {
  printf("Hello\n");
  write(1, "Hello World!\n", 13);
  int i = 0;
  volatile int j = 0;

  while (i < 5) {
    j ++;
    if (j == 10000) {
      printf("Hello World from Navy-apps for the %dth time!\n", i ++);
      j = 0;
    }
  }
  char buf[10] = {0};
  snprintf(buf, 10, "%d+++++++++\n", 0x80000000);
  printf("%s", buf);
  return 0;
}
