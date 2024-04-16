#/
 # @Author: Juqi Li @ NJU 
 # @Date: 2024-03-03 20:14:37 
 # @Last Modified by:   Juqi Li @ NJU 
 # @Last Modified time: 2024-03-03 20:14:37 
#/

# add waves for pipeline CPU
set sig_list [list]

# TOP module
lappend sig_list "cpu.clock"
lappend sig_list "cpu.reset"
lappend sig_list "cpu.pc_cur"
lappend sig_list "cpu.inst"

# IFU
lappend sig_list "ysyx_23060136_IFU_TOP_inst.IFU_o_pc"
lappend sig_list "ysyx_23060136_IFU_TOP_inst.IFU_o_inst"
lappend sig_list "ysyx_23060136_IFU_TOP_inst.IFU_o_valid"

# IDU
lappend sig_list "ysyx_23060136_IDU_TOP_inst.IDU_o_pc"
lappend sig_list "ysyx_23060136_IDU_TOP_inst.IDU_o_inst"

# EXU
lappend sig_list "ysyx_23060136_EXU_TOP_inst.EXU_o_pc"
lappend sig_list "ysyx_23060136_EXU_TOP_inst.EXU_o_inst"

# MEM
lappend sig_list "ysyx_23060136_MEM_TOP_inst.MEM_o_pc"
lappend sig_list "ysyx_23060136_MEM_TOP_inst.MEM_o_inst"
lappend sig_list "ysyx_23060136_MEM_TOP_inst.MEM_i_mem_to_reg"
lappend sig_list "ysyx_23060136_MEM_TOP_inst.MEM_i_write_mem"

# ARBITER
lappend sig_list "ysyx_23060136_ARBITER_inst.io_master_araddr"
lappend sig_list "ysyx_23060136_ARBITER_inst.io_master_rdata"


gtkwave::addSignalsFromList $sig_list

