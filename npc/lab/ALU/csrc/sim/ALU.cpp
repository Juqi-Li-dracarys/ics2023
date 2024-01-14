#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <stdint.h>

#include "verilated.h"
#include "verilated_vcd_c.h"
#include "VALU.h"  

// dpi-c
#include <verilated_dpi.h>

uint32_t mem [5] = {0x00000001, 0x80000000, 0x8100F081, 0x0011A01F, 0xFFFFFFFF};

extern "C" int vaddr_read (int addrs, int len) {
    switch(len) {
        case 1: return *(uint8_t  *)(mem + (uint32_t)addrs -0x80000000);
        case 2: return *(uint16_t *)(mem + (uint32_t)addrs -0x80000000);
        case 4: return *(uint32_t *)(mem + (uint32_t)addrs -0x80000000);
        default: return 0;
    }
}

extern "C" void vaddr_write(int addrs, int len, int data) {
    switch(len) {
        case 1: *(uint8_t  *)(mem + (uint32_t)addrs -0x80000000) = (uint32_t)data; return;
        case 2: *(uint16_t *)(mem + (uint32_t)addrs -0x80000000) = (uint32_t)data; return;
        case 4: *(uint32_t *)(mem + (uint32_t)addrs -0x80000000) = (uint32_t)data; return;
        default: return ;
    }
}

int main(int argc, char** argv, char** env) {
    // Verilator 初始化
    VerilatedContext* contextp = new VerilatedContext;
    contextp->commandArgs(argc, argv);
    VALU* top = new VALU{ contextp };
    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC; //初始化VCD对象指针
    contextp->traceEverOn(true);            //打开追踪功能
    top->trace(tfp, 0);
    tfp->open("wave.vcd");                  //设置输出的文件wave.vcd



    // 开始仿真
    int i = 0;

    while ((!contextp->gotFinish()) && i < 10) {
        tfp->dump(contextp->time()); // dump wave
        contextp->timeInc(1);        // 推动仿真时间
        i++;
    }
    delete top;
    tfp->close();
    delete contextp;
    return 0;
}



