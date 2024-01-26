/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-01-17 15:48:16 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-01-17 21:20:00
 */

#include <common.h>
#include <reg.h>

const char *regs[] = {
  "$0", "ra", "sp", "gp", "tp", "t0", "t1", "t2",
  "s0", "s1", "a0", "a1", "a2", "a3", "a4", "a5",
  "mepc", "mstatus", "mcause", "mtvec"
};


// print the value of each register
void isa_reg_display() {
    puts("ALL register in npc:");
    for (int i = 0; i < MUXDEF(CONFIG_RVE, 16, 32) + 4; i++) {
        if (i < MUXDEF(CONFIG_RVE, 16, 32)) printf("%s:0X%08x ", regs[i], gpr(i));
        else printf("%s:0X%08x ", regs[i], csr(i - MUXDEF(CONFIG_RVE, 16, 32)));
        if ((i + 1) % 4 == 0)
            putchar('\n');
    }
    return;
}

// return the value of register
word_t isa_reg_str2val(const char* s, bool* success) {
    if (!strcmp(s, "pc")) {
        *success = true;
        return dut->pc_cur;
    }
    for (int i = 0; i < MUXDEF(CONFIG_RVE, 16, 32) + 4; i++) {
        if (strcmp(regs[i], s) == 0) {
            *success = 1;
            return i < MUXDEF(CONFIG_RVE, 16, 32) ? gpr(i) : csr(i - MUXDEF(CONFIG_RVE, 16, 32));
        }
    }
    *success = 0;
    return 0;
}

// set cpu_gpr point to your cpu's gpr
extern "C" void set_gpr_ptr(const svOpenArrayHandle r) {
  cpu_gpr = (uint32_t *)(((VerilatedDpiOpenVar*)r)->datap());
}

// set the pointers pint to you cpu's csr
extern "C" void set_csr_ptr(const svLogicVecVal *mstatus, const svLogicVecVal *mtvec, const svLogicVecVal *mepc, const svLogicVecVal *mcause) {
  cpu_mstatus = (uint32_t *)(((VerilatedDpiOpenVar*)mstatus)->datap());
  cpu_mtvec = (uint32_t *)(((VerilatedDpiOpenVar*)mtvec)->datap());
  cpu_mepc = (uint32_t *)(((VerilatedDpiOpenVar*)mepc)->datap());
  cpu_mcause = (uint32_t *)(((VerilatedDpiOpenVar*)mcause)->datap());
}