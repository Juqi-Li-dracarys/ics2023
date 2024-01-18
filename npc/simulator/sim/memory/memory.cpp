/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-01-16 11:00:40 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-01-18 14:42:16
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


// 未定义 AXI 则用 dpi-c
#ifndef AXI

// read physical memory with read enable re, read addr raddr, read size (1 << mask), then return the value in rword

extern "C" int vaddr_ifetch(int addr, int len) {
  return paddr_read(addr, len);
}

extern "C" int vaddr_read(int addr, int len) {
  if (in_pmem(addr)) {
    return paddr_read(addr, len);
  }
  // avoid error befor cpu reset
  else if(!addr) {
    printf("Warning: detect memory-read addr = 0x0000000, if it emerges during CPU reset, just ignore it\n");
    return 0;
  }
  // if not in mem, then check mmio
  else
    return mmio_read(addr, len);
}

extern "C" void vaddr_write(int addr, int len, int data) {
  if (in_pmem(addr)) {
    paddr_write(addr, len, data);
    return;
  }
  // if not in mem, then check mmio
  else {
    mmio_write(addr, len, data);
    return;
  }
}

#else
uint32_t rstate = 0;
uint32_t araddr = 0;
uint32_t arlen = 0;
uint32_t arsize = 0;
uint32_t rcount = 0;
void pmem_read(){
  if(rstate == 0){
    dut->rlast = 0;
    dut->rvalid = 0;
    if(dut->arvalid){
      // Lab5 TODO: implement the read request
    }
  }
  else if(rstate == 1) {
    // Lab5 TODO: implement the read data
  }
}
uint32_t awaddr = 0;
uint32_t awlen = 0;
uint32_t awsize = 0;
uint32_t wstate = 0;
uint32_t wcount = 0;
void pmem_write(){
  if(wstate == 0){
    dut->bvalid = 0;
    if(dut->awvalid == 1){
      awaddr = dut->awaddr;
      assert(awaddr >= 0x80000000);
      awlen = dut->awlen;
      awsize = 1 << dut->awsize;
      wstate = 1;
      dut->awready = 1;
      wcount = 0;
    }
  }
  else if(wstate == 1){
    dut->awready = 0;
    if(dut->wvalid){
      uint32_t wdata = (dut->wdata) >> (8 * (awaddr % 4));
      uint32_t byte_addr = awaddr + wcount * awsize;
      uint32_t wstrb = dut->wstrb;
      uint32_t wlen = 0;
      while(wstrb){
        wlen++;
        wstrb &= (wstrb - 1);
      }
      in_pmem(awaddr) ? host_write(guest_to_host(byte_addr), wlen, wdata) : mmio_write(byte_addr, wlen, wdata);
      dut->wready = 1;
      wcount++;
      wstate = dut->wlast ? 2 : 1;
    }
  }
  else if(wstate == 2){
    dut->wready = 0;
    dut->awready = 0;
    dut->bvalid = 1;
    wstate = dut->bready ? 0 : 2;
  }
}
#endif

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


