#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <stdint.h>

#include "verilated.h"
#include "verilated_vcd_c.h"
#include "VINST_MEM.h"  

// dpi-c
#include "VINST_MEM__Dpi.h"
#include <verilated_dpi.h>


uint32_t mem [5] = {0x00000001, 0x80000000, 0x8100F081, 0x0011A01F, 0xFFFFFFFF};

extern "C" int vaddr_ifetch (int addrs, int len) {
    switch(len) {
        case 1: return *(uint8_t  *)(mem + (uint32_t)addrs - 0x80000000);
        case 2: return *(uint16_t *)(mem + (uint32_t)addrs - 0x80000000);
        case 4: return *(uint32_t *)(mem + (uint32_t)addrs - 0x80000000);
        default: return 0;
    }
}

int main(int argc, char** argv, char** env) {
    // Verilator 初始化
    VerilatedContext* contextp = new VerilatedContext;
    contextp->commandArgs(argc, argv);
    VINST_MEM* top = new VINST_MEM{ contextp };
    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC; //初始化VCD对象指针
    contextp->traceEverOn(true);            //打开追踪功能
    top->trace(tfp, 0);
    tfp->open("wave.vcd");                  //设置输出的文件wave.vcd


    // 开始仿真
    // 注意时序问题
    int ramdom_MemOp = 0;
    int ramdom_addr = 0x80000000;
    int i = 0;


    top->clk = 0;
    top->rst = 1;
    top->next_addr = ramdom_addr;
    top->eval();
    tfp->dump(contextp->time()); // dump wave
    contextp->timeInc(5);        // 推动仿真时间

    top->clk = 1;
    top->eval();
    tfp->dump(contextp->time()); // dump wave
    contextp->timeInc(5);        // 推动仿真时间

    top->rst = 0;

   while ((!contextp->gotFinish()) && i < 5) {

        top->next_addr = ramdom_addr;
        top->clk = 0;
        top->eval();
        printf("Before edge, inst = 0x%08x\n", top->inst);
        tfp->dump(contextp->time()); // dump wave
        contextp->timeInc(1);        // 推动仿真时间

        // 上升沿后立即计算，这里 data_out 不会变化，因为有延迟，但其实已经写入
        top->clk = 1;
        top->eval();
        printf("After edge, inst = 0x%08x\n", top->inst);
        tfp->dump(contextp->time()); // dump wave
        contextp->timeInc(1);        // 推动仿真时间

        i++;
        ramdom_addr++;
    }

    delete top;
    tfp->close();
    delete contextp;
    return 0;
}



