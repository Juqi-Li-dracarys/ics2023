
ifneq ($(words $(CURDIR)),1)
 $(error Unsupported: GNU Make cannot build in directories containing spaces, build elsewhere: '$(CURDIR)')
endif

ifeq ($(VERILATOR_ROOT),)
VERILATOR = verilator
else
export VERILATOR_ROOT
VERILATOR = $(VERILATOR_ROOT)/bin/verilator
endif

all:
	@echo "Write this Makefile by your self."

sim:
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!
	@echo "-- Verilator hello-world simple example"
	@echo "-- VERILATE & BUILD --------"
	$(VERILATOR) -Wall top.v test.cpp --cc --trace --exe --build
	@echo "-- RUN ---------------------"
	obj_dir/Vtop
	@echo "-- FINISH ---------------------""

include ../Makefile

wave:
	gtkwave wave.vcd

clean::
	-rm -rf obj_dir
	-rm -rf wave.vcd