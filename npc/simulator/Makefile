# /*
#  * @Author: Juqi Li @ NJU 
#  * @Date: 2024-04-12 01:01:10 
#  * @Last Modified by:   Juqi Li @ NJU 
#  * @Last Modified time: 2024-04-12 01:01:10 
#  */



include $(NPC_HOME)/../Makefile
include $(NVBOARD_HOME)/scripts/nvboard.mk

WORK_DIR            = $(shell pwd)

OBJ_DIR   			= $(abspath $(WORK_DIR)/build)
CSRC_DIR 			= $(abspath $(WORK_DIR)/sim)
VSRC_DIR 		    = $(abspath $(NPC_HOME)/core)

# 查找所有子目录
# 增加 SoC 外设文件
VERILOG_TOP 		= $(NPC_HOME)/core/ysyxSoCFull.v
VSRC_INC            = $(foreach dir,$(shell find $(VSRC_DIR) -type d),-y $(dir))

NEMUISO 			= $(NEMU_HOME)/build/riscv64-nemu-interpreter-so

VFLAGS 				= --MMD --trace --cc --exe -O3 --threads-dpi all $(VSRC_INC)  --timescale "1ns/1ns" --x-assign fast --noassert --x-initial fast --no-timing -Mdir $(OBJ_DIR) -DDIFF --top-module $(basename $(notdir $(VERILOG_TOP)))

CINC_PATH 			= -CFLAGS -I$(CSRC_DIR)/include

CSRC 				= $(shell find $(CSRC_DIR) -name "*.cpp")
VSRC 				= $(shell find $(VSRC_DIR) -name "*.sv" -o -name "*.v")

VBIN 				= $(OBJ_DIR)/$(addprefix V, $(basename $(notdir $(VERILOG_TOP))))
REWRITE 			= $(abspath $(WORK_DIR)/script/rewrite.mk)
GTKFLAGS            = --script=$(WORK_DIR)/script/gtkwave.tcl


COLOR_RED   		= \033[1;31m
COLOR_GREEN 		= \033[1;32m
COLOR_YELLOW 		= \033[33m
COLOR_NONE  		= \033[0m


include $(WORK_DIR)/script/build.mk


