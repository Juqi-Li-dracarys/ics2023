/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-04-11 14:12:42 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-04-11 14:26:47
 */


 `include "ysyx_23060136_DEFINES.sv"


 // CLINT module support time reading
 // protocol: easy  AXI-lite
 // ===========================================================================
 module ysyx_23060136_CLINT (
    input                                                   clk                       ,
    input                                                   rst                       ,
    // ===========================================================================
    input             [  `ysyx_23060136_BITS_W-1:0]         CLINT_MEM_raddr           ,
    input             [   2:0]                              CLINT_MEM_rsize           ,
    input                                                   CLINT_MEM_raddr_valid     ,
    output                                                  CLINT_MEM_raddr_ready     ,

    output            [  `ysyx_23060136_BITS_W-1:0]         CLINT_MEM_rdata           ,
    output                                                  CLINT_MEM_rdata_valid     ,
    input                                                   CLINT_MEM_rdata_ready     
 );

    wire                     access_mtime           =  (CLINT_MEM_raddr >= `ysyx_23060136_CLINT_BASE && CLINT_MEM_raddr < `ysyx_23060136_CLINT_BASE + 'h8) ;
    assign                   CLINT_MEM_rdata        =  access_mtime ? mtime : 64'b0                     ;
    assign                   CLINT_MEM_raddr_ready  =  access_mtime & CLINT_MEM_raddr_valid             ;
    assign                   CLINT_MEM_rdata_valid  =  CLINT_MEM_rdata_ready                            ;

    logic    [`ysyx_23060136_BITS_W-1 : 0]        mtime                                                 ;

    always_ff @(posedge clk) begin : update_time
        if(rst) begin
            mtime  <=  64'b0;
        end
        else begin
            mtime  <=  mtime + 64'b1;
        end
    end

endmodule

