/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-01-16 13:33:06 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-01-17 12:17:04
 */

#include <bits/stdc++.h>
#include <debug.h>
#include <common.h>
#include <disasm.h>
#include <sim.h>

//////////////////////////////////////////////////////
// context ptr
VerilatedContext* contextp = new VerilatedContext;

// verilog instance
VCPU_TOP *dut = new VCPU_TOP{contextp};

// wave tracer
VerilatedVcdC *m_trace = new VerilatedVcdC;
//////////////////////////////////////////////////////

// state of our simulated cpu
CPU_state sim_cpu;

// the runing state of simulator
extern SimState sim_state;


inline bool is_exit_status_bad() {
  bool good = (sim_state.state == SIM_END && sim_state.halt_ret == 0) ||
    (sim_state.state == SIM_QUIT);
  return !good;
}

int main(int argc, char** argv, char** env) {
    // simulation monitor
    init_monitor(argc, argv);
    // start wave trace
    Verilated::traceEverOn(true);
    dut->trace(m_trace, 5);
    m_trace->open("waveform.vcd");
    
    reset(1);
    
    // start running
    
    // sdb_mainloop();

    printf(ANSI_FG_GREEN "Testcase end!\n" ANSI_NONE);
    
    // close wave trace
    m_trace->close();
    delete dut;
    // close wave trace
    delete contextp;
    return is_exit_status_bad();
}

