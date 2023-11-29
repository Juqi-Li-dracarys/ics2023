include $(_AM_HOME_)/scripts/isa/loongarch32r.mk
include $(_AM_HOME_)/scripts/platform/nemu.mk
CFLAGS  += -DISA_H=\"loongarch/loongarch32r.h\"

AM_SRCS += loongarch/nemu/start.S \
           loongarch/nemu/cte.c \
           loongarch/nemu/trap.S \
           loongarch/nemu/vme.c
