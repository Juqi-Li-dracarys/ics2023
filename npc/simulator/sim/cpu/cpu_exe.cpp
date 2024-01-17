/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-01-17 09:39:10 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-01-17 11:53:58
 */

#include <bits/stdc++.h>
#include <debug.h>
#include <common.h>
#include <disasm.h>
#include <memory.h>
#include <sim.h>

using namespace std;

extern VCPU_TOP *dut;
extern uint64_t sim_time;
extern VerilatedVcdC *m_trace;
extern VerilatedContext* contextp;
extern uint8_t pmem[];

void print_itrace();
void difftest_step();
void device_update();

static const char *regs[] = {
  "$0", "ra", "sp", "gp", "tp", "t0", "t1", "t2",
  "s0", "s1", "a0", "a1", "a2", "a3", "a4", "a5"
};


// Lab2 HINT: instruction log struct for instruction trace
struct inst_log{
  word_t pc;
  word_t inst;
};

// reg dpi-c
uint32_t *cpu_gpr = NULL;
uint32_t *cpu_mstatus = NULL, *cpu_mtvec = NULL, *cpu_mepc = NULL, *cpu_mcause = NULL;

// init the running state of our simulator
SimState sim_state = { .state = SIM_STOP };

// num of executed instruction
uint64_t g_nr_guest_inst = 0;

// time spend
static uint64_t g_timer = 0; // unit: us

bool npc_cpu_uncache_pre = 0;

// load the state of your simulated cpu into sim_cpu
void set_state() {
  sim_cpu.pc = dut->pc_cur;
  memcpy(&sim_cpu.gpr[0], cpu_gpr, sizeof(uint32_t) * 16);
  // // Lab4 TODO: set the state of csr to sim_cpu
}

// just give a single posedge clk
void single_cycle() {
  dut->clk = 1;
  dut->eval();
  m_trace->dump(contextp->time()); // dump wave
  contextp->timeInc(5);            // 推动仿真时间

  dut->clk = 0;
  dut->eval();
  m_trace->dump(contextp->time()); // dump wave
  contextp->timeInc(5);            // 推动仿真时间
  set_state();
}

// reset the cpu
void reset(int n) {
  dut->clk = 0;
  dut->rst = 1;
  dut->eval();
  m_trace->dump(contextp->time()); // dump wave
  contextp->timeInc(5);            // 推动仿真时间
  while (n-- > 0) {
    single_cycle();
  }
  dut->rst = 0;
  dut->clk = 0;
  dut->eval();
  m_trace->dump(contextp->time()); // dump wave
  contextp->timeInc(5);            // 推动仿真时间
}

// check if the program should end
bool signal_detect() {

  if(dut->inst_signal == 1) {
    Log("Inst Error detect, stop simulation.");
    sim_state.state = SIM_ABORT;
    dut->final();
    return true;
  }

  else if(dut->reg_signal) {
    Log("Reg Error detect, stop simulation.");
    sim_state.state = SIM_ABORT;
    dut->final();
    return true;
  }

  else if(dut->ALU_signal) {
    Log("ALU Error detect, stop simulation.");
    sim_state.state = SIM_ABORT;
    dut->final();
    return true;
  }

  else if(dut->inst_signal == 2) {
    Log("ebreak detect, stop simulation.");
    sim_state.state = SIM_STOP;
    dut->final();
    return true;
  }

  else return false;
}

static void statistic() {
#define NUMBERIC_FMT MUXDEF(CONFIG_TARGET_AM, "%", "%'") PRIu64
  Log("host time spent = " NUMBERIC_FMT " us", g_timer);
  Log("total guest instructions = " NUMBERIC_FMT, g_nr_guest_inst);
  if (g_timer > 0) Log("simulation frequency = " NUMBERIC_FMT " inst/s", g_nr_guest_inst * 1000000 / g_timer);
  else Log("Finish running in less than 1 us and can not calculate the simulation frequency");
}

void excute(uint64_t n) {
  
  while (n--) {

    // if (dut->commit_wb) {
    //   if(npc_cpu_uncache_pre){
    //     difftest_sync();
    //   }
    //   // Lab3 TODO: use difftest_step function here to execute difftest
      
    //   g_nr_guest_inst++;
    //   npc_cpu_uncache_pre = dut->uncache_read_wb;
    // }

    // your cpu step a cycle
    single_cycle();

#ifdef DEVICE
    device_update();
#endif

    if(signal_detect() || sim_state.state != SIM_RUNNING) {
      // save the end state
      sim_state.halt_pc = dut->pc_cur;
      sim_state.halt_ret = cpu_gpr[10];
      break;
    }
  }
}

// execute n instructions
void cpu_exec(unsigned int n){
  
  std::cout << sim_state.state << std::endl;

  switch (sim_state.state) {
    case SIM_END: case SIM_ABORT: case SIM_QUIT:
      printf("Program execution has ended. To restart the program, exit NPC and run again.\n");
      return;
    default: sim_state.state = SIM_RUNNING;
  }
  
  // Lab2 TODO: implement instruction trace for your cpu

  uint64_t timer_start = get_time();
  excute(n);
  uint64_t timer_end = get_time();
  g_timer += timer_end - timer_start;

  switch (sim_state.state) {
    case SIM_RUNNING: sim_state.state = SIM_STOP; break;
    case SIM_END: case SIM_ABORT:
      Log("sim: %s at pc = " FMT_WORD,
          (sim_state.state == SIM_ABORT ? ANSI_FMT("ABORT", ANSI_FG_RED) :
           (sim_state.halt_ret == 0 ? ANSI_FMT("HIT GOOD TRAP", ANSI_FG_GREEN) :
            ANSI_FMT("HIT BAD TRAP", ANSI_FG_RED))),
          sim_state.halt_pc);
      // fall through
    case SIM_QUIT: statistic();
  }
}

// map the name of reg to its value
word_t isa_reg_str2val(const char *s, bool *success) {;
  if(!strcmp(s, "pc")){
    *success = true;
    return dut->pc_cur;
  }
  for(int i = 0; i < 16; i++){
    if(!strcmp(s, regs[i])){
      *success = true;
      return cpu_gpr[i];
    }
  }
  *success = false;
  return 0;
}

// set cpu_gpr point to your cpu's gpr
extern "C" void set_gpr_ptr(const svOpenArrayHandle r) {
  cpu_gpr = (uint32_t *)(((VerilatedDpiOpenVar*)r)->datap());
}
// set the pointers pint to you cpu's csr
extern "C" void set_csr_ptr(const svOpenArrayHandle mstatus, const svOpenArrayHandle mtvec, const svOpenArrayHandle mepc, const svOpenArrayHandle mcause) {
  cpu_mstatus = (uint32_t *)(((VerilatedDpiOpenVar*)mstatus)->datap());
  cpu_mtvec = (uint32_t *)(((VerilatedDpiOpenVar*)mtvec)->datap());
  cpu_mepc = (uint32_t *)(((VerilatedDpiOpenVar*)mepc)->datap());
  cpu_mcause = (uint32_t *)(((VerilatedDpiOpenVar*)mcause)->datap());
}

void isa_reg_display() {
  for (int i = 0; i < 16; i++) {
    printf("gpr[%d](%s) = 0x%x\n", i, regs[i], cpu_gpr[i]);
  }
}

void print_itrace() {
  // Lab2 HINT: you can implement this function to help you print the instruction trace
}