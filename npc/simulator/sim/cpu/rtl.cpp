/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-01-17 17:44:39 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-04-12 12:30:18
 */

#include <common.h>
#include <sim.h>
#include <debug.h>
#include <reg.h>

extern uint64_t g_nr_guest_clock;

// load the state of your simulated cpu into sim_cpu
void set_state() {
  sim_cpu.pc = CPU->pc_cur;
#ifdef  CONFIG_DIFFTEST
  memcpy(&sim_cpu.gpr[0], cpu_gpr, sizeof(word_t) * MUXDEF(CONFIG_RVE, 16, 32));
  memcpy(&sim_cpu.csr, cpu_csr, sizeof(word_t) * 4);
#endif
}

// reset the cpu
void reset(int n) {
  dut->clock = 0;
  dut->reset = 1;
  dut->eval();
#ifdef WAVE_RECORD
  m_trace->dump(contextp->time()); // dump wave
  contextp->timeInc(5);            // 推动仿真时间
#endif
  while (n-- > 0) {
    single_cycle();
  }
  dut->reset = 0;
  dut->clock = 0;
  dut->eval();
#ifdef WAVE_RECORD
  m_trace->dump(contextp->time()); // dump wave
  contextp->timeInc(5);            // 推动仿真时间
#endif
  set_state();
}


// give a single posedge clock
void single_cycle() {
    dut->clock = 1;
    dut->eval();
#ifdef WAVE_RECORD
    m_trace->dump(contextp->time()); // dump wave
    contextp->timeInc(5);            // 推动仿真时间
#endif
    dut->clock = 0;
    dut->eval();
#ifdef WAVE_RECORD
    m_trace->dump(contextp->time()); // dump wave
    contextp->timeInc(5);            // 推动仿真时间
#endif
    g_nr_guest_clock++;
}


// check the sytem signal of cpu
bool signal_detect() {
  if(CPU->system_halt) {
    Log("HDL: %s, ebreak detect, stop simulation.", ANSI_FMT("System Verilog", ANSI_FG_GREEN));
    sim_state.state = SIM_END;
    dut->final();
    return true;
  }
  else if(CPU->MEM_error_signal || CPU->ARBITER_error_signal || CPU->IFU_error_signal) {
    Log("HDL: %s, Memory access Error detect, stop simulation.", ANSI_FMT("System Verilog", ANSI_FG_GREEN));
    sim_state.state = SIM_ABORT;
    dut->final();
    return true;
  }
  else
    return false;
}
