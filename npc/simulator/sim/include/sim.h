/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-01-16 10:58:17 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-03-08 00:10:43
 */


// header of each module in SoC
#include "verilated_vcd_c.h"
#include "VysyxSoCFull.h"
#include "VysyxSoCFull_ysyxSoCFull.h"
#include "VysyxSoCFull_ysyx_23060136.h"

// dpi-c
#include "VysyxSoCFull__Dpi.h"
#include <verilated_dpi.h>

extern VysyxSoCFull *dut;
extern VerilatedVcdC *m_trace;
extern VerilatedContext* contextp;


// PATH to cpu core in C++ hierarchy
#define CPU dut->ysyxSoCFull->cpu



