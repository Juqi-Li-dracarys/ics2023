
module ALU (
    input [3:0] da,
    input [3:0] db, 
    input [2:0] ALU_ctr,      
    output less,
    output zero,
    output overflow,
    output cout,
    output reg [3:0] ALUout
);
    wire sub_add;
    wire [3:0] sub_db;
    wire [3:0] add_result;

    assign sub_add = ((ALU_ctr == 3'b001) ? 1'b1 : 1'b0);
    assign sub_db = (sub_add == 1'b1) ? ~db : db;
    assign less = cout ^ sub_add;

    adder adder_4 (
        .cin(sub_add),
        .data_a(da),
        .data_b(sub_db),
        .cout(cout),
        .zero(zero),
        .overflow(overflow),
        .addout(add_result)
    );
       
    always @(*) begin
        case(ALU_ctr[2:0])
            3'b000: ALUout = add_result;
            3'b001: ALUout = add_result;
            3'b010: ALUout = ~da;
            3'b011: ALUout = da & db;
            3'b100: ALUout = da | db;
            3'b101: ALUout = da ^ db;
            3'b110: ALUout = {4{less}};
            3'b111: ALUout = {4{zero}};
            default: ALUout = 4'b0;
        endcase
    end
endmodule