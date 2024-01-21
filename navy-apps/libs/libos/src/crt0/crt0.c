#include <stdint.h>
#include <stdlib.h>
#include <assert.h>

int main(int argc, char *argv[], char *envp[]);

extern char **environ;

void call_main(uintptr_t *args) {


  // int argc = *((int *)args);
  // char **pargs = (char **)args + 1;
  // char **argv = pargs;
  // while (*pargs != NULL)
  //   pargs++;
  // pargs += 1;
  // char **envp = (char **)pargs;
  // environ = envp;


  exit(main(0, NULL, NULL));
  assert(0);
}
