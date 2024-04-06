/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-03-16 11:55:45 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-03-16 15:44:55
 */


 `include "DEFINES_ysyx_23060136.sv"


 // CLINT module support time reading
 // protocol: easy  AXI-lite
 // ===========================================================================
 module CLINT_ysyx_23060136 (
    input                              clk                       ,
    input                              rst                       ,
    // ===========================================================================
    input             [  31:0]         CLINT_MEM_raddr           ,
    input             [   2:0]         CLINT_MEM_rsize           ,
    input                              CLINT_MEM_raddr_valid     ,
    output                             CLINT_MEM_raddr_ready     ,

    output            [  63:0]         CLINT_MEM_rdata           ,
    output                             CLINT_MEM_rdata_valid     ,
    input                              CLINT_MEM_rdata_ready     
 );

    wire                     access_mtime          =  (CLINT_MEM_raddr >= `CLINT_BASE + `MTIME_OFFSET && CLINT_MEM_raddr < `CLINT_BASE + `MTIME_OFFSET + 'h8) ;
    assign                   CLINT_MEM_rdata       =  access_mtime ? mtime : 64'b0                     ;
    assign                   CLINT_MEM_raddr_ready =  access_mtime & CLINT_MEM_raddr_valid             ;
    assign                   CLINT_MEM_rdata_valid =  CLINT_MEM_rdata_ready                            ;

    logic    [63 : 0]        mtime                                                                     ;

    always_ff @(posedge clk) begin : update_time
        if(rst) begin
            mtime  <=  64'b0;
        end
        else begin
            mtime  <=  mtime + 64'b1;
        end
    end

endmodule

