#include <unistd.h>
#include <stdio.h>

int main(int argc, char *argv[], char *envp[]) {
  // printf("Hello\n");
  // write(1, "Hello World!\n", 13);
  // int i = 0;
  // volatile int j = 0;

  // while (i < 5) {
  //   j ++;
  //   if (j == 10000) {
  //     printf("Hello World from Navy-apps for the %dth time!\n", i ++);
  //     j = 0;
  //   }
  // }
  // char buf[15] = {0};
  // sprintf(buf, "%d\n", 0x80000000);
  // printf("%s", buf);


  printf("%d\n", argc);
  printf("%s\n", argv[0]);
  return 0;
}
