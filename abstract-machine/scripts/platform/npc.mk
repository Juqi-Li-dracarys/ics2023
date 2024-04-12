
SIMULATOR_HOME = $(NPC_HOME)/simulator

AM_SRCS := platform/nemu/trm.c \
           platform/nemu/ioe/ioe.c \
           platform/nemu/ioe/timer.c \
           platform/nemu/ioe/input.c \
           platform/nemu/ioe/gpu.c \
           platform/nemu/ioe/audio.c \
           platform/nemu/ioe/disk.c \
           platform/nemu/mpe.c

CFLAGS    += -fdata-sections -ffunction-sections
LDFLAGS   += -T $(AM_HOME)/scripts/linker.ld \
             --defsym=_pmem_start=0x80000000 --defsym=_entry_offset=0x0
LDFLAGS   += --gc-sections -e _start --print-map
NEMUFLAGS += -l $(shell dirname $(IMAGE).elf)/nemu-log.txt
# send the elf dir to the main
NEMUFLAGS += -f $(IMAGE).elf

CFLAGS += -DMAINARGS=\"$(mainargs)\"
CFLAGS += -I$(AM_HOME)/am/src/platform/nemu/include
.PHONY: $(AM_HOME)/am/src/platform/nemu/trm.c

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


