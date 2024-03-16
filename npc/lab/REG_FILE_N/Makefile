

# project source code

TOPNAME = REG_FILE
VSRCS = $(shell find $(abspath ./vsrc) -name "*.sv")
CSRCS_S = $(shell find $(abspath ./csrc/sim) -name "*.c" -or -name "*.cpp")
CSRCS_I = $(shell find $(abspath ./csrc/imp) -name "*.c" -or -name "*.cpp")
NXDC_FILES =  $(shell find $(abspath ./constraint) -name "*.nxdc")


include $(NPC_HOME)/lab/Makefile
