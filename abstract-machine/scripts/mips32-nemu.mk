include $(_AM_HOME_)/scripts/isa/mips32.mk
include $(_AM_HOME_)/scripts/platform/nemu.mk
CFLAGS  += -DISA_H=\"mips/mips32.h\"

AM_SRCS += mips/nemu/start.S \
           mips/nemu/cte.c \
           mips/nemu/trap.S \
           mips/nemu/vme.c
