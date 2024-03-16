SIMULATOR_HOME = $(NPC_HOME)/simulator

AM_SRCS := riscv/npc/start.S \
           riscv/npc/trm.c \
           riscv/npc/ioe.c \
           riscv/npc/timer.c \
           riscv/npc/input.c \
           riscv/npc/cte.c \
           riscv/npc/trap.S \
           platform/dummy/vme.c \
           platform/dummy/mpe.c

CFLAGS    += -fdata-sections -ffunction-sections
LDFLAGS   += -T $(AM_HOME)/scripts/linker.ld \
						 --defsym=_pmem_start=0x80000000 --defsym=_entry_offset=0x0
LDFLAGS   += --gc-sections -e _start
CFLAGS += -DMAINARGS=\"$(mainargs)\"
CFLAGS += -I$(AM_HOME)/am/src/riscv/npc/include

.PHONY: $(AM_HOME)/am/src/riscv/npc/trm.c

NPC_FLAGS += -l $(shell dirname $(IMAGE).elf)/npc-log.txt
# send the elf dir to the main
NPC_FLAGS += -f $(IMAGE).elf


image: $(IMAGE).elf
	@$(OBJDUMP) -d $(IMAGE).elf > $(IMAGE).txt
	@echo + OBJCOPY "->" $(IMAGE_REL).bin
	@$(OBJCOPY) -S --set-section-flags .bss=alloc,contents -O binary $(IMAGE).elf $(IMAGE).bin

# load the image on npc simulator

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