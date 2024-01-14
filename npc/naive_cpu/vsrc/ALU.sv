/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-01-13 20:39:08 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-01-14 21:13:34
 */

// ALU of the CPU

// ALUctr: {funct7[5], funct7[0], funct3}

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

`define   RV32M    1

module ALU (
    input       [31 : 0]    da,       // input signal A
    input       [31 : 0]    db,       // input signal B
    input       [4 : 0]     ALU_ctr,  // set the mode of algorithm
    output                  Less,
    output                  Zero,
    output reg  [31 : 0]    ALUout    // output of the result
);

    // Control bus
    wire          sub_add;
    wire          LR;
    wire          AL;
    wire          US;
    wire [1 : 0]  mul_op;
    wire          div_rem_op;

    assign sub_add = (ALU_ctr == 5'b10000)|(ALU_ctr == 5'b00010)|(ALU_ctr == 5'b00011); // sub_add = 1, subtract
    assign US = (ALU_ctr == 5'b00011);       // US = 1, unsigned
    assign LR = (ALU_ctr[2 : 0] == 3'b001);  // LR = 1, left
    assign AL = (ALU_ctr[4 : 3] == 2'b10);   // AL = 1, algorithm shift
    assign mul_op = ALU_ctr[1 : 0];          // control mul
    assign div_rem_op = ALU_ctr[0];          // control div and rem
    
    // subtract db
    wire  [31 : 0]   sub_db;
    assign sub_db = {32{sub_add}} ^ db;
   
    // the wire of adder
    wire             add_carry;
    wire             add_overflow;
    wire  [31 : 0]   add_result;
    
    // example the adder
    ADDER adder_32 (
        .cin(sub_add),
        .data_a(da),
        .data_b(sub_db),
        .cout(add_carry),
        .zero(Zero),
        .overflow(add_overflow),
        .addout(add_result)
    );
    
    // Output less
    assign Less = US ? add_carry ^ sub_add : add_overflow ^ add_result[31];
    
    wire   [31 : 0]   result_shifter;
    // example od the shifter
    B_SHIFT shifter (
        .din(da),
        .shamt(db[4 : 0]),
        .LR(LR),
        .AL(AL),
        .dout(result_shifter)
    );


`ifdef RV32M

    wire   [31 : 0]   mul_result;
    // example mul
    MULT m0 (
        .data_a(da),
        .data_b(db),
        .mul_op(mul_op),
        .result(mul_result)
    );

    wire   [31 : 0]   div_result;
    // example div
    DIV d0 (
        .data_a(da),
        .data_b(db),
        .div_op(div_rem_op),
        .result(div_result)
    );

    wire   [31 : 0]   rem_result;
    // example rem
    REM r0 (
        .data_a(da),
        .data_b(db),
        .rem_op(div_rem_op),
        .result(rem_result)
    );

`endif

    // ALU output control
    always_comb begin
        unique case(ALU_ctr)
            5'b00000: ALUout = add_result;
            5'b10000: ALUout = add_result;
            5'b00001: ALUout = result_shifter;
            5'b00010: ALUout = {32{Less}};
            5'b00011: ALUout = {32{Less}};
            5'b11000: ALUout = db;
            5'b00100: ALUout = da ^ db;
            5'b00101: ALUout = result_shifter;
            5'b10101: ALUout = result_shifter;
            5'b00110: ALUout = da | db;
            5'b00111: ALUout = da & db;
            
`ifdef RV32M
            // M 指令      
            5'b01000: ALUout = mul_result;
            5'b01001: ALUout = mul_result;
            5'b01011: ALUout = mul_result;
            5'b01100: ALUout = div_result;
            5'b01101: ALUout = div_result;
            5'b01110: ALUout = rem_result;
            5'b01111: ALUout = rem_result;
`endif

            default: ALUout = 32'b0;
        endcase
    end

endmodule



