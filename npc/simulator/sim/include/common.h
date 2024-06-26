#ifndef __COMMON_H__
#define __COMMON_H__

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <assert.h>
#include <generated/autoconf.h>
#include <macro.h>

#define MAX_SIM_TIME 40000000

typedef uint64_t word_t;
typedef int64_t sword_t;
typedef unsigned long long duword_t;
typedef long long dsword_t;

#define FMT_WORD "0x%016lx"

typedef word_t vaddr_t;
typedef word_t paddr_t;
#define FMT_PADDR "0x%016lx"
typedef uint16_t ioaddr_t;

extern word_t *cpu_gpr;

#define PAGE_SHIFT        12
#define PAGE_SIZE         (1ul << PAGE_SHIFT)
#define PAGE_MASK         (PAGE_SIZE - 1)

typedef struct {
  int state;
  vaddr_t halt_pc;
  word_t halt_ret;
} SimState;

typedef struct {
    word_t mepc;
    word_t mstatus;
    word_t mcause;
    word_t mtvec;
} CSR;


typedef struct {
    word_t gpr[32];
    vaddr_t pc;
    CSR csr;
} CPU_state;


typedef struct log{
  word_t pc;
  word_t inst;
#ifdef CONFIG_ITRACE
  char buf [100];
#endif
} inst_log;

extern CPU_state sim_cpu;

enum { SIM_RUNNING, SIM_STOP, SIM_END, SIM_ABORT, SIM_QUIT };

extern SimState sim_state;

void init_mem();
uint8_t* guest_to_host(paddr_t paddr);
paddr_t host_to_guest(uint8_t *haddr);

void init_sdb();

// rtl
void single_cycle();
void reset(int n);
void set_state();
bool signal_detect();

// device
void init_device(const char *diskpath);

// memory
word_t paddr_read(paddr_t addr, int len);
void paddr_write(paddr_t addr, int len, word_t data);
word_t host_read(void *addr, int len);
void host_write(void *addr, int len, word_t data);

paddr_t host_to_guest(uint8_t *haddr);
uint8_t* guest_to_host(paddr_t paddr);


// halt
bool test_break();

// sdb
void sdb_mainloop();
void cpu_exec(unsigned int n);
void cpu_exec_clk(unsigned int n);
void isa_reg_display();
word_t isa_reg_str2val(const char *s, bool *success);

// difftest
void init_difftest(char *ref_so_file, long img_size, int port);
void difftest_skip_ref();
void difftest_sync();

// mmio
word_t mmio_read(paddr_t addr, int len);
void mmio_write(paddr_t addr, int len, word_t data);

// timer
uint64_t get_time();
struct tm *get_time_tm();

// monitor
void init_monitor(int argc, char *argv[]);

// log
void init_log(const char *log_file);

bool is_exit_status_bad();

#endif

