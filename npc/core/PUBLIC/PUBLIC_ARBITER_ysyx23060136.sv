/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-03-04 12:38:17 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-03-07 22:17:47
 */

 
 `include "DEFINES_ysyx23060136.sv"

 
 // Arbiter for IFU and MEM reading section 
 // ===========================================================================
 module PUBLIC_ARBITER_ysyx23060136 (
    input                              clk                         ,
    input                              rst                         ,
    // ===========================================================================
    // arbiter-IFU interface
    input             [  31:0]         ARBITER_IFU_pc              ,
    input                              ARBITER_IFU_pc_valid        ,
    output                             ARBITER_IFU_pc_ready        ,

    input                              ARBITER_IFU_inst_ready      ,
    // IFU 始终保持对齐，不需要特殊操作
    output    logic   [  63:0]         ARBITER_IFU_inst            ,
    output                             ARBITER_IFU_inst_valid      ,
     // ===========================================================================
    // arbiter-MEM interface   
    input             [  31:0]         ARBITER_MEM_raddr           ,
    input             [   2:0]         ARBITER_MEM_rsize           ,
    input                              ARBITER_MEM_raddr_valid     ,
    output                             ARBITER_MEM_raddr_ready     ,

    output    logic   [  63:0]         ARBITER_MEM_rdata           ,
    output                             ARBITER_MEM_rdata_valid     ,
    input                              ARBITER_MEM_rdata_ready     ,
    output    logic                    ARBITER_error_signal        ,
    // ===========================================================================
    // arbiter-Soc full-axi BUS interface
    input                              io_master_arready           , 
    output                             io_master_arvalid           , 
    output    logic   [  31:0]         io_master_araddr            , 
    output            [   3:0]         io_master_arid              , 
    output            [   7:0]         io_master_arlen             , 
    output    logic   [   2:0]         io_master_arsize            , 
    output            [   1:0]         io_master_arburst           , 
    output                             io_master_rready            , 
    input                              io_master_rvalid            , 
    input             [   1:0]         io_master_rresp             , 
    input             [  63:0]         io_master_rdata             , 
    input                              io_master_rlast             , 
    input             [   3:0]         io_master_rid               
 );


    // 优先级判断，当有 MEM 和 IFU 同时有读要求时，我们优先考虑 MEM 的读操作
    assign       ARBITER_IFU_pc_ready      =  a_state_idle  & ~ARBITER_MEM_raddr_valid              ;
    assign       ARBITER_MEM_raddr_ready   =  a_state_idle                                          ;

    assign       ARBITER_IFU_inst_valid    =  a_state_over  & guest_IFU                             ;
    assign       ARBITER_MEM_rdata_valid   =  a_state_over  & guest_MEM                             ;

    assign       io_master_arvalid         =  a_state_ready                                         ;
    assign       io_master_rready          =  a_state_waiting                                       ;

    // configure
    assign       io_master_arid            =  'b0                                                   ;
    assign       io_master_arlen           =  8'b0000_0000                                          ;
    assign       io_master_arburst         =  2'b00                                                 ;


    // ===========================================================================
    // 仲裁器当前处理对象和状态机
    logic                      guest_obj                                                               ;
    logic        [1 : 0]       a_state                                                                 ;

    // handshake in each state
    wire                       IFU_a_handshake   =   ARBITER_IFU_pc_ready    & ARBITER_IFU_pc_valid    ;
    wire                       MEM_a_handshake   =   ARBITER_MEM_raddr_ready & ARBITER_MEM_raddr_valid ;

    wire                       IFU_d_handshake   =   ARBITER_IFU_inst_ready  & ARBITER_IFU_inst_valid  ;
    wire                       MEM_d_handshake   =   ARBITER_MEM_rdata_ready & ARBITER_MEM_rdata_valid ;

    // arbiter state
    wire                       a_state_idle      =  (a_state == `idle)                                 ;
    wire                       a_state_ready     =  (a_state == `ready)                                ;
    wire                       a_state_waiting   =  (a_state == `waiting)                              ;
    wire                       a_state_over      =  (a_state == `over)                                 ;


    wire         [1 : 0]       a_state_next      =   ({2{a_state_idle}}    & ((IFU_a_handshake   | MEM_a_handshake)                            ? `ready   : `idle))    |
                                                     ({2{a_state_ready}}   & ((io_master_arready & io_master_arvalid)                          ? `waiting : `ready))   |
                                                     ({2{a_state_waiting}} & ((io_master_rready  & io_master_rvalid)                           ? `over    : `waiting)) |
                                                     ({2{a_state_over}}    & (((IFU_d_handshake  & guest_IFU) | (MEM_d_handshake & guest_MEM)) ? `idle    : `over))    ;


    wire                       guest_IFU         =   (guest_obj == `G_IFU);
    wire                       guest_MEM         =   (guest_obj == `G_MEM);                           


    // ===========================================================================                                         
    always_ff @(posedge clk) begin : update_arbiter_state
        if(rst) begin
            a_state  <=  `idle;
        end
        else begin
            a_state  <=  a_state_next;
        end
    end

    always_ff @(posedge clk) begin : addr_trans_to_arbiter
        if(rst) begin
            io_master_araddr  <=  `PC_RST;
            io_master_arsize  <=  'b0;
            guest_obj         <=  'b0;
        end
        else if(a_state_idle & (a_state_next == `ready)) begin
            io_master_araddr  <=   {32{IFU_a_handshake}} & ARBITER_IFU_pc    |
                                   {32{MEM_a_handshake}} & ARBITER_MEM_raddr ;

            io_master_arsize  <=   {3{IFU_a_handshake}}  & 3'b010            |
                                   {3{MEM_a_handshake}}  & ARBITER_MEM_rsize ;
            
            guest_obj         <=   IFU_a_handshake       & `G_IFU            |
                                   MEM_a_handshake       & `G_MEM            ; 
        end
    end


    always_ff @(posedge clk) begin : inst_trans_to_arbiter
        if(rst) begin
            ARBITER_IFU_inst       <=  {32'b0,`NOP};
        end
        else if(a_state_waiting & (a_state_next == `over) & guest_IFU & io_master_rlast)
            begin
            ARBITER_IFU_inst       <=  io_master_rdata;
        end
    end

    
    always_ff @(posedge clk) begin : rdata_trans_to_arbiter
        if(rst) begin
            ARBITER_MEM_rdata  <=  64'b0;
        end
        else if(a_state_waiting & (a_state_next == `over) & guest_MEM & io_master_rlast)
            begin
            ARBITER_MEM_rdata  <=  io_master_rdata;
        end
    end

    always_ff @(posedge clk) begin : update_respond
        if(rst) begin
            ARBITER_error_signal   <=  `false;
        end
        else if(a_state_waiting & a_state_next == `over)
            begin
            ARBITER_error_signal   <=  (io_master_rresp != `OKAY) || (io_master_rid != io_master_arid);
        end
    end

 endmodule


