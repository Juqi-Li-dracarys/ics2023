
# **********************************************
#  Makefile for NPC
#  Author: LJQ
#  Date: 2023.11.30 
#  @ NJU_EE
# **********************************************

include ../Makefile
include $(NVBOARD_HOME)/scripts/nvboard.mk

# define some path and flags
VERILATOR = verilator
TOPNAME = top
VERILATOR_CFLAGS += -MMD --cc --trace --build -O3 \
				--x-assign fast --x-initial fast --noassert
BUILD_DIR = $(NPC_HOME)/build
SIM_DIR = $(BUILD_DIR)/sim
IMP_DIR = $(BUILD_DIR)/imp
BIN_S = $(SIM_DIR)/$(TOPNAME)
BIN_I = $(IMP_DIR)/$(TOPNAME)

# creat build dir
$(shell mkdir -p $(SIM_DIR))
$(shell mkdir -p $(IMP_DIR))

# project source code
VSRCS = $(shell find $(abspath $(NPC_HOME)/vsrc) -name "*.v")
CSRCS_S = $(shell find $(abspath $(NPC_HOME)/csrc/sim) -name "*.c" -or -name "*.cpp")
CSRCS_I = $(shell find $(abspath $(NPC_HOME)/csrc/imp) -name "*.c" -or -name "*.cpp")
NXDC_FILES =  $(shell find $(abspath $(NPC_HOME)/vsrc) -name "*.nxdc")
CSRCS_I += $(SRC_AUTO_BIND)

# generate constraint file for implementation
SRC_AUTO_BIND = $(abspath $(BUILD_DIR)/auto_bind.cpp)
$(SRC_AUTO_BIND): $(NXDC_FILES)
	python3 $(NVBOARD_HOME)/scripts/auto_pin_bind.py $^ $@

# import args from nvboard
INCFLAGS = $(addprefix -I, $(INC_PATH))
CXXFLAGS += $(INCFLAGS) -DTOP_NAME="\"V$(TOPNAME)\""

# compile rulers for simulation
$(BIN_S): $(VSRCS) $(CSRCS_S)
	@rm -rf $(SIM_DIR)
	@echo "------- SIMULATION ON THE SOURCE CODE--------"
	@$(VERILATOR) $(VERILATOR_CFLAGS) \
		--top-module $(TOPNAME) $^ \
		--Mdir $(SIM_DIR) --exe -o $(abspath $(BIN_S))

sim: $(BIN_S)
	$(call git_commit, "sim RTL")
	@echo "------- RUNNING THE SIMULATION--------"
	@$^
	@echo "------- DISPLAY THE WAVE--------"
	@gtkwave $(NPC_HOME)/*.vcd
	@echo "-------- SIMULATION FINISH --------"


# compile rulers for implementation
$(BIN_I): $(VSRCS) $(CSRCS_I) $(NVBOARD_ARCHIVE)
	@rm -rf $(IMP_DIR)
	@echo "------- IMPLEMENTATION ON THE SOURCE CODE--------"
	@$(VERILATOR) $(VERILATOR_CFLAGS) \
		--top-module $(TOPNAME) $^ \
		$(addprefix -CFLAGS , $(CXXFLAGS)) $(addprefix -LDFLAGS , $(LDFLAGS)) \
		--Mdir $(IMP_DIR) --exe -o $(abspath $(BIN_I))

imp: $(BIN_I)
	$(call git_commit, "imp RTL")
	@echo "------- RUNNING THE IMPLEMENTATION--------"
	@$^
	@echo "-------- IMPLEMENTATION FINISH --------"

clean:
	rm -rf $(BUILD_DIR)
	rm -f $(NPC_HOME)/*.vcd

default: $(BIN_S)
	@echo "default: compile and run the simulation."

all: default

.PHONY: default all clean sim imp