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
/*
    I 指令：
    00 000 选择加法器输出，做加法
    10 000 选择加法器输出，做减法
    00 001 选择移位器输出，左移
    00 010 做减法，选择带符号小于置位结果输出, Less 按带符号结果设置
    00 011 做减法，选择无符号小于置位结果输出, Less 按无符号结果设置
    11 000 选择 ALU 输入 B 的结果直接输出
    00 100 选择异或输出
    00 101 选择移位器输出，逻辑右移
    10 101 选择移位器输出，算术右移
    00 110 选择逻辑或输出
    00 111 选择逻辑与输出

    M 指令：
    01 000 乘法取低 32 位
    01 001 乘法取高 32 位，带符号
    01 011 乘法取高 32 位，无符号
    01 100 除法，带符号
    01 101 除法，无符号
    01 110 求余，带符号
    01 111 求余，无符号
*/
    // 初始化
    int i = 0;
    int data_a = 0;
    int data_b = 0;
    int op[11] = {0, 16, 1, 2, 3, 24, 4, 5, 21, 6, 7};

    while ((!contextp->gotFinish()) && i < 100) {
        data_a = rand();
        data_b = rand();
        top->da = data_a;
        top->db = data_b;
        top->ALU_ctr = op[i % 5];
        top->eval();
        tfp->dump(contextp->time()); // dump wave
        contextp->timeInc(1);        // 推动仿真时间

        switch (op[i % 5])
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



