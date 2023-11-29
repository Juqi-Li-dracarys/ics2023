include $(_AM_HOME_)/scripts/isa/riscv.mk

AM_SRCS := riscv/spike/trm.c \
           riscv/spike/ioe.c \
           riscv/spike/timer.c \
           riscv/spike/start.S \
           riscv/spike/htif.S \
           platform/dummy/cte.c \
           platform/dummy/vme.c \
           platform/dummy/mpe.c \

CFLAGS    += -fdata-sections -ffunction-sections
LDFLAGS   += -T $(_AM_HOME_)/am/src/riscv/spike/linker.ld
LDFLAGS   += --gc-sections -e _start

CFLAGS += -DMAINARGS=\"$(mainargs)\"
.PHONY: $(_AM_HOME_)/am/src/riscv/spike/trm.c

image: $(IMAGE).elf
