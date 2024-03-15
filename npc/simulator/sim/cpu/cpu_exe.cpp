/*
 * @Author: Juqi Li @ NJU
 * @Date: 2024-01-17 09:39:10
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-03-09 17:42:24
 */

#include <bits/stdc++.h>
#include <debug.h>
#include <common.h>
#include <disasm.h>
#include <sim.h>
#include <trace.h>

using namespace std;

#define MAX_INST_TO_PRINT 20

extern uint8_t pmem[];

void difftest_step(bool interrupt);
void device_update();
void disassemble(char* str, int size, uint64_t pc, uint8_t* code, int nbyte);

static const char* regs[] = {
  "$0", "ra", "sp", "gp", "tp", "t0", "t1", "t2",
  "s0", "s1", "a0", "a1", "a2", "a3", "a4", "a5"
};


inst_log* log_ptr = new inst_log;

// reg dpi-c
uint32_t* cpu_gpr = NULL;
uint32_t* cpu_csr = NULL;

// init the running state of our simulator
SimState sim_state = { .state = SIM_STOP };

// num of executed instruction
uint64_t g_nr_guest_inst = 0;

// time spend
static uint64_t g_timer = 0; // unit: us

static bool g_print_step = false;

static void statistic() {
#define NUMBERIC_FMT MUXDEF(CONFIG_TARGET_AM, "%", "%'") PRIu64
  Log("host time spent = " NUMBERIC_FMT " us", g_timer);
  Log("total guest instructions = " NUMBERIC_FMT, g_nr_guest_inst);
  if (g_timer > 0) Log("simulation frequency = " NUMBERIC_FMT " inst/s", g_nr_guest_inst * 1000000 / g_timer);
  else Log("Finish running in less than 1 us and can not calculate the simulation frequency");
}


static void trace_and_difftest(inst_log* _ptr, bool interrupt) {
#ifdef CONFIG_ITRACE
  char* p = log_ptr->buf;
  p += snprintf(p, sizeof(log_ptr->buf), "ITRACE: " FMT_WORD "\t", log_ptr->pc);
  int i;
  uint8_t* inst = (uint8_t*)&(log_ptr->inst);
  for (i = 4 - 1; i >= 0; i--) {
    p += snprintf(p, 4, " %02x", inst[i]);
  }
  memset(p, ' ', 1);
  p++;
  disassemble(p, log_ptr->buf + sizeof(log_ptr->buf) - p,
    log_ptr->pc, (uint8_t*)&log_ptr->inst, 4);
#endif

  IFDEF(CONFIG_FTRACE, ftrace_process(_ptr));

#ifdef CONFIG_ITRACE_COND
  if (ITRACE_COND) { log_write("%s\n\n", _ptr->buf); }
#endif
  // Value of g_print_step is related to the times of CPU excution
  if (g_print_step) { IFDEF(CONFIG_ITRACE, puts(_ptr->buf)); }
  // record trace in ring buffer
  IFDEF(CONFIG_ITRACE, ring_head = write_ring_buffer(ring_head, _ptr->buf));
#ifdef CONFIG_WBCHECK
  if (check_wp() == true || check_bp(sim_cpu.pc) == true) {
    // To avoid OJ compile error
    IFDEF(CONFIG_ITRACE, puts(_ptr->buf));
    sim_state.state = SIM_STOP;
  }
#endif 
  IFDEF(CONFIG_DIFFTEST, difftest_step(interrupt));
}

// 先跑一次，然后一直运行，直到下一条指令到来
void run_untile_commit() {
  while (true) {
    single_cycle();
    if (CPU->inst_commit)
      break;
  }
}

// execute n instructions
void excute(uint64_t n) {
  while (n--) {
    // 流水线还未完成复位,需要跑完第一条指令
    // 以保证和 REF 同步
    if (!CPU->inst_commit) {
      run_untile_commit();
    }
    log_ptr->pc = CPU->pc_cur;
    log_ptr->inst = CPU->inst;
    run_untile_commit();
    // 保存下一条指令执行前的状态
    printf("ok1\n");
    set_state();
    printf("ok4\n");
    g_nr_guest_inst++;
    trace_and_difftest(log_ptr, false);
    printf("ok5\n");
    // 对于有异常的指令，会在下一次执行前终止程序
    if (signal_detect()) {
      // save the end state
      sim_state.halt_pc = CPU->pc_cur;
      sim_state.halt_ret = cpu_gpr[10];
      log_ptr->pc = CPU->pc_cur;
      log_ptr->inst = CPU->inst;
      g_nr_guest_inst++;
      // 异常信号，直接跳过检查
      trace_and_difftest(log_ptr, true);
      break;
    }
    if (sim_state.state != SIM_RUNNING)
      break;
  }
}

// execute n instructions
void cpu_exec(unsigned int n) {
  g_print_step = (n < MAX_INST_TO_PRINT);
  switch (sim_state.state) {
    case SIM_END: case SIM_ABORT: case SIM_QUIT:
      printf("Program execution has ended. To restart the program, exit NPC and run again.\n");
      return;
    default: sim_state.state = SIM_RUNNING;
  }
  uint64_t timer_start = get_time();
  excute(n);
  uint64_t timer_end = get_time();
  g_timer += timer_end - timer_start;

  switch (sim_state.state) {
    case SIM_RUNNING: sim_state.state = SIM_STOP; break;
    case SIM_END: case SIM_ABORT:
      Log("SoC simulator: %s at pc = " FMT_WORD,
        (sim_state.state == SIM_ABORT ? ANSI_FMT("ABORT", ANSI_FG_RED) :
          (sim_state.halt_ret == 0 ? ANSI_FMT("HIT GOOD TRAP", ANSI_FG_GREEN) :
            ANSI_FMT("HIT BAD TRAP", ANSI_FG_RED))),
        sim_state.halt_pc);
      // fall through
    case SIM_QUIT: statistic();
  }
}

// execute n clock
void cpu_exec_clk(unsigned int n) {
  while (n-- > 0) {
    single_cycle();
  }
}




