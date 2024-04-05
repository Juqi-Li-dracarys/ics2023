/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-04-05 12:40:17 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-04-05 17:46:55
 */


// width of CPU'bits and inst
`define  ysyx23060136_BITS_W     64
`define  ysyx23060136_INST_W     32

// NPC addr space specification
`define  ysyx23060136_MBASE      64'h80000000
`define  ysyx23060136_MEND       64'h88000000

`define  ysyx23060136_true      'b1
`define  ysyx23060136_false     'b0

`define  ysyx23060136_PC_RST     64'h80000000
`define  ysyx23060136_NOP        32'h00000013


// AXI-lite machine state
`define  ysyx23060136_idle      'h0
`define  ysyx23060136_busy      'h1
// only for writing
`define  ysyx23060136_done      'h2

// csr idx   
`define  ysyx23060136_mstatus   'h0 
`define  ysyx23060136_mtvec     'h1
`define  ysyx23060136_mepc      'h2
`define  ysyx23060136_mcause    'h3
`define  ysyx23060136_mvendorid 'h4
`define  ysyx23060136_marchid   'h5


// arbiter state machine(read)
`define  ysyx23060136_idle      'h0
`define  ysyx23060136_ready     'h1
`define  ysyx23060136_waiting   'h2
`define  ysyx23060136_over      'h3

// arbiter handling guests
`define  ysyx23060136_G_IFU     'd0
`define  ysyx23060136_G_MEM     'd1
