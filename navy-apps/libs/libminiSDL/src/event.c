#include <NDL.h>
#include <SDL.h>
#include <string.h>
#include <assert.h>

#define keyname(k) #k,

static const char *keyname[] = {
  "NONE",
  _KEYS(keyname)
};

// parsing event
static char type = 0;
static char name[10] = {0};
static char buf[15] = {0};

int SDL_PushEvent(SDL_Event *ev) {
  return 0;
}

int SDL_PollEvent(SDL_Event *ev) {
  if (NDL_PollEvent(buf, sizeof(buf))) {
    // parsing the event
    assert(ev);
    sscanf(buf, "%c %s\n", &type, name);
    if (type == 'd')
      ev->type = SDL_KEYDOWN;
    else
      ev->type = SDL_KEYUP;
    for (int i = 0; i < sizeof(keyname) / sizeof(char *); i++) {
      if (strcmp(name, keyname[i]) == 0) {
        ev->key.keysym.sym = i;
        return 1;
      }
    }
    // parsing fail
    return -1;
  }
  return 0;
}

int SDL_WaitEvent(SDL_Event* event) {
  assert(event);
  int ret = 0;
  while (1) {
    // success
    if((ret = SDL_PollEvent(event)) == 1)
      return 1;
    // fail
    else if(ret == -1)
      return 0;
    else continue;
  }
}

int SDL_PeepEvents(SDL_Event *ev, int numevents, int action, uint32_t mask) {
  return 0;
}

uint8_t* SDL_GetKeyState(int *numkeys) {
  return NULL;
}
