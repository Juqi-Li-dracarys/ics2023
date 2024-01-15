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
    while ((!contextp->gotFinish()) && i < 10000) {
        i++;
    }
    delete top;
    tfp->close();
    delete contextp;
    std::cout << "PASS" << std::endl;
    return 0;
}



