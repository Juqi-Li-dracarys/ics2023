/***************************************************************************************
* Copyright (c) 2014-2022 Zihao Yu, Nanjing University
*
* NEMU is licensed under Mulan PSL v2.
* You can use this software according to the terms and conditions of the Mulan PSL v2.
* You may obtain a copy of Mulan PSL v2 at:
*          http://license.coscl.org.cn/MulanPSL2
*
* THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
* EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
* MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
*
* See the Mulan PSL v2 for more details.
***************************************************************************************/

#include "local-include/reg.h"
#include <cpu/cpu.h>
#include <cpu/ifetch.h>
#include <cpu/decode.h>

#define R(i) gpr(i)
#define Mr vaddr_read
#define Mw vaddr_write

enum {
  TYPE_I, TYPE_U, TYPE_S, TYPE_J, TYPE_B, TYPE_RE,
  TYPE_N // none
};

// rs转寄存器的数
#define src1R() do { *src1 = R(rs1); } while (0)
#define src2R() do { *src2 = R(rs2); } while (0)
// 提取立即数部分
#define immI() do { *imm = SEXT(BITS(i, 31, 20), 12); } while(0)
#define immU() do { *imm = SEXT(BITS(i, 31, 12), 20) << 12; } while(0)
#define immS() do { *imm = (SEXT(BITS(i, 31, 25), 7) << 5) | BITS(i, 11, 7); } while(0)
#define immJ() do { *imm = SEXT(BITS(i, 31, 31) << 19 | BITS(i, 30, 21) | BITS(i, 20, 20) << 10 | BITS(i, 19, 12) << 11, 20); } while(0)
#define immB() do { *imm = SEXT(BITS(i, 31, 31) << 11 | BITS(i, 30, 25) << 4 | BITS(i, 11, 8) | BITS(i, 7, 7) << 10, 12); } while(0)

// 提取指令的各个参数
static void decode_operand(Decode *s, int *rd, word_t *src1, word_t *src2, word_t *imm, int type) {
  uint32_t i = s->isa.inst.val;
  int rs1 = BITS(i, 19, 15);
  int rs2 = BITS(i, 24, 20);
  *rd     = BITS(i, 11, 7);
  switch (type) {
    case TYPE_I: src1R();          immI(); break;
    case TYPE_U:                   immU(); break;
    case TYPE_S: src1R(); src2R(); immS(); break;
    case TYPE_J:                   immJ(); break;
    case TYPE_B: src1R(); src2R(); immB(); break;
    case TYPE_RE: src1R(); src2R();        break;
    default: break;
  }
}

static int decode_exec(Decode *s) {
  int rd = 0;
  word_t src1 = 0, src2 = 0, imm = 0;
  s->dnpc = s->snpc;

#define INSTPAT_INST(s) ((s)->isa.inst.val)
#define INSTPAT_MATCH(s, name, type, ... /* execute body */ ) { \
  decode_operand(s, &rd, &src1, &src2, &imm, concat(TYPE_, type)); \
  __VA_ARGS__ ; \
}

  INSTPAT_START();
  INSTPAT("??????? ????? ????? ??? ????? 0010111", auipc  , U, R(rd) = s->pc + imm);
  INSTPAT("??????? ????? ????? ??? ????? 0110111", lui    , U, R(rd) = imm;);

  INSTPAT("0000000 ????? ????? 000 ????? 0110011", add    ,RE, R(rd) = src1 + src2);
  INSTPAT("0100000 ????? ????? 000 ????? 0110011", sub    ,RE, R(rd) = src1 - src2);
  INSTPAT("0000000 ????? ????? 011 ????? 0110011", sltu   ,RE, R(rd) = (src1 < src2));
  INSTPAT("0000000 ????? ????? 110 ????? 0110011", or     ,RE, R(rd) = (src1 | src2));
  INSTPAT("0000000 ????? ????? 100 ????? 0110011", xor    ,RE, R(rd) = (src1 ^ src2));
  INSTPAT("0000000 ????? ????? 111 ????? 0110011", and    ,RE, R(rd) = (src1 & src2));
  INSTPAT("0000001 ????? ????? 000 ????? 0110011", mul    ,RE, R(rd) = (word_t)(src1 * src2));
  INSTPAT("0000001 ????? ????? 100 ????? 0110011", div    ,RE, R(rd) = (word_t)((int32_t)src1 / (int32_t)src2));
  INSTPAT("0000001 ????? ????? 101 ????? 0110011", divu   ,RE, R(rd) = (word_t)(src1 / src2));
  INSTPAT("0000001 ????? ????? 110 ????? 0110011", rem    ,RE, R(rd) = (word_t)((int32_t)src1 % (int32_t)src2));
  INSTPAT("0000001 ????? ????? 111 ????? 0110011", remu   ,RE, R(rd) = (word_t)(src1 % src2));
  INSTPAT("0000000 ????? ????? 001 ????? 0110011", sll    ,RE, R(rd) = (src1 << BITS(src2, 4, 0)));
  INSTPAT("0000000 ????? ????? 010 ????? 0110011", slt    ,RE, R(rd) = (((int32_t)src1) < ((int32_t)src2)));
  INSTPAT("0000001 ????? ????? 001 ????? 0110011", mulh   ,RE, R(rd) = (word_t)((((int64_t)((int32_t)src1)) * ((int64_t)((int32_t)src2))) >> 32));
  INSTPAT("0100000 ????? ????? 101 ????? 0110011", sra    ,RE, R(rd) = (uint32_t)((int32_t)src1 >> BITS(src2, 4, 0)));
  INSTPAT("0000000 ????? ????? 101 ????? 0110011", srl    ,RE, R(rd) = (src1 >> BITS(src2, 4, 0)));

  INSTPAT("??????? ????? ????? 000 ????? 0010011", addi   , I, R(rd) = src1 - imm);                                         
  INSTPAT("??????? ????? ????? 000 ????? 1100111", jalr   , I, R(rd) = s->pc + 4; s->dnpc = (src1 + imm) & (~(word_t)0x01);); 
  INSTPAT("??????? ????? ????? 100 ????? 0000011", lbu    , I, R(rd) = Mr(src1 + imm, 1));
  INSTPAT("??????? ????? ????? 010 ????? 0000011", lw     , I, R(rd) = Mr(src1 + imm, 4));
  INSTPAT("??????? ????? ????? 001 ????? 0000011", lh     , I, R(rd) = SEXT(Mr(src1 + imm, 2), 16));
  INSTPAT("??????? ????? ????? 101 ????? 0000011", lhu    , I, R(rd) = Mr(src1 + imm, 2));
  INSTPAT("??????? ????? ????? 011 ????? 0010011", sltiu  , I, R(rd) = (src1 < imm));
  INSTPAT("010000? ????? ????? 101 ????? 0010011", srai   , I, R(rd) = BITS(imm, 5, 5)==0 ? (word_t)(((int32_t)src1) >> BITS(imm, 5, 0)) : R(rd));
  INSTPAT("??????? ????? ????? 111 ????? 0010011", andi   , I, R(rd) = (src1 & imm));
  INSTPAT("??????? ????? ????? 100 ????? 0010011", xori   , I, R(rd) = (src1 ^ imm));
  INSTPAT("000000? ????? ????? 101 ????? 0010011", srli   , I, R(rd) = BITS(imm, 5, 5)==0 ? (src1 >> BITS(imm, 5, 0)) : R(rd));
  INSTPAT("000000? ????? ????? 001 ????? 0010011", slli   , I, R(rd) = BITS(imm, 5, 5)==0 ? (src1 << BITS(imm, 5, 0)) : R(rd));

  INSTPAT("??????? ????? ????? 000 ????? 0100011", sb     , S, Mw(src1 + imm, 1, src2));
  INSTPAT("??????? ????? ????? 010 ????? 0100011", sw     , S, Mw(src1 + imm, 4, src2));
  INSTPAT("??????? ????? ????? 001 ????? 0100011", sh     , S, Mw(src1 + imm, 2, src2));

  INSTPAT("??????? ????? ????? ??? ????? 1101111", jal    , J, R(rd) = s->pc + 4; s->dnpc = s->pc + (imm << 1));

  INSTPAT("??????? ????? ????? 000 ????? 1100011", beq    , B, s->dnpc = (src1 == src2) ? s->pc + (imm << 1) : s->dnpc);
  INSTPAT("??????? ????? ????? 001 ????? 1100011", bne    , B, s->dnpc = (src1 != src2) ? s->pc + (imm << 1) : s->dnpc);
  INSTPAT("??????? ????? ????? 101 ????? 1100011", bge    , B, s->dnpc = ((int32_t)src1 >= (int32_t)src2) ? s->pc + (imm << 1) : s->dnpc);
  INSTPAT("??????? ????? ????? 111 ????? 1100011", bgeu   , B, s->dnpc = (src1 >= src2) ? s->pc + (imm << 1) : s->dnpc);
  INSTPAT("??????? ????? ????? 100 ????? 1100011", blt    , B, s->dnpc = ((int32_t)src1 < (int32_t)src2) ? s->pc + (imm << 1) : s->dnpc);
  INSTPAT("??????? ????? ????? 110 ????? 1100011", bltu   , B, s->dnpc = (src1 < src2) ? s->pc + (imm << 1) : s->dnpc);

  INSTPAT("0000000 00001 00000 000 00000 1110011", ebreak , N, NEMUTRAP(s->pc, R(10))); // 以抛出异常的方式提醒调试器 R(10) is $a0
  INSTPAT("??????? ????? ????? ??? ????? ???????", inv    , N, INV(s->pc));
  INSTPAT_END();

  R(0) = 0; // reset $zero to 0

  return 0;
}

int isa_exec_once(Decode *s) {
  s->isa.inst.val = inst_fetch(&s->snpc, 4);
  return decode_exec(s);
}
