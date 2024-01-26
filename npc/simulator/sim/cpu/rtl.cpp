/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-01-17 17:44:39 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-01-17 20:32:34
 */

#include <common.h>
#include <sim.h>
#include <debug.h>
#include <reg.h>

// load the state of your simulated cpu into sim_cpu
void set_state() {
  sim_cpu.pc = dut->pc_cur;
  memcpy(&sim_cpu.gpr[0], cpu_gpr, sizeof(uint32_t) * MUXDEF(CONFIG_RVE, 16, 32));
  assert(cpu_mstatus);
  memcpy(&(sim_cpu.csr.mstatus), cpu_mstatus, sizeof(uint32_t));
  // memcpy(&sim_cpu.csr.mepc, cpu_mepc, sizeof(uint32_t));
  // memcpy(&sim_cpu.csr.mcause, cpu_mcause, sizeof(uint32_t));
  // memcpy(&sim_cpu.csr.mtvec, cpu_mtvec, sizeof(uint32_t));
}

// reset the cpu
void reset(int n) {
  dut->clk = 0;
  dut->rst = 1;
  dut->eval();
#ifdef WAVE_RECORD
  m_trace->dump(contextp->time()); // dump wave
  contextp->timeInc(5);            // 推动仿真时间
#endif
  while (n-- > 0) {
    single_cycle();
  }
  dut->rst = 0;
  dut->clk = 0;
  dut->eval();
#ifdef WAVE_RECORD
  m_trace->dump(contextp->time()); // dump wave
  contextp->timeInc(5);            // 推动仿真时间
#endif
}


// just give a single posedge clk
void single_cycle() {
  dut->clk = 1;
  dut->eval();
#ifdef WAVE_RECORD
  m_trace->dump(contextp->time()); // dump wave
  contextp->timeInc(5);            // 推动仿真时间
#endif
  dut->clk = 0;
  dut->eval();
#ifdef WAVE_RECORD
  m_trace->dump(contextp->time()); // dump wave
  contextp->timeInc(5);            // 推动仿真时间
#endif
  set_state();
}

// check if the program should end
bool signal_detect() {
  if(dut->inst_signal == 1) {
    Log("HDL: %s, Inst Error detect, stop simulation.", ANSI_FMT("System Verilog", ANSI_FG_GREEN));
    sim_state.state = SIM_ABORT;
    dut->final();
    return true;
  }
  else if(dut->reg_signal) {
    Log("HDL: %s, Reg Error detect, stop simulation.", ANSI_FMT("System Verilog", ANSI_FG_GREEN));
    sim_state.state = SIM_ABORT;
    dut->final();
    return true;
  }
  else if(dut->ALU_signal) {
    Log("HDL: %s, ALU Error detect, stop simulation.", ANSI_FMT("System Verilog", ANSI_FG_GREEN));
    sim_state.state = SIM_ABORT;
    dut->final();
    return true;
  }
  else if(dut->inst_signal == 2) {
    Log("HDL: %s, ebreak detect, stop simulation.", ANSI_FMT("System Verilog", ANSI_FG_GREEN));
    sim_state.state = SIM_END;
    dut->final();
    return true;
  }
  else return false;
}
