/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-01-12 20:11:50 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-01-13 20:40:13
 */


// Main control of CPU
// Support ISA: riscv32-IM

`define   I_type   3'b000
`define   S_type   3'b010
`define   B_type   3'b011
`define   U_type   3'b001
`define   J_type   3'b100
`define   R_type   3'b111

// Stage of CPU
`define  RUNNING   2'b00
`define  HALT      2'b01
`define  ERROR     2'b10

module CRTL_GEN (
    input        [31 : 0]    inst,
    input        [31 : 0]    pc,
    // 立即数输出类型
    output reg   [2 : 0]     ExtOp,

    // 控制是否对寄存器 rd 进行写回，为 1 时写回寄存器
    output reg               RegWr,

    // 选择 ALU 输入端 A 的来源
    // 0 时选择 rs1,为 1 时选择 PC
    output reg               ALUAsrc,

    // ALU 输入端 B 的来源
    // 00 时选择 rs2
    // 01 时选择 imm(当是立即数移位指令时，只有低 5 位有效)，
    // 10 时选择常数 4（用于跳转时计算返回地址 PC+4）
    output reg   [1 : 0]     ALUBsrc,

    // 选择 ALU 执行的操作
    // ALUctr: {funct7[5], funct7[0], funct3}
    output reg   [4 : 0]     ALUctr,

    // 说明分支和跳转的种类，用于生成最终的分支控制信号
    output reg   [2 : 0]     Branch,

    // 选择寄存器 rd 写回数据来源，为 0 时选择 ALU
    // 输出，为 1 时选择数据存储器输出
    output reg               MemtoReg,

    // 控制是否对数据存储器进行写入，为 1 时写回存储器
    output reg               MemWr,

    // 控制数据存储器读写格式，为 010 时为 4 字节读写，
    // 为 001 时为 2 字节读写带符号扩展，为 000 时为 1 字节读写带符号扩展，
    // 为 101 时为 2 字节读写无符号扩展，为 100 时为 1 字节读写无符号扩展
    output reg   [2 : 0]     MemOP
);

    // 标志提取
    wire      [6 : 0]       op;
    wire      [2 : 0]       func3;
    wire      [6 : 0]       func7;

    assign op =  inst[6 : 0];
    assign funct3 = inst[14 : 12];
    assign funct7 = inst[31 : 25];

    reg      [2 : 0]       inst_type;
    
    // DIP-C in verilog
    import "DPI-C" function void ebreak();
    import "DPI-C" function invalid_inst(input int thispc);

    // 指令类型解析
    always_comb begin
        // R 型指令解析(未包含mret)
        unique if(op == 6'b0110011) begin
            inst_type = R_type;
            ExtOp = R_type;
            RegWr = 1'b1;
            ALUAsrc = 1'b0;
            ALUBsrc = 2'b00;
            ALUctr = {func7[5], funct7[0], func3};
            Branch = 3'b000;
            MemtoReg = 1'b0;
            MemWr = 1'b0;
            MemOP = 3'b000;
        end

        // B 型指令
        else if(op == 6'b1100011) begin
            inst_type = B_type;
            ExtOp = B_type;
            RegWr = 1'b0;
            ALUAsrc = 1'b0;
            ALUBsrc = 2'b00;
            unique case(func3)
                // beq
                3'b000: begin
                    Branch = 3'b100; ALUctr = 5'b00010; 
                end
                // bne
                3'b001: begin
                    Branch = 3'b101; ALUctr = 5'b00010; 
                end
                // blt
                3'b100: begin
                    Branch = 3'b110; ALUctr = 5'b00010; 
                end
                // bge
                3'b101: begin
                    Branch = 3'b111; ALUctr = 5'b00010; 
                end
                // bltu
                3'b110: begin
                    Branch = 3'b110; ALUctr = 5'b10010; 
                end
                // bgeu
                3'b111: begin
                    Branch = 3'b111; ALUctr = 5'b10010; 
                end
                // unkown instruction, should not reach here
                default: begin
                    invalid_inst(pc);
                end            
            endcase
            MemtoReg = 1'b0;
            MemWr = 1'b0;
            MemOP = 3'b000;          
        end

        // S 型指令
        else if(op == 6'b0100011) begin
            inst_type = S_type;
            ExtOp = S_type;
            RegWr = 1'b0;
            ALUAsrc = 1'b0;
            ALUBsrc = 2'b01;
            ALUctr = 5'b00000;
            Branch = 3'b000;
            MemtoReg = 1'b0;
            MemWr = 1'b1;
            MemOP = func3;
        end

        // U 型指令
        else if(op == 6'b0010111 || op == 6'b0110111) begin
            inst_type = U_type;
            ExtOp = U_type;
            RegWr = 1'b1;
            ALUAsrc = 1'b1;
            ALUBsrc = 2'b01;
            // aupic or lui
            ALUctr = (op == 6'b0010111 ? 5'b00000 : 5'b11000);
            Branch = 3'b000;
            MemtoReg = 1'b0;
            MemWr = 1'b0;
            MemOP = 3'b000;
        end

        // J 型指令
        else if(op == 6'b1101111) begin
            inst_type = J_type;
            ExtOp = J_type;
            RegWr = 1'b1;
            ALUAsrc = 1'b1;
            ALUBsrc = 2'b10;
            ALUctr = 5'b00000;
            Branch = 3'b001;
            MemtoReg = 1'b0;
            MemWr = 1'b0;
            MemOP = 3'b000;
        end

        // I 型指令的第一部分
        else if(op == 6'b0010011) begin
            inst_type = I_type;
            ExtOp = I_type;
            RegWr = 1'b1;
            ALUAsrc = 1'b0;
            ALUBsrc = 2'b01;
            ALUctr = (func3 == 3'b101 && func7[5]) ? {2'b10, func3} : {2'b00, func3};
            Branch = 3'b000;
            MemtoReg = 1'b0;
            MemWr = 1'b0;
            MemOP = 3'b000;
        end

        // I 型指令的第二部分(jalr)
        else if(op == 6'b1100111) begin
            inst_type = I_type;
            ExtOp = I_type;          
            RegWr = 1'b1;
            ALUAsrc = 1'b1;
            ALUBsrc = 2'b10;
            ALUctr = 5'b00000;
            Branch = 3'b010;
            MemtoReg = 1'b0;
            MemWr = 1'b0;
            MemOP = 3'b000;
        end

        // I 型指令的第三部分(load)
        else if(op == 6'b0000011) begin
            inst_type = I_type;
            ExtOp = I_type;          
            RegWr = 1'b1;
            ALUAsrc = 1'b0;
            ALUBsrc = 2'b01;
            ALUctr = 5'b00000;
            Branch = 3'b000;
            MemtoReg = 1'b1;
            MemWr = 1'b0;
            MemOP = func3;
        end
        
        else if(op == 6'b1110011) begin
            ebreak();
        end

        else begin
            invalid_inst(pc);
        end

    end
    
endmodule



