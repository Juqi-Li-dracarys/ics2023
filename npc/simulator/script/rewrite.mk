# /*
#  * @Author: Juqi Li @ NJU 
#  * @Date: 2024-01-16 19:39:44 
#  * @Last Modified by:   Juqi Li @ NJU 
#  * @Last Modified time: 2024-03-23 19:39:44 
#  */

# Makefile for compiling C++ files of model
# 修改依赖库和编译选项

default: VysyxSoCFull

include VysyxSoCFull.mk

CXXFLAGS += -MMD -O3 -g -std=c++14 -fno-exceptions -fPIE -Wall
CXXFLAGS += $(filter-out -D__STDC_FORMAT_MACROS, $(shell llvm-config-11 --cxxflags)) \
			-fPIC -DDEVICE -D__GUEST_ISA__=riscv64 -D__CPU_ARCH__=pipeline
LDFLAGS += -O3 -rdynamic -shared -fPIC
LIBS += $(shell llvm-config-11 --libs)
LIBS += -lreadline -ldl -pie -lSDL2 -lSDL2_image -lSDL2_ttf
LINK := g++