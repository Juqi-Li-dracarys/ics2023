/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-03-04 12:38:17 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-03-04 21:49:08
 */

 
 `include "DEFINES_ysyx23060136.sv"

 
 // Naive arbiter for IFU and MEM 
 // ===========================================================================
 module PUBLIC_ARBITER_ysyx23060136 (
    input                               clk                        ,
    input                               rst                        ,
    // ===========================================================================
    // arbiter-IFU interface
    input             [  31:0]         ARBITER_IFU_pc              ,
    input                              ARBITER_IFU_pc_valid        ,
    input                              ARBITER_IFU_inst_ready      ,

    output    logic   [  31:0]         ARBITER_IFU_inst            ,
    output                             ARBITER_IFU_inst_valid      ,
    output                             ARBITER_IFU_pc_ready        ,
     // ===========================================================================
    // arbiter-MEM interface   
    input             [  31:0]         ARBITER_MEM_raddr           ,
    input                              ARBITER_MEM_raddr_valid     ,
    output                             ARBITER_MEM_raddr_ready     ,

    output    logic   [  31:0]         ARBITER_MEM_rdata           ,
    output                             ARBITER_MEM_rdata_valid     ,
    input                              ARBITER_MEM_rdata_ready     ,
     // ===========================================================================
    // arbiter-xbar interface
    input             [  31:0]         ARBITER_XBAR_rdata          ,
    output                             ARBITER_XBAR_rdata_ready    ,
    input                              ARBITER_XBAR_rdata_valid    ,

    output   logic    [  31:0]         ARBITER_XBAR_raddr          ,
    output                             ARBITER_XBAR_raddr_valid    ,
    input                              ARBITER_XBAR_raddr_ready    
 );


    // 优先级判断，当有 MEM 和 IFU 有写要求时优先考虑 MEM
    assign       ARBITER_IFU_pc_ready      =  arbiter_state_0  & ~ARBITER_MEM_raddr_valid  ;
    assign       ARBITER_MEM_raddr_ready   =  arbiter_state_0                              ;

    // addr : arbiter->xbar
    assign       ARBITER_XBAR_raddr_valid  =  arbiter_state_1  | arbiter_state_4           ;
    // data : arbiter->MEM
    assign       ARBITER_MEM_rdata_valid   =  arbiter_state_6                              ;
    // inst : arbiter->MEM
    assign       ARBITER_IFU_inst_valid    =  arbiter_state_3                              ;
    // data : xbar->arbiter
    assign       ARBITER_XBAR_rdata_ready  =  arbiter_state_2  | arbiter_state_5           ;
    
    
    wire                       arbiter_state_0     =  (arbiter_state == `state_0) ;
    wire                       arbiter_state_1     =  (arbiter_state == `state_1) ;
    wire                       arbiter_state_2     =  (arbiter_state == `state_2) ;
    wire                       arbiter_state_3     =  (arbiter_state == `state_3) ;
    wire                       arbiter_state_4     =  (arbiter_state == `state_4) ;
    wire                       arbiter_state_5     =  (arbiter_state == `state_5) ;
    wire                       arbiter_state_6     =  (arbiter_state == `state_6) ; 


    // ===========================================================================
    // read state machine
    // 握手成功则状态转移
    logic        [2 : 0]       arbiter_state       ;
    wire         [2 : 0]       arbiter_state_next  = ({3{arbiter_state_0}} & ({3{ARBITER_IFU_pc_ready    & ARBITER_IFU_pc_valid}}    & `state_1))            |
                                                     ({3{arbiter_state_0}} & ({3{ARBITER_MEM_raddr_ready & ARBITER_MEM_raddr_valid}} & `state_4))            |

                                                     ({3{arbiter_state_1}} & ((ARBITER_XBAR_raddr_ready  & ARBITER_XBAR_raddr_valid) ? `state_2 : `state_1)) |
                                                     ({3{arbiter_state_2}} & ((ARBITER_XBAR_rdata_ready  & ARBITER_XBAR_rdata_valid) ? `state_3 : `state_2)) |
                                                     ({3{arbiter_state_3}} & ((ARBITER_IFU_inst_ready    & ARBITER_IFU_inst_valid)   ? `state_0 : `state_3)) |

                                                     ({3{arbiter_state_4}} & ((ARBITER_XBAR_raddr_ready  & ARBITER_XBAR_raddr_valid) ? `state_5 : `state_4)) |
                                                     ({3{arbiter_state_5}} & ((ARBITER_XBAR_rdata_ready  & ARBITER_XBAR_rdata_valid) ? `state_6 : `state_5)) |
                                                     ({3{arbiter_state_6}} & ((ARBITER_MEM_rdata_ready   & ARBITER_MEM_rdata_valid)  ? `state_0 : `state_6)) ;

                                                     
    // ===========================================================================                                         
    always_ff @(posedge clk) begin : update_arbiter_state
        if(rst) begin
            arbiter_state  <=  `state_0;
        end
        else begin
            arbiter_state  <=  arbiter_state_next;
        end
    end


    always_ff @(posedge clk) begin : addr_trans_to_arbiter
        if(rst) begin
            ARBITER_XBAR_raddr  <=  `PC_RST;
        end
        else begin
            ARBITER_XBAR_raddr  <=  (arbiter_state_next  == `state_1) ? ARBITER_IFU_pc    :
                                    ((arbiter_state_next == `state_4) ? ARBITER_MEM_raddr : ARBITER_XBAR_raddr);
        end
    end


    always_ff @(posedge clk) begin : xbar_inst_trans_to_arbiter
        if(rst) begin
            ARBITER_IFU_inst  <=  `NOP;
        end
        else if(arbiter_state_next == `state_3)
            begin
            ARBITER_IFU_inst  <=  ARBITER_XBAR_rdata;
        end
    end

    
    always_ff @(posedge clk) begin : xbar_rdata_trans_to_arbiter
        if(rst) begin
            ARBITER_MEM_rdata  <=  32'b0;
        end
        else if(arbiter_state_next == `state_6)
            begin
            ARBITER_MEM_rdata  <=  ARBITER_XBAR_rdata;
        end
    end


    
 endmodule


