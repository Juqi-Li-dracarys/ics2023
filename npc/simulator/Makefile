
# /*
# * @Author: Juqi Li @ NJU 
# * @Date: 2024-01-16 10:45:16 
# * @Last Modified by:   Juqi Li @ NJU 
# * @Last Modified time: 2024-01-16 10:45:16 
# */

include $(NPC_HOME)/../Makefile

WORK_DIR            = $(shell pwd)

OBJ_DIR   			= $(abspath $(WORK_DIR)/build)
CSRC_DIR 			= $(abspath $(WORK_DIR)/sim)
VSRC_DIR 			= $(abspath $(NPC_HOME)/$(CPU_ARCH))
NEMU_DIR 			= $(abspath $(WORK_DIR)/nemu)
# 查找所有子目录
VSRC_INC            = $(foreach dir,$(shell find $(VSRC_DIR) -type d),-y $(dir))

VERILOG_TOP 		= $(VSRC_DIR)/CPU_TOP_ysyx23060136.sv
NEMUISO 			= $(NEMU_DIR)/build/riscv32-nemu-interpreter-so
VFLAGS 				= --MMD --trace --cc --exe -O3 --threads-dpi all -sv $(VSRC_INC) -Wall \
					  -Mdir $(OBJ_DIR) -DDIFF --top-module $(basename $(notdir $(VERILOG_TOP)))


CINC_PATH 			= -CFLAGS -I$(CSRC_DIR)/include 
CSRC 				= $(shell find $(CSRC_DIR) -name "*.cpp*")
VSRC 				= $(shell find $(VSRC_DIR) -name "*.sv" -o -name "*.v")
VBIN 				= $(OBJ_DIR)/$(addprefix V, $(basename $(notdir $(VERILOG_TOP))))
REWRITE 			= $(abspath $(WORK_DIR)/script/rewrite.mk)
GTKFLAGS            = --script=$(WORK_DIR)/script/gtkwave.tcl

COLOR_RED   		= \033[1;31m
COLOR_GREEN 		= \033[1;32m
COLOR_YELLOW 		= \033[33m
COLOR_NONE  		= \033[0m


include $(WORK_DIR)/script/build.mk

