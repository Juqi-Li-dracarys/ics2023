
# Makefile for NPC

include ../Makefile

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

INCFLAGS = $(addprefix -I, $(INC_PATH))
CXXFLAGS += $(INCFLAGS) -DTOP_NAME="\"V$(TOPNAME)\""

$(shell mkdir -p $(BUILD_DIR))

default: $(BIN)
	@echo "default: compile and run the bin."

all: default

$(BIN): $(VSRCS) $(CSRCS)
	@rm -rf $(OBJ_DIR)
	@echo "------- VERILATE & BUILD --------"
	$(VERILATOR) $(VERILATOR_CFLAGS) \
		--top-module $(TOPNAME) $^ \
		$(addprefix -CFLAGS , $(CXXFLAGS)) $(addprefix -LDFLAGS , $(LDFLAGS)) \
		--Mdir $(OBJ_DIR) --exe -o $(abspath $(BIN))

sim: $(BIN)
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!
	@echo "------- RUN THE BIN--------"
	@$^
	@echo "-------- FINISH --------"

wave: sim
	@echo "------- DISPLAY WAVE--------"
	@gtkwave $(NPC_HOME)/*.vcd
	@echo "-------- FINISH --------"

clean:
	rm -rf $(BUILD_DIR)