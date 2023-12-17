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
  char buf[15] = {0};
  sprintf(buf, 15, "%d\n", 0x80000000);
  printf("%s", buf);
  snprintf(buf, 15, "%d\n", -2147483648);
  printf("%s", buf);
  printf("%d\n", -2147483648);
  return 0;
}
