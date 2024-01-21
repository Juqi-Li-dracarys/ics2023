#include <stdint.h>
#include <stdlib.h>
#include <assert.h>
#include <string.h>

int main(int argc, char *argv[], char *envp[]);

extern char **environ;

void call_main(uintptr_t *args) {
  int argc = (int)args[0];
  int envc = (int)args[argc + 2];
  char **argv = (char **)(args + 1);
  char **envp = (char **)(args + argc + 3);
  environ = envp;
  exit(main((uint32_t)args, argv, envp));
  assert(0);
}
