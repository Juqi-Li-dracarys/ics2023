/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-02-15 23:42:05 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-02-19 23:35:42
 */


// csr file for RV32E

`include "IDU_DEFINES_ysyx23060136.sv"

// ===========================================================================
module IDU_CSR_FILE_ysyx_23060136 (
    input             clk,                      // clk for write
    input             rst,
    input   [11 : 0]  csr_id,
    input             CSRWr,                    // write CSR reg enable
    input             csr_busW,                 // write data
    output  [31 : 0]  csr_busA                  // csr read result
);

    // CSR internal ctr
    logic             csr_ecall   = (csr_id == 12'd0);
    logic             csr_mret    = (csr_id == 12'd770);
    logic             csr_mtvec   = (csr_id == 12'd773);
    logic             csr_mstatus = (csr_id == 12'd768);
    logic             csr_mcause  = (csr_id == 12'd834);
    logic             csr_mepc    = (csr_id == 12'd833);

    // read addr
    logic   [1 : 0]   CSR_Raddr   = ({2{csr_ecall}}  & `mtvec)  | ({2{csr_mret}}    & `mepc) |
                                    ({2{csr_mtvec}}  & `mtvec)  | ({2{csr_mstatus}} & `mstatus) |
                                    ({2{csr_mcause}} & `mcause) | ({2{csr_mepc}}    & `mepc);
                                    
    logic   [1 : 0]   CSR_Waddr;       // write addr


    // // DIP-C in verilog
    // import "DPI-C" function void set_csr_ptr(input logic [31 : 0] b []);


    // mstatus mtvec mepc mcause
    logic  [31 : 0]   csr_reg  [0 : 3];


    // // set the ptr to register
    // initial begin
    //     set_csr_ptr(csr_reg);
    // end

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


    assign csr_busA = csr_reg[CSR_Raddr];

endmodule


