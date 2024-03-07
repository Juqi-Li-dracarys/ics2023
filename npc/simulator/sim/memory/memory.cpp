/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-01-16 11:00:40 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-03-08 00:30:39
 */

#include <assert.h>
#include <common.h>
#include <sim.h>
#include <debug.h>

extern inst_log *log_ptr;

// the physical memory of our simulator
uint8_t pmem[CONFIG_MSIZE];

// check if the addr is valid
static inline bool in_pmem(paddr_t addr) {
    return (addr >= CONFIG_MBASE) && (addr < (paddr_t)CONFIG_MBASE + CONFIG_MSIZE);
}

// print a log when addr is out of bound
static void out_of_bound(paddr_t addr) {
  printf("address = " FMT_PADDR " is out of bound of pmem [" FMT_PADDR ", " FMT_PADDR ") at pc = " FMT_WORD "\n",
      addr, CONFIG_MBASE, CONFIG_MBASE + CONFIG_MSIZE, addr);
}

// map the addr in riscv code to the addr in our host
uint8_t* guest_to_host(paddr_t paddr) { return pmem + paddr - CONFIG_MBASE; }

// map the addr in our host to the addr in riscv code
paddr_t host_to_guest(uint8_t *haddr) { return haddr - pmem + CONFIG_MBASE; }



// DIP-C interface for SoC
extern "C" void flash_read(int addr, int *data) { 
  assert(0); 
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

// give addr in host, write value
void host_write(void *addr, int len, word_t data) {
  switch (len) {
    case 1: *(uint8_t  *)addr = data; return;
    case 2: *(uint16_t *)addr = data; return;
    case 4: *(uint32_t *)addr = data; return;
    case 8: *(uint64_t *)addr = data; return;
    default: assert(0);
  }
}

// read with addr in riscv code, without mmio
word_t paddr_read(paddr_t addr, int len) {
  word_t r_data;
  if (in_pmem(addr))  
    r_data = host_read(guest_to_host(addr), len);
  else 
    out_of_bound(addr);
#ifdef CONFIG_MTRACE_COND
    if (MTRACE_COND) {log_write("MTRACE: 0x%08x\t read %d byte 0x%08x in mem: 0x%08x\n", log_ptr->pc, len, r_data, addr);}
#endif
  return r_data;
}

// write with addr in riscv code, without mmio
void paddr_write(paddr_t addr, int len, word_t data) {
  #ifdef CONFIG_MTRACE_COND
    if (MTRACE_COND) {log_write("MTRACE: 0x%08x\t write %d byte 0x%08x in mem: 0x%08x\n", log_ptr->pc, len, data, addr);}
  #endif
  if (in_pmem(addr)) { host_write(guest_to_host(addr), len, data); return; }
  out_of_bound(addr);
}


