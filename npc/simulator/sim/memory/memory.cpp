/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-03-09 15:21:33 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-03-23 10:44:05
 */


#include <assert.h>
#include <common.h>
#include <debug.h>

extern inst_log *log_ptr;

// the physical memory of simulator(flash)
static uint8_t flash [CONFIG_FLASH_SIZE];

// check if the addr is valid

static inline bool in_flash(paddr_t addr) {
    return (addr < (paddr_t)CONFIG_FLASH_SIZE && addr >= 0);
}

// print a log when addr is out of bound
static void out_of_bound(paddr_t addr) {
  printf("address = " FMT_PADDR " is out of bound of rom [" FMT_PADDR ", " FMT_PADDR ") at pc = " FMT_WORD "\n",
      addr, 0, CONFIG_FLASH_SIZE, addr);
}

// map the addr in riscv code to the addr in our host
uint8_t* guest_to_host(paddr_t paddr) { return flash + paddr - CONFIG_FLASH_BASE; }

// map the addr in our host to the addr in riscv code
paddr_t host_to_guest(uint8_t *haddr) { return haddr - flash + CONFIG_FLASH_BASE; }

// 32 bit 对齐
inline int bit_align_32(int addr) {
  return addr & 0xFFFFFFFC;
}

// DIP-C interface for SoC
// 不要通过 SPI 寄存器间接访问 FLASH， 这可能会导致对齐错误
extern "C" void flash_read(int addr, int *data) {
  assert((uint32_t)addr < CONFIG_FLASH_SIZE);
  if(in_flash)
    *data = host_read(flash + bit_align_32(addr), 4);
  else 
    out_of_bound(addr);
  return;
}

extern "C" void mrom_read(int addr, int *data) {
  // mrom has been removed from SoC
  assert(0);
}

// give addr in host, return value
word_t host_read(void *addr, int len) {
  switch (len) {
    case 1: return *(uint8_t  *)addr;
    case 2: return *(uint16_t *)addr;
    case 4: return *(uint32_t *)addr;
    case 8: return *(uint64_t *)addr;
    default: assert(0);
  }
}

// read with addr in riscv code, without mmio
word_t paddr_read(paddr_t addr, int len) {
  word_t r_data;
  if (in_flash(addr))  
    r_data = host_read(guest_to_host(addr), len);
  else 
    out_of_bound(addr);
  return r_data;
}

// NOP
void init_mem() {
  return;
}


