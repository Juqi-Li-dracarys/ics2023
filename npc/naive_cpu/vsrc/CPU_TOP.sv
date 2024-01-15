/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-01-14 09:07:03 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-01-14 10:36:45
 */

// TOP module

module CPU_TOP #(parameter PC_RST = 32'h80000000) (
    input                  clk, rst,       // 时钟，高电平复位
    output     [31 : 0]    pc_cur, inst,   // 当前 PC，指令
    output                 reg_signal,     // 寄存器异常
    output     [1 : 0]     inst_signal,    // 指令异常
    output                 ALU_signal      // ALU 异常         
);
    // PC next
    wire       [31 : 0]        pc_next;


    // 寄存器读写
    wire       [31 : 0]        rf_busW;                  // write data
    wire       [31 : 0]        rf_busA, rf_busB;         // read result


    // 控制总线
    wire       [2 : 0]         ExtOp;
    wire                       RegWr;
    wire                       ALUAsrc;
    wire       [1 : 0]         ALUBsrc;
    wire       [4 : 0]         ALUctr;
    wire       [2 : 0]         Branch;
    wire                       MemtoReg;
    wire                       MemWr;
    wire       [2 : 0]         MemOp;


    // 立即数
    wire       [31 : 0]        imm;


    // 跳转控制
    wire                       PCAsrc;
    wire                       PCBsrc;


    // ALU
    wire       [31 : 0]        da;
    wire       [31 : 0]        db;
    wire                       Less;
    wire                       Zero;
    wire       [31 : 0]        ALUout;   // output of the result



    // Memory
    wire       [31 : 0]        DataOut;

    ///////////////////////////////////////// 

    // 模块例化
    // PC 计数器
    PC pc0 (
        .clk, .rst, .*
    );

    // 指令存储器
    INST_MEM inst0 (
        .clk, .rst, .*
    );

    // 通用寄存器组
    REG_FILE reg0 (
        .clk, .rst, .*
    );

    // 控制器
    CRTL_GEN crtl0 (
        .*
    );

    // 立即数提取
    IMM_GEN imm0 (
        .*
    );

    // PC 控制
    PC_SEL ps0 (
        .rs1(rf_busA),
        .*
    );

    MuxKey #(2, 1, 32) m0 (
        .out(da),
        .key(ALUAsrc),
        .lut ({
                1'b0, rf_busA,
                1'b1, pc_cur
            })
    );

    MuxKey #(4, 2, 32) m1 (
        .out(db),
        .key(ALUBsrc),
        .lut ({
                2'b00, rf_busB,
                2'b01, imm,
                2'b10, 32'h4,
                // should not reach here
                2'b11, 32'h0
            })
    );

    // ALU
    ALU a1 (
        .*
    );

    // 分支控制
    BRANCH b1 (
        .*
    );

    // 内存控制
    DATA_MEM d0 (
        .addr(ALUout),
        .DataIn(rf_busB),
        .WrEn(MemWr),
        .*
    );

    MuxKey #(2, 1, 32) m2 (
        .out(rf_busW),
        .key(MemtoReg),
        .lut ({
                1'b0, ALUout,
                1'b1, DataOut
            })
    );

endmodule




