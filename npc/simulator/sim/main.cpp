/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-01-16 13:33:06 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-04-12 10:32:06
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
VysyxSoCFull *dut = new VysyxSoCFull{contextp};

// wave tracer
VerilatedVcdC *m_trace = new VerilatedVcdC;
//////////////////////////////////////////////////////

// state of our simulated cpu
CPU_state sim_cpu = {.pc = RESET_VECTOR};

// the runing state of simulator
extern SimState sim_state;

int main(int argc, char** argv, char** env) {
    Verilated::commandArgs(argc, argv);
    // simulation monitor
    init_monitor(argc, argv);
    // start wave trace
#ifdef WAVE_RECORD
    Verilated::traceEverOn(true);
    dut->trace(m_trace, 5);
    m_trace->open("waveform.vcd");
#endif
    // reset the whole circuit
    reset(10);
    // start running
    sdb_mainloop();
    // close wave trace
#ifdef WAVE_RECORD
    m_trace->close();
#endif
    delete dut;
    // close wave trace
    delete contextp;
    return is_exit_status_bad();
}

