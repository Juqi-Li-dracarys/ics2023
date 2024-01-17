/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-01-16 13:33:06 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-01-17 21:43:23
 */

#include <bits/stdc++.h>
#include <debug.h>
#include <common.h>
#include <disasm.h>

// header of verilator
#include "verilated_vcd_c.h"
#include "VCPU_TOP.h"

// dpi-c
#include "VCPU_TOP__Dpi.h"
#include <verilated_dpi.h>


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

int main(int argc, char** argv, char** env) {
    // simulation monitor
    init_monitor(argc, argv);
    // start wave trace
    Verilated::traceEverOn(true);
    dut->trace(m_trace, 5);
    m_trace->open("waveform.vcd");
    // reset the whole circuit
    reset(1);
    // start running
    sdb_mainloop();
    // close wave trace
    m_trace->close();
    delete dut;
    // close wave trace
    delete contextp;
    return is_exit_status_bad();
}

