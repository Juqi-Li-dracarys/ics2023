/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-02-14 18:25:21 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-02-16 14:06:07
 */

 `include "IFU_DEFINES_ysyx23060136.sv"

// We set ROM as an independent module for IFU
//////////////////////////////////////////////////////////////////

module IFU_ROM_ysyx23060136(
        input                       clk,
        input                       rst,
        input  logic [31 : 0]       r_addr,
        output logic [31 : 0]       r_data,
        output                      data_valid
    );

    import "DPI-C" function int pmem_read(input int raddr);

    // temp reg to store raddr
    logic [31 : 0] temp_addr;

    // check if it is same
    logic          data_check  = (temp_addr == r_addr);

    // 暂时存放地址
    always_ff @(posedge clk) begin
        if(rst) begin
            temp_addr <= `PC_RST;
        end
        else begin
            temp_addr <= r_addr;
        end
    end

    always_ff @(posedge clk) begin: update_data
        if(data_check) begin
            data_valid <= `true;
            r_data <= pmem_read(r_addr);
        end
        else begin
            data_valid <= `false;
            r_data <= 32'b0;
        end
    end

endmodule



