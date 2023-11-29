include $(_AM_HOME_)/scripts/isa/riscv.mk
include $(_AM_HOME_)/scripts/platform/nemu.mk
CFLAGS  += -DISA_H=\"riscv/riscv.h\"

AM_SRCS += riscv/nemu/start.S \
           riscv/nemu/cte.c \
           riscv/nemu/trap.S \
           riscv/nemu/vme.c
