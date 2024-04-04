#/*
# * @Author: Juqi Li @ NJU 
# * @Date: 2024-03-23 10:33:30 
# * @Last Modified by:   Juqi Li @ NJU 
# * @Last Modified time: 2024-03-23 10:33:30 
# */


include $(NPC_HOME)/../Makefile
include $(NVBOARD_HOME)/scripts/nvboard.mk

WORK_DIR            = $(shell pwd)

OBJ_DIR   			= $(abspath $(WORK_DIR)/build)
CSRC_DIR 			= $(abspath $(WORK_DIR)/sim)
VSRC_DIR 		    = $(abspath $(NPC_HOME)/core)

# 查找所有子目录
# 增加 SoC 外设文件
VERILOG_TOP 		= $(SOC_HOME)/generated/ysyxSoCFull.v
VSRC_INC            = $(foreach dir,$(shell find $(VSRC_DIR) -type d),-y $(dir)) \
					 -y $(SOC_HOME)/perip/uart16550/rtl -y $(SOC_HOME)/perip/spi/rtl -y $(SOC_HOME)/perip/sdram

NEMUISO 			= $(NEMU_HOME)/build/riscv64-nemu-interpreter-so

VFLAGS 				= --MMD --trace --cc --exe -O3 --threads-dpi all $(VSRC_INC) --timescale "1ns/1ns"  \
					   --no-timing -Mdir $(OBJ_DIR) -DDIFF --top-module $(basename $(notdir $(VERILOG_TOP)))

CINC_PATH 			= -CFLAGS -I$(CSRC_DIR)/include -CFLAGS -I$(NVBOARD_USR_INC)

CSRC 				= $(shell find $(CSRC_DIR) -name "*.cpp")
VSRC 				= $(shell find $(VSRC_DIR) $(SOC_HOME)/perip -name "*.sv" -o -name "*.v") $(VERILOG_TOP)

VBIN 				= $(OBJ_DIR)/$(addprefix V, $(basename $(notdir $(VERILOG_TOP))))
REWRITE 			= $(abspath $(WORK_DIR)/script/rewrite.mk)
GTKFLAGS            = --script=$(WORK_DIR)/script/gtkwave.tcl

# constraint file(cpp)
NXDC_FILES          = $(WORK_DIR)/constr/top.nxdc
SRC_AUTO_BIND       = $(abspath $(OBJ_DIR)/auto_bind.cpp)
CSRC                += $(SRC_AUTO_BIND)

COLOR_RED   		= \033[1;31m
COLOR_GREEN 		= \033[1;32m
COLOR_YELLOW 		= \033[33m
COLOR_NONE  		= \033[0m


include $(WORK_DIR)/script/build.mk


