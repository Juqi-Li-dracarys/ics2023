#include <stdbool.h>
#include <debug.h>
#include <device/map.h>
#include <stdlib.h>

#define IO_SPACE_MAX (2 * 1024 * 1024)

static uint8_t *io_space = NULL;
static uint8_t *p_space = NULL;
extern CPU_state npc_cpu;

extern inst_log *log_ptr;

// alloc use a memory space
uint8_t* new_space(int size) {
  uint8_t *p = p_space;
  // page aligned;
  size = (size + (PAGE_SIZE - 1)) & ~PAGE_MASK;
  p_space += size;
  assert(p_space - io_space < IO_SPACE_MAX);
  return p;
}

static bool w_check_bound(IOMap *map, paddr_t addr) {
  if (map == NULL || addr > map->high || addr < map->low) {
    printf("write-memory address = " FMT_PADDR " is out of bound of pmem [" FMT_PADDR ", " FMT_PADDR ") at pc = " FMT_WORD "\n",
      addr, CONFIG_MBASE, CONFIG_MBASE + CONFIG_MSIZE, log_ptr->pc);
    sim_state.state = SIM_ABORT;
    sim_state.halt_pc = log_ptr->pc;
    return false;
  } 
  return true;
}

static bool r_check_bound(IOMap *map, paddr_t addr) {
  if (map == NULL || addr > map->high || addr < map->low) {
    return false;
  } 
  return true;
}

// if have device function, call it
static void invoke_callback(io_callback_t c, paddr_t offset, int len, bool is_write) {
  if (c != NULL) { c(offset, len, is_write); }
}

void init_map() {
  io_space = (uint8_t *)malloc(IO_SPACE_MAX);
  assert(io_space);
  p_space = io_space;
}

// call the function, then read the device memory
word_t map_read(paddr_t addr, int len, IOMap *map) {
  assert(len >= 1 && len <= 8);
  if(!r_check_bound(map, addr))
    return 0;
  paddr_t offset = addr - map->low;
  invoke_callback(map->callback, offset, len, false); // prepare data to read
  word_t ret = host_read((uint8_t*)(map->space) + offset, len);
  return ret;
}

// write the device memory, then call the function
void map_write(paddr_t addr, int len, word_t data, IOMap *map) {
  assert(len >= 1 && len <= 8);
  if(!w_check_bound(map, addr)){
    return;
  }
  paddr_t offset = addr - map->low;
  host_write((uint8_t*)(map->space) + offset, len, data);
  invoke_callback(map->callback, offset, len, true);
}
