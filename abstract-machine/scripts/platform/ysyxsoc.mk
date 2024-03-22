#/*
# * @Author: Juqi Li @ NJU 
# * @Date: 2024-03-08 23:32:08 
# * @Last Modified by:   Juqi Li @ NJU 
# * @Last Modified time: 2024-03-08 23:32:08 
# */


# The operation of eliminating the unused code and data from 
# the final executable is directly performed by the linker.
# In order to do this, it has to work with objects compiled 
# with the following options: -ffunction-sections -fdata-sections.
# These options are usable with C and Ada files. 
# They will place respectively each function or data 
# in a separate section in the resulting object file.
# Once the objects and static libraries are created with these options, 
# the linker can perform the dead code elimination. You can do this by 
# setting the -Wl,–gc-sections option to gcc command or in the -largs section of gnatmake. 
# This will perform a garbage collection of code and data never referenced.
# If the linker performs a partial link (-r linker option),
#  then you will need to provide the entry point using the -e / --entry linker option.
# Note that objects compiled without the -ffunction-sections 
# and -fdata-sections options can still be linked with the executable. 
# However, no dead code elimination will be performed on those objects (they will be linked as is).
# The GNAT static library is now compiled with -ffunction-sections and 
# -fdata-sections on some platforms. This allows you to eliminate 
# the unused code and data of the GNAT library from your executable.



SIMULATOR_HOME = $(NPC_HOME)/simulator

AM_SRCS := riscv/ysyxsoc/start.S \
           riscv/ysyxsoc/trm.c \
           riscv/ysyxsoc/cte.c \
           riscv/ysyxsoc/trap.S \
		   riscv/ysyxsoc/ioe/ioe.c\
		   riscv/ysyxsoc/ioe/timer.c \
           platform/dummy/vme.c \
           platform/dummy/mpe.c

CFLAGS    += -fdata-sections -ffunction-sections

LDFLAGS   += -T $(AM_HOME)/scripts/SoC_linker.ld

LDFLAGS   += --gc-sections -e _start --print-map
CFLAGS += -DMAINARGS=\"$(mainargs)\"
CFLAGS += -I$(AM_HOME)/am/src/riscv/ysyxsoc/include

.PHONY: $(AM_HOME)/am/src/riscv/ysyxsoc/trm.c

NPC_FLAGS += -l $(shell dirname $(IMAGE).elf)/ysyxsoc-log.txt
# send the elf dir to the main
NPC_FLAGS += -f $(IMAGE).elf


image: $(IMAGE).elf
	@$(OBJDUMP) -d $(IMAGE).elf > $(IMAGE).txt
	@echo + OBJCOPY "->" $(IMAGE_REL).bin
# 这里埋个雷
# @$(OBJCOPY) -S -O binary $(IMAGE).elf $(IMAGE).bin
	@$(OBJCOPY) -S --set-section-flags .bss=alloc,contents -O binary $(IMAGE).elf $(IMAGE).bin


# load the image on ysyxsoc simulator
run: image
	@echo + Load "->" $(IMAGE).bin
	$(MAKE) -C $(SIMULATOR_HOME) ARGS="$(NPC_FLAGS)" IMG="$(IMAGE).bin" run

wave: image
	@echo + Load "->" $(IMAGE).bin
	$(MAKE) -C $(SIMULATOR_HOME) ARGS="$(NPC_FLAGS)" IMG="$(IMAGE).bin" wave

gdb: image
	@echo + Load "->" $(IMAGE).bin
	$(MAKE) -C $(SIMULATOR_HOME) ARGS="$(NPC_FLAGS)" IMG="$(IMAGE).bin" gdb

test: image
	@echo + Load "->" $(IMAGE).bin
	$(MAKE) -C $(SIMULATOR_HOME) ARGS="$(NPC_FLAGS)" IMG="$(IMAGE).bin" test

