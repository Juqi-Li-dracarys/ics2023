/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-01-16 13:33:06 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-01-16 13:58:21
 */

#include <bits/stdc++.h>
#include <debug.h>
#include <common.h>
#include <disasm.h>
#include <sim.h>

// verilog instance
VCPU_TOP *dut = new VCPU_TOP;
// wave tracer
VerilatedVcdC *m_trace = new VerilatedVcdC;

size_t sim_time = 0;
// state of our simulated cpu
CPU_state sim_cpu;

uint32_t *cpu_gpr = NULL;
// the runing state of simulator
extern SimState sim_state;

int main(int argc, char** argv, char** env) {


    init_monitor(argc, argv);

    // start wave trace
    Verilated::traceEverOn(true);
    dut->trace(m_trace, 5);
    m_trace->open("waveform.vcd");
    reset(1);
    
    // start running
    sdb_mainloop();

    printf(ANSI_FG_GREEN "Testcase end!\n" ANSI_NONE);
    
    // close wave trace
    m_trace->close();
    delete dut;
    return sim_state.state == SIM_ABORT;
}
