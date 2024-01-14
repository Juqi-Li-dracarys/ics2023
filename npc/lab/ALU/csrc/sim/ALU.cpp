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

    // 初始化
    int i = 0;
    int data_a = 0;
    int data_b = 0;
    int op[11] = {0, 16, 1, 2, 3, 24, 4, 5, 21, 6, 7};

    while ((!contextp->gotFinish()) && i < 10000) {
        data_a = rand();
        data_b = rand();
        top->da = data_a;
        top->db = data_b;
        top->ALU_ctr = op[i % 11];
        top->eval();
        tfp->dump(contextp->time()); // dump wave
        contextp->timeInc(1);        // 推动仿真时间

        switch (op[i % 11])
        {
            case 0:
                assert((uint32_t)top->ALUout == (uint32_t)data_a + (uint32_t)data_b);
                break;
            case 16:
                assert((uint32_t)top->ALUout == (uint32_t)data_a - (uint32_t)data_b);
                break;
            case 1:
                assert((uint32_t)top->ALUout == (uint32_t)data_a << ((uint32_t)data_b & (uint32_t)31));
                break;
            case 2:
                assert((uint32_t)top->Less == (int32_t)data_a < (int32_t)data_b);
                break;
            case 3:
                assert((uint32_t)top->Less == (uint32_t)data_a < (uint32_t)data_b);
                break;
            case 24:
                assert((uint32_t)top->ALUout == (uint32_t)data_b);
                break;
            case 4:
                assert((uint32_t)top->ALUout == (uint32_t)data_a ^ (uint32_t)data_b);
                break;
            case 5:
                assert((uint32_t)top->ALUout == (uint32_t)data_a >> ((uint32_t)data_b & (uint32_t)31));
                break;
            case 21:
                assert((int32_t)top->ALUout == (int32_t)data_a >> ((uint32_t)data_b & (uint32_t)31));
                break;
            case 6:
                assert((uint32_t)top->ALUout == (uint32_t)data_a | (uint32_t)data_b);
                break;
            case 7:
                assert((uint32_t)top->ALUout == ((uint32_t)data_a & (uint32_t)data_b));
                break;
            default:
                assert(0); break;
        }
        std::cout << "TEST TIMES:" << i++ << std::endl;
    }
    delete top;
    tfp->close();
    delete contextp;
    std::cout << "PASS" << std::endl;
    return 0;
}



