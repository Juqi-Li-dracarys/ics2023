#include <stdint.h>
#include <stdlib.h>
#include <assert.h>

int main(int argc, char *argv[], char *envp[]);

extern char **environ;

void call_main(uintptr_t *args) {
  // int argc = (int)args[0];
  // char **argv = (char **)(args + 1);
  // char **envp = (char **)(args + argc + 1);
  int argc = 0;
  char **argv = NULL;
  char **envp = NULL;
  environ = envp;
  exit(main(argc, argv, envp));
  assert(0);
}
