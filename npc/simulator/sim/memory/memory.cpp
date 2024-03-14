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
// 从 SoC 开始，我们只关注 MROM 的代码和寄存器
// 内存已经不可访问

uint8_t mrom[CONFIG_MROM_SIZE];

uint8_t flash [CONFIG_FLASH_SIZE];

// check if the addr is valid
static inline bool in_mrom(paddr_t addr) {
    return (addr >= CONFIG_MROM_BASE) && (addr < (paddr_t)CONFIG_MROM_BASE + CONFIG_MROM_SIZE);
}

static inline bool in_flash(paddr_t addr) {
    return (addr >= CONFIG_FLASH_BASE) && (addr < (paddr_t)CONFIG_FLASH_BASE + CONFIG_FLASH_SIZE);
}

// print a log when addr is out of bound
static void out_of_bound(paddr_t addr) {
  printf("address = " FMT_PADDR " is out of bound of rom [" FMT_PADDR ", " FMT_PADDR ") at pc = " FMT_WORD "\n",
      addr, CONFIG_MROM_BASE, CONFIG_MROM_BASE + CONFIG_MROM_SIZE, addr);
}

// map the addr in riscv code to the addr in our host
uint8_t* guest_to_host(paddr_t paddr) { return mrom + paddr - CONFIG_MROM_BASE; }

// map the addr in our host to the addr in riscv code
paddr_t host_to_guest(uint8_t *haddr) { return haddr - mrom + CONFIG_MROM_BASE; }


int bit_align_32(int addr) {
  return addr & 0xFFFFFFFC;
}

// DIP-C interface for SoC
// 暂时不能对齐，因为读地址是 SPI，永远是对其的
// 这就会导致错误
extern "C" void flash_read(int addr, int *data) { 
    *data = *(uint32_t *)(flash + addr);
  return;
}

extern "C" void mrom_read(int addr, int *data) {
  if(in_mrom(addr))
    *data = host_read(guest_to_host(bit_align_32(addr)), 4);
  else
     out_of_bound(addr);
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
  if (in_mrom(addr))  
    r_data = host_read(guest_to_host(addr), len);
  else 
    out_of_bound(addr);
#ifdef CONFIG_MTRACE_COND
    if (MTRACE_COND) {log_write("MTRACE: 0x%08x\t read %d byte 0x%08x in mem: 0x%08x\n", log_ptr->pc, len, r_data, addr);}
#endif
  return r_data;
}

void init_mem() {
  for(int i = 0; i < 100; i++) {
    flash[i] = i;
  }
  return;
}


