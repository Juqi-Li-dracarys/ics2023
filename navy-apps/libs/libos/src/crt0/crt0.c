#include <stdint.h>
#include <stdlib.h>
#include <assert.h>
#include <string.h>

int main(int argc, char *argv[], char *envp[]);

extern char **environ;

char *empety[1] = {NULL}; 

void call_main(uintptr_t *args) {
//   int argc = (int)args[0];
//   int envc = (int)args[argc + 2];
//   char **argv = (char **)(args + 1);

//   // Do not need this arg
//   // char **envp = (char **)(args + argc + 3);

//   environ = empety;
//   exit(main(argc, argv, empety));


 
 exit(main(0, NULL, NULL));

  assert(0);
}
