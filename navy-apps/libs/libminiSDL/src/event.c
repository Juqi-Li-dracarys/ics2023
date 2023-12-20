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

static char key_map[sizeof(keyname)];

int SDL_PushEvent(SDL_Event *ev) {
  assert(0);
  return 0;
}

int SDL_PollEvent(SDL_Event *ev) {
  if (NDL_PollEvent(buf, sizeof(buf))) {
    // parsing the event
    assert(ev);
    memset(key_map, 0, sizeof(key_map));
    sscanf(buf, "%c %s\n", &type, name);
    if (type == 'd')
      ev->type = SDL_KEYDOWN;
    else
      ev->type = SDL_KEYUP;
    for (int i = 0; i < sizeof(keyname) / sizeof(char *); i++) {
      if (strcmp(name, keyname[i]) == 0) {
        ev->key.keysym.sym = i;
        key_map[i] = (ev->type == SDL_KEYDOWN) ? 1 : 0;
        return 1;
      }
    }
    // parsing fail
    assert(0);
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
    else continue;
  }
}

int SDL_PeepEvents(SDL_Event *ev, int numevents, int action, uint32_t mask) {
  assert(0);
  return 0;
}

/*

  Gets a snapshot of the current keyboard state. The current state is re‐
  turn as a pointer to an array, the size of this array  is  stored  in
  numkeys. The array is indexed by the SDLK_* symbols. A value of 1 means
  the key is pressed and a value of 0 means its not. The pointer returned
  is  a  pointer  to an internal SDL array and should not be freed by the
  caller.

*/
uint8_t* SDL_GetKeyState(int *numkeys) {
  if(numkeys != NULL) {
    *numkeys = sizeof(key_map) / sizeof(char);
  }
  return key_map;
}
