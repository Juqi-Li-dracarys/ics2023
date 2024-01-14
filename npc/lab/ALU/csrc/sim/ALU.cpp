#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <stdint.h>
#include <iostream>

#include "verilated.h"
#include "verilated_vcd_c.h"
#include "VALU.h"  

// dpi-c
#include <verilated_dpi.h>

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

    // 随机测试次数
    int i = 0;
    int data_a = 0;
    int data_b = 0;
    int ctr = 0;

    while ((!contextp->gotFinish()) && i < 100) {
        data_a = rand();
        data_b = rand();
        top->da = data_a;
        top->db = data_b;
        top->ALU_ctr = ctr;
        top->eval();
        tfp->dump(contextp->time()); // dump wave
        contextp->timeInc(1);        // 推动仿真时间
        assert((uint32_t)top->ALUout == (uint32_t)data_a + (uint32_t)data_b);
        std::cout << "TEST TIMES:" << i++ << std::endl;
    }
    delete top;
    tfp->close();
    delete contextp;
    std::cout << "PASS" << std::endl;
    return 0;
}



