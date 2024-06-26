/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-06-10 08:58:03 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-06-10 21:32:47
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

`define  ysyx_23060136_CLINT_BASE 64'h02000000
`define  ysyx_23060136_CLINT_END  64'h0200ffff

`define  ysyx_23060136_MMIOB      64'ha0000000
`define  ysyx_23060136_MMIOD      64'hb0000000

`define  ysyx_23060136_PC_RST     64'h80000000
`define  ysyx_23060136_NOP        32'h00000013

 // csr idx  
`define  ysyx_23060136_mepc      'h0
`define  ysyx_23060136_mstatus   'h1
`define  ysyx_23060136_mcause    'h2
`define  ysyx_23060136_mtvec     'h3

`define  ysyx_23060136_mvendorid 'h4
`define  ysyx_23060136_marchid   'h5

// ecall value
`define  ysyx_23060136_ecall_v   'hb

`define  ysyx_23060136_true      'b1
`define  ysyx_23060136_false     'b0

`define  ysyx_23060136_cache_offset 3
`define  ysyx_23060136_cache_index  8
`define  ysyx_23060136_cache_tag    21
`define  ysyx_23060136_cache_ways   2
`define  ysyx_23060136_cache_line   512
`define  ysyx_23060136_cache_group  256

 
// IFU I-cache state
`define ysyx_23060136_icache_idle    0
`define ysyx_23060136_icache_r_hit   1


// MEM D-cache state(read)
`define ysyx_23060136_dcache_idle     'h0
`define ysyx_23060136_dcache_r_hit    'h1
`define ysyx_23060136_dcache_r_dirty  'h2
`define ysyx_23060136_dcache_r_miss   'h3
 

// MEM D-cache state(write)
`define ysyx_23060136_dcache_idle     'h0
`define ysyx_23060136_dcache_w_dirty  'h1
`define ysyx_23060136_dcache_w_wb     'h2
`define ysyx_23060136_dcache_w_al     'h3
`define ysyx_23060136_dcache_w_lo     'h4

// cache config
`define  ysyx_23060136_cache_index  8
`define  ysyx_23060136_cache_tag    21
`define  ysyx_23060136_cache_ways   2
`define  ysyx_23060136_cache_line   512
`define  ysyx_23060136_cache_group  256


// BHT config
`define  ysyx_23060136_BHT_size     512



// ===========================================================================


// AXI state machine
`define  ysyx_23060136_idle      'h0
`define  ysyx_23060136_ready     'h1
`define  ysyx_23060136_wait      'h2
 

// arbiter state machine
`define  ysyx_23060136_IFU       'd1
`define  ysyx_23060136_MEM       'd2


 // response signal
`define  ysyx_23060136_OKAY      'b00
`define  ysyx_23060136_EXOKAY    'b01
`define  ysyx_23060136_SLVERR    'b10
`define  ysyx_23060136_DECERR    'b11


// // Use wallace-booth multiplyer
// `define  ysyx_23060136_WALLACE    1


// // Use multi-cycle divider
// `define  ysyx_23060136_DIV        1


 // enable bench counter
`define bench_counter             1



