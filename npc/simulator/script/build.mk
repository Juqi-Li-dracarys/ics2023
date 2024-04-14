# /*
#  * @Author: Juqi Li @ NJU 
#  * @Date: 2024-04-12 01:07:16 
#  * @Last Modified by:   Juqi Li @ NJU 
#  * @Last Modified time: 2024-04-12 01:07:16 
#  */


IMG ?= 
VERILATOR = verilator
ARGS_DIFF = --diff=$(NEMUISO)
SILENT = -s
BATCH_MODE = -b

GPROF=gprof
GPROF_FILE=$(dir $(VBIN))/gprof.out
GPROF_REPORT=$(dir $(VBIN))/report.out

override ARGS ?= --log=$(OBJ_DIR)/npc-log.txt
override ARGS += $(ARGS_DIFF)


$(VBIN): $(CSRC) $(VSRC)
	@echo "$(COLOR_YELLOW)[VERILATOR]$(COLOR_NONE) $(VBIN)"
	@echo "$(COLOR_YELLOW)[GENERATE]$(COLOR_NONE) Creating System Verilog Model"
	@$(VERILATOR) $(VFLAGS) $^ $(CINC_PATH)
	@echo "$(COLOR_YELLOW)[COMPILE]$(COLOR_NONE) Compiling C++ files"
	@$(MAKE) $(SILENT) -C $(OBJ_DIR) -f $(REWRITE)

$(NEMUISO):
	@echo "$(COLOR_YELLOW)[Make DIFF]$(COLOR_NONE) $(notdir $(NEMU_HOME))/build/nemu-interpreter-so"
	@$(MAKE) -C $(NEMU_HOME) ISA=$(ISA) app


run: $(VBIN) $(NEMUISO) $(IMG)
	@echo "$(COLOR_YELLOW)[RUN IMG]$(COLOR_NONE)" $(notdir $(IMG))
	$(call git_commit, "RUN NPC")
	@$(GPROF) $(VBIN) $(PROF_FILE)
	@verilator_profcfunc $(PROF_FILE) $(GPROF_REPORT)
	@$(VBIN) $(ARGS) $(IMG)

test: $(VBIN) $(NEMUISO) $(IMG)
	@echo "$(COLOR_YELLOW)[RUN IMG]$(COLOR_NONE)" $(notdir $(IMG))
	$(call git_commit, "RUN NPC")
	@$(GPROF) $(VBIN) $(PROF_FILE)
	@verilator_profcfunc $(PROF_FILE) $(GPROF_REPORT)
	@$(VBIN) $(ARGS) $(BATCH_MODE) $(IMG)

gdb: $(VBIN) $(NEMUISO) $(IMG)
	@echo "$(COLOR_YELLOW)[GDB IMG]$(COLOR_NONE)" $(notdir $(IMG))
	$(call git_commit, "GDB NPC")
	@$(GPROF) $(VBIN) $(PROF_FILE)
	@verilator_profcfunc $(PROF_FILE) $(GPROF_REPORT)
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
	@make -s -C $(NEMU_HONE) clean

.PHONY: run gdb wave clean-all clean
