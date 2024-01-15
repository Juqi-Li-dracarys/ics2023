#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <stdint.h>

#include "verilated.h"
#include "verilated_vcd_c.h"
#include "VREG_FILE.h"  

// dpi-c
#include "VREG_FILE__Dpi.h"
#include <verilated_dpi.h>


// source
uint32_t data [5] = {0x12345678, 0x87654321, 0x8100F081, 0x0011A01F, 0x44444444};


uint32_t *cpu_gpr = NULL;

extern "C" void set_gpr_ptr(const svOpenArrayHandle r) {
    cpu_gpr = (uint32_t *)(((VerilatedDpiOpenVar*)r)->datap());
}


int main(int argc, char** argv, char** env) {
    // Verilator 初始化
    VerilatedContext* contextp = new VerilatedContext;
    contextp->commandArgs(argc, argv);
    VREG_FILE* top = new VREG_FILE{ contextp };
    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC; //初始化VCD对象指针
    contextp->traceEverOn(true);            //打开追踪功能
    top->trace(tfp, 0);
    tfp->open("wave.vcd");                  //设置输出的文件wave.vcd


    // 开始仿真
    // 注意时序问题
    int ramdom_addr = 0x80000000;
    int i = 0;

    top->clk = 0;
    top->rst = 1;
    top->inst = 0x80000000;
    top->rf_busW = 0;
    top->RegWr = 1;
    top->eval();
    tfp->dump(contextp->time()); // dump wave
    contextp->timeInc(5);        // 推动仿真时间

    top->clk = 1;
    top->eval();
    tfp->dump(contextp->time()); // dump wave
    contextp->timeInc(5);        // 推动仿真时间

    top->rst = 0;

    while ((!contextp->gotFinish()) && i < 5) {

        top->inst = data[i];
        top->rf_busW = data[i];
        top->clk = 0;
        top->eval();
        printf("Before edge, busA = 0x%08x, busB = 0x%08x\n", top->rf_busA, top->rf_busB);
        tfp->dump(contextp->time()); // dump wave
        contextp->timeInc(1);        // 推动仿真时间

        // 上升沿后立即计算，这里 data_out 不会变化，因为有延迟，但其实已经写入
        top->clk = 1;
        top->eval();
        printf("A0, busA = 0x%08x, busB = 0x%08x\n", top->rf_busA, top->rf_busB);
        tfp->dump(contextp->time()); // dump wave
        contextp->timeInc(2);        // 推动仿真时间

        // 1ps 后 data_out 变化
        top->eval();
        printf("A1 edge, busA = 0x%08x, busB = 0x%08x\n", top->rf_busA, top->rf_busB);
        tfp->dump(contextp->time()); // dump wave
        contextp->timeInc(3);        // 推动仿真时间

        for(int i = 0; i < 16; i++) {
            printf("0x%08x\t", cpu_gpr[i]);
            if((i + 1) % 4 == 0) {
                putchar('\n');
            }
        }

        i++;
        ramdom_addr++;
    }



    delete top;
    tfp->close();
    delete contextp;
    return 0;
}



