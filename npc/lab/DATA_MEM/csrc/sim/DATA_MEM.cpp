#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <stdint.h>

#include "verilated.h"
#include "verilated_vcd_c.h"
#include "VDATA_MEM.h"  

// dpi-c
#include "VDATA_MEM__Dpi.h"
#include <verilated_dpi.h>

uint32_t mem [5] = {0x00000001, 0x81000000, 0x81000001, 0x801100FF, 0xFFFFFFFF};

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
    VDATA_MEM* top = new VDATA_MEM{ contextp };
    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC; //初始化VCD对象指针
    contextp->traceEverOn(true);            //打开追踪功能
    top->trace(tfp, 0);
    tfp->open("wave.vcd");                  //设置输出的文件wave.vcd

    // 初始化
    top->clk = 0;
    top->WrEn = 0;
    top->MemOp = 0;
    top->addr = 0x80000000;
    top->DataIn = 0;
    top->DataOut = 0;
    top->eval();

    // 开始仿真
    int ramdom_MemOp = 0;
    int ramdom_addr = 0x80000000;

    while ((!contextp->gotFinish()) && contextp->time() < 100) {
        ramdom_MemOp = (rand() % 8);
        ramdom_addr = 0x80000000 + rand() % 5;
        top->MemOp = ramdom_MemOp;
        top->addr = ramdom_addr;
        top->eval();
        printf("ramdom_MemOp = 0x%08x, ramdom_addr = 0x%08x, result = 0x%08x\n", ramdom_MemOp, ramdom_addr, top->DataOut);
        tfp->dump(contextp->time()); // dump wave
        contextp->timeInc(1);        // 推动仿真时间
    }
    delete top;
    tfp->close();
    delete contextp;
    return 0;
}

