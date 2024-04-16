/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-04-13 23:51:28 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-04-14 00:07:23
 */


`include "ysyx_23060136_DEFINES.sv"


// Interface for arbiter(AXI bus) and cache
// protocol: AXI and cache interface
// ===========================================================================
module ysyx_23060136_IFU_ICACHE (
      // data from pc counter
      input                                             clk                        ,
      input                                             rst                        ,
      
      input              [  `ysyx_23060136_BITS_W-1:0]  IFU1_pc                    ,

      input                                             BRANCH_flushIF             ,
      input                                             FORWARD_stallIF            ,
      // ===========================================================================
      // Arbiter AXI interface 
      input                                             ARBITER_IFU_arready        , 
      output    logic                                   ARBITER_IFU_arvalid        , 
      output    logic   [  31:0]                        ARBITER_IFU_araddr         , 
      output            [   3:0]                        ARBITER_IFU_arid           , 
      output            [   7:0]                        ARBITER_IFU_arlen          , 
      output    logic   [   2:0]                        ARBITER_IFU_arsize         , 
      output            [   1:0]                        ARBITER_IFU_arburst        , 
      output                                            ARBITER_IFU_rready         , 
      input                                             ARBITER_IFU_rvalid         , 
      input             [   1:0]                        ARBITER_IFU_rresp          , 
      input             [  63:0]                        ARBITER_IFU_rdata          , 
      input                                             ARBITER_IFU_rlast          , 
      input             [   3:0]                        ARBITER_IFU_rid            ,

      // ===========================================================================
      // cache interface
      // To do: cache
      output             [   5:0]                       io_sram0_addr              ,             
      output                                            io_sram0_cen               ,             
      output                                            io_sram0_wen               ,             
      output             [ 127:0]                       io_sram0_wmask             ,             
      output             [ 127:0]                       io_sram0_wdata             ,             
      input              [ 127:0]                       io_sram0_rdata             ,

      output             [   5:0]                       io_sram1_addr              ,             
      output                                            io_sram1_cen               ,             
      output                                            io_sram1_wen               ,             
      output             [ 127:0]                       io_sram1_wmask             ,             
      output             [ 127:0]                       io_sram1_wdata             ,             
      input              [ 127:0]                       io_sram1_rdata             ,

      output             [   5:0]                       io_sram2_addr              ,             
      output                                            io_sram2_cen               ,             
      output                                            io_sram2_wen               ,             
      output             [ 127:0]                       io_sram2_wmask             ,             
      output             [ 127:0]                       io_sram2_wdata             ,             
      input              [ 127:0]                       io_sram2_rdata             ,

      output             [   5:0]                       io_sram3_addr              ,             
      output                                            io_sram3_cen               ,             
      output                                            io_sram3_wen               ,             
      output             [ 127:0]                       io_sram3_wmask             ,             
      output             [ 127:0]                       io_sram3_wdata             ,             
      input              [ 127:0]                       io_sram3_rdata             ,
      // ===========================================================================
      // output for the next stage
      output   logic     [  `ysyx_23060136_INST_W-1:0]  IFU_o_inst                 ,
      output   logic                                    inst_valid                 ,
      output   logic                                    IFU_error_signal                                           
);
    


    // PC值非法检测(only for debug)
    wire                         pc_legal               =  (IFU1_pc >= `ysyx_23060136_MBASE && IFU1_pc < `ysyx_23060136_MEND)  ; 
    
    // 传输地址完成后，我们直接准备接受数据
    assign                       ARBITER_IFU_rready     =  r_state_wait                                         ;

    assign                       ARBITER_IFU_arid       =  'b0                                                  ;
    assign                       ARBITER_IFU_arlen      =  8'b0000_0000                                         ;
    assign                       ARBITER_IFU_arburst    =  2'b00                                                ;
    
    wire                         r_state_idle           =  (r_state == `ysyx_23060136_idle)                     ;
    wire                         r_state_ready          =  (r_state == `ysyx_23060136_ready)                    ;
    wire                         r_state_wait           =  (r_state == `ysyx_23060136_wait)                     ;
    // state machine
    logic       [1 : 0]          r_state                                                                        ;
    logic       [1 : 0]          r_state_next                                                                   ;

    // higher 32 bits or lower 
    logic                        inst_hi                                                                        ;

    // ===========================================================================
    // TO DO: add I-cache interface here
    wire                        cache_hit               =  `ysyx_23060136_false                                 ;
    
    assign                      io_sram0_addr           =  `ysyx_23060136_false                                 ;
    assign                      io_sram0_cen            =  `ysyx_23060136_false                                 ;
    assign                      io_sram0_wen            =  `ysyx_23060136_false                                 ;
    assign                      io_sram0_wmask          =  `ysyx_23060136_false                                 ;
    assign                      io_sram0_wdata          =  `ysyx_23060136_false                                 ;

    assign                      io_sram1_addr           =  `ysyx_23060136_false                                 ;
    assign                      io_sram1_cen            =  `ysyx_23060136_false                                 ;
    assign                      io_sram1_wen            =  `ysyx_23060136_false                                 ;
    assign                      io_sram1_wmask          =  `ysyx_23060136_false                                 ;
    assign                      io_sram1_wdata          =  `ysyx_23060136_false                                 ;

    assign                      io_sram2_addr           =  `ysyx_23060136_false                                 ;
    assign                      io_sram2_cen            =  `ysyx_23060136_false                                 ;
    assign                      io_sram2_wen            =  `ysyx_23060136_false                                 ;
    assign                      io_sram2_wmask          =  `ysyx_23060136_false                                 ;
    assign                      io_sram2_wdata          =  `ysyx_23060136_false                                 ;

    assign                      io_sram3_addr           =  `ysyx_23060136_false                                 ;
    assign                      io_sram3_cen            =  `ysyx_23060136_false                                 ;
    assign                      io_sram3_wen            =  `ysyx_23060136_false                                 ;
    assign                      io_sram3_wmask          =  `ysyx_23060136_false                                 ;
    assign                      io_sram3_wdata          =  `ysyx_23060136_false                                 ;
    // ===========================================================================

    always_comb begin : r_state_trans
        // pipeline flow and cache miss
        unique case(r_state)
            `ysyx_23060136_idle: begin
                if(!FORWARD_stallIF & !cache_hit) begin
                    r_state_next = `ysyx_23060136_ready;
                end
                else begin
                    r_state_next = `ysyx_23060136_idle;
                end
            end
            `ysyx_23060136_ready: begin
                if(ARBITER_IFU_arready & ARBITER_IFU_arvalid) begin
                    r_state_next = `ysyx_23060136_wait;
                end
                else begin
                    r_state_next = `ysyx_23060136_ready;
                end
            end
            `ysyx_23060136_wait: begin
                if(ARBITER_IFU_rvalid & ARBITER_IFU_rready) begin
                    r_state_next = `ysyx_23060136_idle;
                end
                else begin
                    r_state_next = `ysyx_23060136_wait;
                end
            end
            default: r_state_next = `ysyx_23060136_idle;
        endcase
    end
    

    always_ff @(posedge clk) begin : state_machine
        if(rst || (BRANCH_flushIF & !FORWARD_stallIF)) begin
            r_state <=  `ysyx_23060136_idle;
        end
        else begin
            r_state <=  r_state_next;
        end
    end


    always_ff @(posedge clk) begin : pc_valid
        if(rst || (BRANCH_flushIF & !FORWARD_stallIF)) begin
            ARBITER_IFU_arvalid <= `ysyx_23060136_false;       
        end
        else if((r_state_idle & r_state_next == `ysyx_23060136_ready)) begin
            ARBITER_IFU_arvalid <=  `ysyx_23060136_true;
        end 
        else if((r_state_ready & r_state_next == `ysyx_23060136_wait)) begin
            ARBITER_IFU_arvalid <= `ysyx_23060136_false;  
        end
    end

    always_ff @(posedge clk) begin : pc_update
        if(rst || (BRANCH_flushIF & ~FORWARD_stallIF)) begin
            ARBITER_IFU_araddr <= `ysyx_23060136_false;
            ARBITER_IFU_arsize <= `ysyx_23060136_false;
            inst_hi            <= `ysyx_23060136_false;
        end
        else if((r_state_idle & r_state_next == `ysyx_23060136_ready)) begin
            ARBITER_IFU_araddr <=  {IFU1_pc[31 : 3], {3{1'b0}}};
            ARBITER_IFU_arsize <=  3'b010;
            inst_hi            <=  IFU1_pc[2];
        end
    end

    always_ff @(posedge clk) begin : inst_valid_trans
        if(rst || (BRANCH_flushIF & ~FORWARD_stallIF)) begin
            inst_valid <= `ysyx_23060136_true;
        end
        else if((r_state_idle & r_state_next == `ysyx_23060136_ready)) begin
            inst_valid <=  `ysyx_23060136_false;
        end
        else if((r_state_next == `ysyx_23060136_idle & r_state_wait)) begin
            inst_valid <= `ysyx_23060136_true;
        end
    end

    always_ff @(posedge clk) begin : inst_update
        if(rst || (BRANCH_flushIF & ~FORWARD_stallIF)) begin
            IFU_o_inst <= `ysyx_23060136_NOP;
        end
        else if((r_state_next == `ysyx_23060136_idle & r_state_wait & ARBITER_IFU_rlast))begin
            IFU_o_inst <=  inst_hi  ?  ARBITER_IFU_rdata[63 : 32] : ARBITER_IFU_rdata[31 : 0] ;
        end
    end

    always_ff @(posedge clk) begin : update_respond
        if(rst) begin
            IFU_error_signal   <=  `ysyx_23060136_false;
        end
        else if(ARBITER_IFU_arvalid & !pc_legal) begin
            IFU_error_signal  <= `ysyx_23060136_true;
        end
        else if(r_state_wait & r_state_next == `ysyx_23060136_idle) begin
            IFU_error_signal  <=  (ARBITER_IFU_rresp != `ysyx_23060136_OKAY) || (ARBITER_IFU_rid !=  ARBITER_IFU_arid);
        end
    end

endmodule


