/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-01-16 11:00:24 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-03-09 17:37:41
 */

#include <dlfcn.h>
#include <common.h>
#include <debug.h>
#include <trace.h>
#include <reg.h>


extern inst_log *log_ptr;

enum { DIFFTEST_TO_DUT, DIFFTEST_TO_REF };
// the size of registers that should be checked in difftest, 32 gpr, 1 pc, 4 csr
#define DIFFTEST_REG_SIZE (sizeof(word_t) * (16 + 1 + 4))

// init fuction pointer with NULL, they will be assign when init
void (*difftest_regcpy)(void *dut, bool direction) = NULL;
void (*difftest_memcpy)(paddr_t addr, void *buf, size_t n, bool direction) = NULL;
void (*difftest_exec)(uint64_t n) = NULL;
void (*difftest_raise_intr)(uint64_t NO) = NULL;


// should skip difftest 
static bool is_skip_ref = false;
// the num of instruction that should be skipped
static int skip_dut_nr_inst = 0;

// skip in the next cycle
static bool is_skip_next = false;


#ifdef CONFIG_DIFFTEST 

extern uint8_t pmem     [CONFIG_MSIZE];
static uint8_t ref_pmem [CONFIG_MSIZE];

// this is used to let ref skip instructions which
// can not produce consistent behavior with npc simulator
// we use it when we read device memory 
void difftest_skip_ref() {
  is_skip_ref = true;
  skip_dut_nr_inst = 0;
}

// Do not consider it in npc simulator
// since we use nemu as ref
void difftest_skip_dut(int nr_ref, int nr_dut) {
  skip_dut_nr_inst += nr_dut;
  while (nr_ref -- > 0) {
    difftest_exec(1);
  }
}

void init_difftest(char *ref_so_file, long img_size, int port) {

  // ref_so_file is the nemu lib
  assert(ref_so_file != NULL);

  void *handle;
  Log("open dl: %s", ref_so_file);
  // open nemu lib, and link the difftest functions, they are implemented in nemu dir
  handle = dlopen(ref_so_file, RTLD_LAZY);
  assert(handle);

  difftest_memcpy = (void (*)(paddr_t, void *, size_t, bool))dlsym(handle, "difftest_memcpy");
  assert(difftest_memcpy);

  difftest_regcpy = (void (*)(void *, bool))dlsym(handle, "difftest_regcpy");
  assert(difftest_regcpy);

  difftest_exec = (void (*)(uint64_t))dlsym(handle, "difftest_exec");
  assert(difftest_exec);

  void (*difftest_init)(int) = (void (*)(int))dlsym(handle, "difftest_init");
  assert(difftest_init);

  Log("Differential testing: %s", ANSI_FMT("ON", ANSI_FG_GREEN));

  // init difftest
  difftest_init(port);
  // copy register
  difftest_regcpy(&sim_cpu, DIFFTEST_TO_REF);
  // copy the memory, the registers, the pc to nemu, so our cpu and nemu can run with the same initial state
  difftest_memcpy(CONFIG_MBASE, guest_to_host(CONFIG_MBASE), CONFIG_MSIZE, DIFFTEST_TO_REF);
}

// copy our registers to nemu
void difftest_sync() {
  difftest_regcpy(&sim_cpu, DIFFTEST_TO_REF);
}


// check the registers with nemu
bool isa_difftest_checkregs(CPU_state *ref_r, vaddr_t pc) {
    
  word_t *ref_csr_ptr = (word_t *)&(ref_r->csr);

  for(int i = 0; i < MUXDEF(CONFIG_RVE, 16, 32); i++) {
    if(ref_r->gpr[i] != (sim_cpu.gpr[check_reg_idx(i)])) {
      printf("difftest fail @PC = 0x%016lx, due to wrong gpr reg[%d].\n", pc, i);
      puts("REF register map:");
      for(int j = 0; j < MUXDEF(CONFIG_RVE, 16, 32); j++) {
        printf("%s:0X%016lx ",regs[j], ref_r->gpr[j]);
        if((j + 1) % 4 == 0)
            putchar('\n');
      }
      return false;
    }
  }

 for(int i = 0; i < 4; i++) {
    if(ref_csr_ptr[i] != csr(i)) {
      printf("difftest fail @PC = 0x%016lx, due to wrong csr reg[%d].\n", pc, i);
      puts("REF register map:");
      for(int j = 0; j < 4; j++) {
        printf("%s:0X%016lx ",regs[j + MUXDEF(CONFIG_RVE, 16, 32)], ref_csr_ptr[j]);
        if((j + 1) % 4 == 0)
            putchar('\n');
      }
      return false;
    }
  }

  if(ref_r->pc != pc) {
    printf("difftest fail @PC = 0x%08lx, due to wrong PC.\n", pc);
    printf("REF PC = 0x%08lx\n", ref_r->pc);
    return false;
  }
  else {
    return true;
  }
}

// check mem， use it carefully
bool isa_difftest_checkmem(uint8_t *ref_pmem, vaddr_t pc) {
  for (uint32_t i = 0; i < CONFIG_MSIZE; i++){
    if (ref_pmem[i] != pmem[i]) {
      printf("memory of NPC is wrong before executing instruction at pc = " FMT_WORD
        ", mem[%08x] right = " "%08x" ", wrong = " "%08x" "\n", sim_cpu.pc, i, ref_pmem[i], pmem[i]); 
      return false;
    }
  }
  return true;
}


static void checkregs(CPU_state *ref, vaddr_t pc) {
  if (!isa_difftest_checkregs(ref, pc)) {
    sim_state.state = SIM_ABORT;
    sim_state.halt_pc = pc;
    isa_reg_display();
    IFDEF(CONFIG_ITRACE, print_ring_buffer(ring_head));
    IFDEF(CONFIG_FTRACE, ftrace_log_d());
  }
}

static void checkmem(uint8_t *ref_pmem, vaddr_t pc) {
  if (!isa_difftest_checkmem(ref_pmem, pc)) {
    sim_state.state = SIM_ABORT;
    sim_state.halt_pc = pc;
    isa_reg_display();
    IFDEF(CONFIG_ITRACE, print_ring_buffer(ring_head));
    IFDEF(CONFIG_FTRACE, ftrace_log_d());
  }
}

void difftest_step(bool interrupt) {
  CPU_state ref_r;
  // we should jump diff here
  if(is_skip_next) {
    is_skip_next = is_skip_ref;
    difftest_sync();
    return;
  }
  difftest_exec(1);
  difftest_regcpy(&ref_r, DIFFTEST_TO_DUT);
  difftest_memcpy(CONFIG_MBASE, ref_pmem, CONFIG_MSIZE, DIFFTEST_TO_DUT);

  if(!interrupt) {
    checkregs(&ref_r, sim_cpu.pc);
    checkmem(ref_pmem, sim_cpu.pc);
  }
  if(is_skip_ref) {
    is_skip_ref = false;
    is_skip_next = true;
  }
  return;
}

#else

void init_difftest(char *ref_so_file, long img_size, int port) {
    Log("Differential testing: %s", ANSI_FMT("OFF", ANSI_FG_RED));
}


void difftest_skip_ref() {

}

void difftest_skip_dut(int nr_ref, int nr_dut) {

}
#endif