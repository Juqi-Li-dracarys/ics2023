
# Makefile for NPC
# Author: LJQ

include ../Makefile

# define some flags
VERILATOR = verilator
TOPNAME = top
VERILATOR_CFLAGS += --cc --trace --build
BUILD_DIR = $(NPC_HOME)/build
OBJ_DIR = $(BUILD_DIR)/obj_dir
BIN = $(BUILD_DIR)/$(TOPNAME)
INC_PATH ?=

# project source
VSRCS = $(shell find $(abspath $(NPC_HOME)/vsrc) -name "*.v")
CSRCS = $(shell find $(abspath $(NPC_HOME)/csrc) -name "*.c" -or -name "*.cpp")

# import nvboard
INCFLAGS = $(addprefix -I, $(INC_PATH))
CXXFLAGS += $(INCFLAGS) -DTOP_NAME="\"V$(TOPNAME)\""

$(shell mkdir -p $(BUILD_DIR))

# compile rulers
$(BIN): $(VSRCS) $(CSRCS)
	@rm -rf $(OBJ_DIR)
	@echo "------- COMPILING THE SOURCE CODE--------"
	$(VERILATOR) $(VERILATOR_CFLAGS) \
		--top-module $(TOPNAME) $^ \
		--Mdir $(OBJ_DIR) --exe -o $(abspath $(BIN))

sim: $(BIN)
	$(call git_commit, "sim RTL")
	@echo "------- RUNNING THE SIMULATION--------"
	@$^
	@echo "-------- FINISH SIMULATION--------"

wave: sim
	@echo "------- DISPLAY THE WAVE--------"
	@gtkwave $(NPC_HOME)/*.vcd
	@echo "-------- FINISH --------"

clean:
	rm -rf $(BUILD_DIR)
	rm -f $(NPC_HOME)/*.vcd

default: $(BIN)
	@echo "default: compile and run the bin."

all: default

.PHONY: default all clean sim wave