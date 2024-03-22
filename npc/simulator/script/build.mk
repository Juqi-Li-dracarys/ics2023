# /*
#  * @Author: Juqi Li @ NJU 
#  * @Date: 2024-01-16 13:22:39 
#  * @Last Modified by:   Juqi Li @ NJU 
#  * @Last Modified time: 2024-03-22 11:22:39 
#  */

IMG ?= 
VERILATOR = verilator
ARGS_DIFF = --diff=$(NEMUISO)
SILENT = -s
BATCH_MODE = -b

override ARGS ?= --log=$(OBJ_DIR)/npc-log.txt
override ARGS += $(ARGS_DIFF)

$(VBIN): $(CSRC) $(VSRC) $(NVBOARD_ARCHIVE)
	@echo "$(COLOR_YELLOW)[VERILATOR]$(COLOR_NONE) $(VBIN)"
	@echo "$(COLOR_YELLOW)[GENERATE]$(COLOR_NONE) Creating System Verilog Model"
	@$(VERILATOR) $(VFLAGS) $^ $(CINC_PATH)
	@echo "$(COLOR_YELLOW)[COMPILE]$(COLOR_NONE) Compiling C++ files"
	@$(MAKE) $(SILENT) -C $(OBJ_DIR) -f $(REWRITE)
	@echo $(CPU_ARCH)

$(NEMUISO):
	@echo "$(COLOR_YELLOW)[Make DIFF]$(COLOR_NONE) $(notdir $(NEMU_DIR))/build/riscv32-nemu-interpreter-so"
	@$(MAKE) -C $(NEMU_DIR)

# constraint file
$(SRC_AUTO_BIND): $(NXDC_FILES)
	$(shell mkdir -p $(OBJ_DIR))
	python3 $(NVBOARD_HOME)/scripts/auto_pin_bind.py $^ $@

run: $(VBIN) $(NEMUISO) $(IMG)
	@echo "$(COLOR_YELLOW)[RUN IMG]$(COLOR_NONE)" $(notdir $(IMG))
	$(call git_commit, "RUN NPC")
	@$(VBIN) $(ARGS) $(IMG)

test: $(VBIN) $(NEMUISO) $(IMG)
	@echo "$(COLOR_YELLOW)[RUN IMG]$(COLOR_NONE)" $(notdir $(IMG))
	$(call git_commit, "RUN NPC")
	@$(VBIN) $(ARGS) $(BATCH_MODE) $(IMG)

gdb: $(VBIN) $(NEMUISO) $(IMG)
	@echo "$(COLOR_YELLOW)[GDB IMG]$(COLOR_NONE)" $(notdir $(IMG))
	$(call git_commit, "GDB NPC")
	@gdb -s $(VBIN) --args $(VBIN) $(ARGS) $(IMG)

wave: run
	@gtkwave waveform.vcd $(GTKFLAGS)


clean:
	@echo rm -rf OBJ_DIR *vcd
	@rm -rf $(OBJ_DIR)
	@rm -rf *.vcd

clean-all:
	@echo rm -rf OBJ_DIR *vcd NEMU_DIFF
	@rm -rf $(OBJ_DIR)
	@rm -rf *.vcd
	@make -s -C $(NEMU_DIR) clean

.PHONY: run gdb wave clean-all clean
