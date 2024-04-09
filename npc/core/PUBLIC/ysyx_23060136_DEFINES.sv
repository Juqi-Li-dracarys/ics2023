/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-04-05 12:40:17 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-04-06 23:42:51
 */

// ===========================================================================
 
// width of CPU'bits and inst
`define  ysyx_23060136_BITS_W     64
// log(64)
`define  ysyx_23060136_BITS_S     6

`define  ysyx_23060136_INST_W     32

`define  ysyx_23060136_GPR_NUM    32
`define  ysyx_23060136_GPR_W      5

`define  ysyx_23060136_CSR_NUM    6
`define  ysyx_23060136_CSR_W      3

// NPC addr space specification
`define  ysyx_23060136_MBASE      64'h80000000
`define  ysyx_23060136_MEND       64'h88000000

`define  ysyx_23060136_true      'b1
`define  ysyx_23060136_false     'b0

`define  ysyx_23060136_PC_RST     64'h80000000
`define  ysyx_23060136_NOP        32'h00000013


// AXI-lite machine state(arbiter)
`define  ysyx_23060136_ready     'h1
`define  ysyx_23060136_wait      'h2
 // only for writing
`define  ysyx_23060136_done      'h2

 // state for ALU
`define  ysyx_23060136_idle      'h0
`define  ysyx_23060136_ready_mul 'h1
`define  ysyx_23060136_ready_div 'h2
`define  ysyx_23060136_wait_mul  'h3
`define  ysyx_23060136_wait_div  'h4



// csr idx   
`define  ysyx_23060136_mstatus   'h0
`define  ysyx_23060136_mtvec     'h1
`define  ysyx_23060136_mepc      'h2
`define  ysyx_23060136_mcause    'h3
`define  ysyx_23060136_mvendorid 'h4
`define  ysyx_23060136_marchid   'h5


// arbiter state machine(read)
`define  ysyx_23060136_idle      'h0
`define  ysyx_23060136_ready     'h1
`define  ysyx_23060136_wait      'h3
`define  ysyx_23060136_over      'h2


// arbiter handling guests
`define  ysyx_23060136_G_IFU     'd0
`define  ysyx_23060136_G_MEM     'd1

