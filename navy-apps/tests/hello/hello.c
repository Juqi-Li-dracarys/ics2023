#include <unistd.h>
#include <stdio.h>

int main(int argc, char *argv[], char *envp[]) {
  // printf("Hello\n");

  int i = 0;
  volatile int j = 0;
  while (1) {
    j ++;
    if (j == 10000) {
      j = 0;
      printf("Hello World from Navy-apps for the %dth time in APP!\n", i ++);
    }
  }
  // char buf[15] = {0};
  // sprintf(buf, "%d\n", 0x80000000);
  // printf("%s", buf);


  // printf("0x%08x\n", argc);
  // printf("%s\n", argv[0]);
  // printf("%s\n", envp[0]);
  return 0;
}
