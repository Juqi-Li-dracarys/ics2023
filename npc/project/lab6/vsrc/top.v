
module top (
    input clk,
    input rst,
    input [3:0] sw1,   // da
    input [3:0] sw2,   // db
    input [2:0] sw3,   // cntrol
    output [3:0] led1, // ALU_out
    output [1:0] led2  // cout, overflow
);
    wire less;
    wire zero;

    ALU alu_4 (
        .da(sw1),
        .db(sw2),
        .ALU_ctr(sw3),
        .ALUout(led1),
        .cout(led2[1]),
        .overflow(led2[0]),
        .less(less),
        .zero(zero)
    );

endmodule

