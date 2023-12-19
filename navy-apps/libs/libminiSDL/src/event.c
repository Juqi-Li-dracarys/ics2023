#include <NDL.h>
#include <SDL.h>
#include <string.h>

#define keyname(k) #k,

static const char *keyname[] = {
  "NONE",
  _KEYS(keyname)
};

int SDL_PushEvent(SDL_Event *ev) {
  return 0;
}

int SDL_PollEvent(SDL_Event *ev) {
  return 0;
}

int SDL_WaitEvent(SDL_Event* event) {
  char type = 0;
  char buf[15] = { 0 };
  char name[10] = { 0 };
  while (1) {
    if (NDL_PollEvent(buf, sizeof(buf))) {
      // parsing the event
      sscanf(buf, "%c %s\n", &type, name);
      printf("%c\n%s\n", type, name);
      if (type == 'd')
        event->type = SDL_KEYDOWN;
      else
        event->type = SDL_KEYUP;
      for (int i = 0; i < sizeof(keyname) / sizeof(char*); i++) {
        if (strcmp(name, keyname[i]) == 0) {
          event->key.keysym.sym = i;
          return 1;
        }
      }
      return 0;
    }
  }
}

int SDL_PeepEvents(SDL_Event *ev, int numevents, int action, uint32_t mask) {
  return 0;
}

uint8_t* SDL_GetKeyState(int *numkeys) {
  return NULL;
}
