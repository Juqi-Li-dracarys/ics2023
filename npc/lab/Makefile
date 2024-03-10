# /*
#  * @Author: Juqi Li @ NJU 
#  * @Date: 2024-01-16 11:04:33 
#  * @Last Modified by:   Juqi Li @ NJU 
#  * @Last Modified time: 2024-01-16 11:04:33 
#  */

include $(NPC_HOME)/../Makefile
include $(NVBOARD_HOME)/scripts/nvboard.mk

# define some path and flags
VERILATOR = verilator
WAVE = gtkwave
VERILATOR_CFLAGS += -MMD --cc --trace --build -O3 \
				--x-assign fast --x-initial fast --noassert
BUILD_DIR = $(NPC_HOME)/lab/build
SIM_DIR = $(BUILD_DIR)/sim
IMP_DIR = $(BUILD_DIR)/imp
BIN_S = $(SIM_DIR)/$(TOPNAME)
BIN_I = $(IMP_DIR)/$(TOPNAME)

# creat build dir
$(shell mkdir -p $(SIM_DIR))
$(shell mkdir -p $(IMP_DIR))

# generate constraint file for implementation
SRC_AUTO_BIND = $(abspath $(BUILD_DIR)/imp/auto_bind.cpp)
CSRCS_I += $(SRC_AUTO_BIND)

$(SRC_AUTO_BIND): $(NXDC_FILES)
	@rm -rf $(IMP_DIR)
	@echo "generate autobind"
	@mkdir -p $(IMP_DIR)
	@python3 $(NVBOARD_HOME)/scripts/auto_pin_bind.py $^ $@

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
	@$(WAVE) *.vcd
	@echo "-------- SIMULATION FINISH --------"

# compile rulers for implementation
$(BIN_I): $(VSRCS) $(CSRCS_I) $(NVBOARD_ARCHIVE)
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
	rm -f *.vcd

default: $(BIN_S)
	@echo "default: compile and run the simulation."

all: default

.PHONY: default all clean sim imp
