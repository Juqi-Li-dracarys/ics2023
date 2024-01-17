# /*
#  * @Author: Juqi Li @ NJU 
#  * @Date: 2024-01-16 13:22:39 
#  * @Last Modified by:   Juqi Li @ NJU 
#  * @Last Modified time: 2024-01-16 13:22:39 
#  */

IMG ?= 
VERILATOR = verilator
ARGS_DIFF = --diff=$(NEMUISO)

override ARGS ?= --log=$(OBJ_DIR)/nemu-log.txt
override ARGS += $(ARGS_DIFF)

$(VBIN): $(CSRC) $(VSRC)
	@echo "$(COLOR_YELLOW)[VERILATOR]$(COLOR_NONE) $(notdir $(OBJ_DIR))/VCPU_TOP"
	@echo "$(COLOR_YELLOW)[GENERATE]$(COLOR_NONE) Creating System Verilog Model"
	@$(VERILATOR) $(VFLAGS) $(VSRC) $(CSRC) $(CINC_PATH)
	@echo "$(COLOR_YELLOW)[COMPILE]$(COLOR_NONE) Compiling C++ files"
	@make -C $(OBJ_DIR) -f $(REWRITE)

$(NEMUISO):
	@echo "$(COLOR_YELLOW)[Make DIFF]$(COLOR_NONE) $(notdir $(NEMU_DIR))/build/riscv32-nemu-interpreter-so"
	@make -C $(NEMU_DIR)

run: $(VBIN) $(NEMUISO) $(IMG)
	@echo "$(COLOR_YELLOW)[RUN IMG]$(COLOR_NONE)" $(notdir $(IMG))
	$(call git_commit, "RUN NPC")
	@$(VBIN) $(ARGS) $(IMG)

gdb: $(VBIN) $(NEMUISO) $(IMG)
	@echo "$(COLOR_YELLOW)[GDB IMG]$(COLOR_NONE)" $(notdir $(IMG))
	$(call git_commit, "GDB NPC")
	@gdb -s $(VBIN) --args $(VBIN) $(ARGS) $(IMG)

app: $(VBIN) $(APP_IMG) $(NEMUISO)
	@$(VBIN) $(ARGS) $(APP_IMG)


clean:
	@echo rm -rf OBJ_DIR *vcd
	@rm -rf $(OBJ_DIR)
	@rm -rf *.vcd

clean-all:
	@echo rm -rf OBJ_DIR *vcd NEMU_DIFF
	@rm -rf $(OBJ_DIR)
	@rm -rf *.vcd
	@make -s -C $(NEMU_DIR) clean

.PHONY: test test_all clean
