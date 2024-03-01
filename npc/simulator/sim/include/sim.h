/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-01-16 10:58:17 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-01-17 16:08:00
 */


// header of verilator
#include "verilated_vcd_c.h"
#include "VCPU_TOP.h"

// dpi-c
#include "VCPU_TOP__Dpi.h"
#include <verilated_dpi.h>

extern VCPU_TOP *dut;
extern VerilatedVcdC *m_trace;
extern VerilatedContext* contextp;



