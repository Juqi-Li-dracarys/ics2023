#/*
# * @Author: Juqi Li @ NJU 
# * @Date: 2024-03-08 10:58:08 
# * @Last Modified by:   Juqi Li @ NJU 
# * @Last Modified time: 2024-03-08 10:58:08 
# */

# Copy from AM_HOME makefile

SIMULATOR_HOME = $(NPC_HOME)/simulator
WORK_DIR      = $(shell pwd)
CSCR          = $(shell find $(WORK_DIR) -name "*.c")
OBJ           = $(CSCR:%.c=%.o)
IMG           = $(CSCR:%.c=%.bin)
CFLAGS        = -std=gnu11 -O2 -g -MMD -Wall -Werror -fno-asynchronous-unwind-tables \
				 -fno-builtin -fno-stack-protector -Wno-main -U_FORTIFY_SOURCE -fno-pic \
				-march=rv64g -mcmodel=medany -mstrict-align -march=rv32e_zicsr -mabi=ilp32e \
				-static -fdata-sections -ffunction-sections

CROSS_COMPILE = riscv64-linux-gnu

%.o:%.c
	$(CROSS_COMPILE)-gcc $(CFLAGS) -c -o $@ $<

$(IMG):$(OBJ)
	$(CROSS_COMPILE)-objcopy -S -O binary $< $@
	$(CROSS_COMPILE)-objdump -d $< > $(OBJ:%.o=%.txt)


run: $(IMG)
	$(MAKE) -C $(SIMULATOR_HOME) IMG="$(IMG)" run

wave: $(IMG)
	$(MAKE) -C $(SIMULATOR_HOME) IMG="$(IMG)" wave

clean:
	rm -rf *.o *.d *.bin

default: $(OBJ)

