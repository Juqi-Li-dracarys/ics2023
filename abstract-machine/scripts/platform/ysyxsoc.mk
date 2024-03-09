#/*
# * @Author: Juqi Li @ NJU 
# * @Date: 2024-03-08 23:32:08 
# * @Last Modified by:   Juqi Li @ NJU 
# * @Last Modified time: 2024-03-08 23:32:08 
# */

SIMULATOR_HOME = $(NPC_HOME)/simulator

AM_SRCS := riscv/ysyxsoc/start.S \
           riscv/ysyxsoc/trm.c \
           riscv/ysyxsoc/cte.c \
           riscv/ysyxsoc/trap.S \
           platform/dummy/vme.c \
           platform/dummy/mpe.c

CFLAGS    += -fdata-sections -ffunction-sections

LDFLAGS   += -T $(AM_HOME)/scripts/linker.ld \
						 --defsym=_pmem_start=0x80000000 --defsym=_entry_offset=0x0

LDFLAGS   += --gc-sections -e _start
CFLAGS += -DMAINARGS=\"$(mainargs)\"
CFLAGS += -I$(AM_HOME)/am/src/riscv/ysyxsoc/include

.PHONY: $(AM_HOME)/am/src/riscv/ysyxsoc/trm.c

NPC_FLAGS += -l $(shell dirname $(IMAGE).elf)/ysyxsoc-log.txt
# send the elf dir to the main
NPC_FLAGS += -f $(IMAGE).elf


image: $(IMAGE).elf
	@$(OBJDUMP) -d $(IMAGE).elf > $(IMAGE).txt
	@echo + OBJCOPY "->" $(IMAGE_REL).bin
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