/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-03-09 15:21:33 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-03-09 15:46:36
 */


#include <assert.h>
#include <common.h>
#include <debug.h>

extern inst_log *log_ptr;

// the physical memory of our simulator

uint8_t flash [CONFIG_FLASH_SIZE];

// check if the addr is valid

static inline bool in_flash(paddr_t addr) {
    return (addr >= CONFIG_FLASH_BASE) && (addr < (paddr_t)CONFIG_FLASH_BASE + CONFIG_FLASH_SIZE);
}

// print a log when addr is out of bound
static void out_of_bound(paddr_t addr) {
  printf("address = " FMT_PADDR " is out of bound of rom [" FMT_PADDR ", " FMT_PADDR ") at pc = " FMT_WORD "\n",
      addr, CONFIG_FLASH_BASE, CONFIG_FLASH_BASE + CONFIG_FLASH_SIZE, addr);
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
  *data = *(uint32_t *)(flash + bit_align_32(addr));
  return;
}

extern "C" void mrom_read(int addr, int *data) {
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
#ifdef CONFIG_MTRACE_COND
    if (MTRACE_COND) {log_write("MTRACE: 0x%08x\t read %d byte 0x%08x in mem: 0x%08x\n", log_ptr->pc, len, r_data, addr);}
#endif
  return r_data;
}

void init_mem() {
  // for(int i = 0; i < 100; i++) {
  //   flash[i] = i;
  // }
  return;
}


