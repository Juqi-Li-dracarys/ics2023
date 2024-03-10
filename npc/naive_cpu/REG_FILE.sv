/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-01-12 20:25:26 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-01-26 19:23:43
 */

// register file for RV32E
// 与 CSR 寄存器相关的控制逻辑
// 全部放在这里

 /* verilator lint_off UNUSED */
 /* verilator lint_off UNUSEDSIGNAL */

localparam   mstatus  =  2'h0; 
localparam   mtvec    =  2'h1;
localparam   mepc     =  2'h2;
localparam   mcause   =  2'h3;


module REG_FILE #(parameter gpr_reg_num = 5'd16, csr_reg_num = 5'd4) (
    input             clk,                      // clk for write
    input   [31 : 0]  pc_cur,
    input             rst,
    input   [31 : 0]  inst,
    // csr reg
    input             CSRWr,                    // write CSR reg enable
    output  [31 : 0]  csr_busA,                 // csr read result
    // gpr reg
    input             RegWr,                    // write gpr reg enable
    input   [31 : 0]  rf_busW,                  // write gpr data
    output  [31 : 0]  rf_busA, rf_busB,         // gpr read result
    output            reg_signal                // should be 0
);

    // gpr reg
    wire      [3 : 0]       rs1;
    wire      [3 : 0]       rs2;
    wire      [3 : 0]       rd;


    // CSR internal ctr
    reg       [1 : 0]       CSR_Raddr;  // read addr
    reg       [1 : 0]       CSR_Waddr;  // write addr
    reg       [31 : 0]      csr_busW;   // write csr data


    assign rs1 = inst[18 : 15];
    assign rs2 = inst[23 : 20];
    assign rd =  inst[10 : 7];
 

    // DIP-C in verilog
    import "DPI-C" function void set_gpr_ptr(input logic [31 : 0] a []);
    import "DPI-C" function void set_csr_ptr(input logic [31 : 0] b []);


    // mstatus mtvec mepc mcause
    reg  [31 : 0]   gpr_reg  [0 : gpr_reg_num - 1];
    reg  [31 : 0]   csr_reg  [0 : csr_reg_num - 1];


    // set the ptr to register
    initial begin
        set_gpr_ptr(gpr_reg);
        set_csr_ptr(csr_reg);
    end

    // calculate addr by imm
    always_comb begin: intenal_ctr_csr_1
        unique case (inst[31 : 20])
            // ecall
            12'd0:   begin  CSR_Raddr = mtvec;   CSR_Waddr = mepc;     end
            // other csr instructions
            12'd773: begin  CSR_Raddr = mtvec;   CSR_Waddr = mtvec;    end
            12'd768: begin  CSR_Raddr = mstatus; CSR_Waddr = mstatus;  end
            12'd834: begin  CSR_Raddr = mcause;  CSR_Waddr = mcause;   end
            12'd833: begin  CSR_Raddr = mepc;    CSR_Waddr = mepc;     end
            // mret
            12'd770: begin  CSR_Raddr = mepc;    CSR_Waddr = mepc;     end
            // shoul not reach here
            default: begin  CSR_Raddr = mtvec;   CSR_Waddr = mepc;     end
        endcase
    end

    // calculate write data by func
    always_comb begin: intenal_ctr_csr_2
        unique case (inst[14 : 12])
        // ecall
        3'b000:  begin  csr_busW = pc_cur;              end
        // csrrw
        3'b001:  begin  csr_busW = rf_busA;             end
        3'b010:  begin  csr_busW = rf_busA | csr_busA;  end
        default: begin  csr_busW = pc_cur;              end
        endcase
    end

    // write the gpr-reg in the next posedge
    integer i;
    always_ff @(posedge clk) begin
        // should not write $0
        if(rst) begin
            for(i = 0; i < gpr_reg_num; i = i + 1) begin
                gpr_reg[i] <= 32'h0;
            end
        end
        else if(RegWr && rd != 4'b0) begin
            gpr_reg[rd] <= rf_busW;
        end
    end

    // write the csr-reg in the next posedge
    always_ff @(posedge clk) begin
        // should not write $0
        if(rst) begin
            // mstatus
            csr_reg[mstatus] <= 32'h1800;
            csr_reg[mtvec] <= 32'h0;
            csr_reg[mepc] <= 32'h0;
            // mcause
            csr_reg[mcause] <= 32'hb;
        end
        else if(CSRWr) begin
            csr_reg[CSR_Waddr] <= csr_busW;
        end
    end


    // read register
    assign rf_busA = gpr_reg[rs1];
    assign rf_busB = gpr_reg[rs2];
    assign csr_busA = csr_reg[CSR_Raddr];


    // Error sinal
    assign reg_signal = 1'b0;

endmodule


