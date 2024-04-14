/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-04-11 14:27:08 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-04-14 01:14:09
 */


 `include "ysyx_23060136_DEFINES.sv"

 
 // Arbiter for IFU and MEM reading process
 // ===========================================================================
 module ysyx_23060136_ARBITER (
    input                                              clk                        ,
    input                                              rst                        ,
    // ===========================================================================
    // arbiter-IFU interface
    output                                             ARBITER_IFU_arready        , 
    input                                              ARBITER_IFU_arvalid        , 
    input              [  31:0]                        ARBITER_IFU_araddr         , 
    input              [   3:0]                        ARBITER_IFU_arid           , 
    input              [   7:0]                        ARBITER_IFU_arlen          , 
    input              [   2:0]                        ARBITER_IFU_arsize         , 
    input              [   1:0]                        ARBITER_IFU_arburst        , 
    input                                              ARBITER_IFU_rready         , 
    output                                             ARBITER_IFU_rvalid         , 
    output             [   1:0]                        ARBITER_IFU_rresp          , 
    output             [  63:0]                        ARBITER_IFU_rdata          , 
    output                                             ARBITER_IFU_rlast          , 
    output             [   3:0]                        ARBITER_IFU_rid            ,
    // ===========================================================================
    // arbiter-MEM interface   
    output                                             ARBITER_MEM_arready        , 
    input                                              ARBITER_MEM_arvalid        , 
    input              [  31:0]                        ARBITER_MEM_araddr         , 
    input              [   3:0]                        ARBITER_MEM_arid           , 
    input              [   7:0]                        ARBITER_MEM_arlen          , 
    input              [   2:0]                        ARBITER_MEM_arsize         , 
    input              [   1:0]                        ARBITER_MEM_arburst        , 
    input                                              ARBITER_MEM_rready         , 
    output                                             ARBITER_MEM_rvalid         , 
    output             [   1:0]                        ARBITER_MEM_rresp          , 
    output             [  63:0]                        ARBITER_MEM_rdata          , 
    output                                             ARBITER_MEM_rlast          , 
    output             [   3:0]                        ARBITER_MEM_rid            ,
    // ===========================================================================
    // SoC AXI interface
    input                                              io_master_arready           , 
    output                                             io_master_arvalid           , 
    output            [  31:0]                         io_master_araddr            , 
    output            [   3:0]                         io_master_arid              , 
    output            [   7:0]                         io_master_arlen             , 
    output            [   2:0]                         io_master_arsize            , 
    output            [   1:0]                         io_master_arburst           , 
    output                                             io_master_rready            , 
    input                                              io_master_rvalid            , 
    input             [   1:0]                         io_master_rresp             , 
    input             [  63:0]                         io_master_rdata             , 
    input                                              io_master_rlast             , 
    input             [   3:0]                         io_master_rid               
 );


    // 当 MEM 和 IFU 同时有读要求时，我们优先考虑 MEM 的读操作
    assign       ARBITER_IFU_arready       =  a_state_idle  & ~ARBITER_MEM_arvalid & io_master_arready   ;
    assign       ARBITER_IFU_rvalid        =  a_state_ifu       & io_master_rvalid                       ;
    assign       ARBITER_IFU_rresp         =  {2{a_state_ifu}}  & io_master_rresp                        ;
    assign       ARBITER_IFU_rdata         =  {64{a_state_ifu}} & io_master_rdata                        ;
    assign       ARBITER_IFU_rlast         =  a_state_ifu       & io_master_rlast                        ;
    assign       ARBITER_IFU_rid           =  {4{a_state_ifu}}  & io_master_rid                          ;   
    

    assign       ARBITER_MEM_arready       =  a_state_idle      & io_master_arready                      ;
    assign       ARBITER_MEM_rvalid        =  a_state_mem       & io_master_rvalid                       ;
    assign       ARBITER_MEM_rresp         =  {2{a_state_mem}}  & io_master_rresp                        ;
    assign       ARBITER_MEM_rdata         =  {64{a_state_mem}} & io_master_rdata                        ;
    assign       ARBITER_MEM_rlast         =  a_state_mem       & io_master_rlast                        ;
    assign       ARBITER_MEM_rid           =  {4{a_state_mem}}  & io_master_rid                          ; 
    
    
    assign       io_master_arvalid         =   a_state_idle & (ARBITER_IFU_arvalid | ARBITER_MEM_arvalid) ;
    assign       io_master_araddr          =  (a_state_idle & ARBITER_MEM_arvalid) ? ARBITER_MEM_araddr   : ((a_state_idle & ARBITER_IFU_arvalid) ? ARBITER_IFU_araddr  : 32'b0);
    assign       io_master_arid            =  (a_state_idle & ARBITER_MEM_arvalid) ? ARBITER_MEM_arid     : ((a_state_idle & ARBITER_IFU_arvalid) ? ARBITER_IFU_arid    : 4'b0);
    assign       io_master_arsize          =  (a_state_idle & ARBITER_MEM_arvalid) ? ARBITER_MEM_arsize   : ((a_state_idle & ARBITER_IFU_arvalid) ? ARBITER_IFU_arsize  : 3'b0);
    assign       io_master_arburst         =  (a_state_idle & ARBITER_MEM_arvalid) ? ARBITER_MEM_arburst  : ((a_state_idle & ARBITER_IFU_arvalid) ? ARBITER_IFU_arburst : 2'b0);
    assign       io_master_arlen           =  (a_state_idle & ARBITER_MEM_arvalid) ? ARBITER_MEM_arlen    : ((a_state_idle & ARBITER_IFU_arvalid) ? ARBITER_IFU_arlen   : 8'b0);
    assign       io_master_rready          =  (a_state_ifu  & ARBITER_IFU_rready)  | (a_state_mem & ARBITER_MEM_rready);


    // ===========================================================================
    // 仲裁器当前处理对象和状态机
    logic        [1 : 0]       a_state                                                                ;
    logic        [1 : 0]       a_state_next                                                           ;
    
    // arbiter state
    wire                       a_state_idle      =  (a_state == `ysyx_23060136_idle)                  ;
    wire                       a_state_ifu       =  (a_state == `ysyx_23060136_IFU)                   ;
    wire                       a_state_mem       =  (a_state == `ysyx_23060136_MEM)                   ;


    always_comb begin : state_update
        case(a_state)
            `ysyx_23060136_idle: begin
                if(ARBITER_MEM_arready & ARBITER_MEM_arvalid) begin
                    a_state_next = `ysyx_23060136_MEM;
                end
                else if(ARBITER_IFU_arready & ARBITER_IFU_arvalid)begin
                    a_state_next = `ysyx_23060136_IFU;
                end
                else begin
                    a_state_next = `ysyx_23060136_idle;
                end
            end
            `ysyx_23060136_IFU: begin
                if(ARBITER_IFU_rready & ARBITER_IFU_rvalid) begin
                    a_state_next = `ysyx_23060136_idle;
                end
                else begin
                    a_state_next = `ysyx_23060136_IFU;
                end
            end
            `ysyx_23060136_MEM: begin
                if(ARBITER_MEM_rready & ARBITER_MEM_rvalid) begin
                    a_state_next = `ysyx_23060136_idle;
                end
                else begin
                    a_state_next = `ysyx_23060136_MEM;
                end
            end
            default: a_state_next = `ysyx_23060136_idle;
        endcase 
    end

    
    always_ff @(posedge clk) begin : state_machine
        if(rst) begin
            a_state  <=  `ysyx_23060136_idle;
        end
        else begin
            a_state  <=  a_state_next;
        end
        
    end
                                                            
 endmodule


