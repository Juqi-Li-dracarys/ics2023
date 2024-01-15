#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <stdint.h>
#include <iostream>

#include "verilated.h"
#include "verilated_vcd_c.h"
#include "VCRTL_GEN.h"  

// dpi-c
#include <verilated_dpi.h>

static const uint32_t img [] = {
  0x00000297,  // auipc t0,0
  0x00028823,  // sb  zero,16(t0)
  0x0102c503,  // lbu a0,16(t0)
  0x00100073,  // ebreak (used as nemu_trap)
  0xdeadbeef,  // some data
};


int main(int argc, char** argv, char** env) {
    // Verilator 初始化
    VerilatedContext* contextp = new VerilatedContext;
    contextp->commandArgs(argc, argv);
    VCRTL_GEN* top = new VCRTL_GEN{ contextp };
    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC; //初始化VCD对象指针
    contextp->traceEverOn(true);            //打开追踪功能
    top->trace(tfp, 0);
    tfp->open("wave.vcd");                  //设置输出的文件wave.vcd

    // 初始化
    int i = 0;
    top->inst = 0;
    top->eval();
    tfp->dump(contextp->time()); // dump wave
    contextp->timeInc(1);        // 推动仿真时间

    while ((!contextp->gotFinish()) && (i < sizeof(img) / sizeof(img[0]))) {
        top->inst = img[i];
        top->eval();
        tfp->dump(contextp->time()); // dump wave
        contextp->timeInc(5);        // 推动仿真时间
        i++;
    }
    contextp->timeInc(20);        // 推动仿真时间
    top->eval();
    tfp->dump(contextp->time()); // dump wave

    delete top;
    tfp->close();
    delete contextp;
    return 0;
}



