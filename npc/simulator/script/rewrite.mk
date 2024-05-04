# /*
#  * @Author: Juqi Li @ NJU 
#  * @Date: 2024-04-12 01:07:35 
#  * @Last Modified by:   Juqi Li @ NJU 
#  * @Last Modified time: 2024-04-12 01:07:35 
#  */


# Makefile for compiling C++ files of model
# 修改依赖库和编译选项

default: VysyxSoCFull

include VysyxSoCFull.mk

# DEBUG    = -g

CXXFLAGS += -MMD -Ofast -std=c++14 -fno-exceptions -fPIE -Wall $(DEBUG)

CXXFLAGS += $(filter-out -D__STDC_FORMAT_MACROS, $(shell llvm-config-11 --cxxflags)) \
			-fPIC -DDEVICE -D__GUEST_ISA__=riscv64 -D__CPU_ARCH__=pipeline

LDFLAGS += -Ofast -rdynamic -shared -fPIC

LIBS += $(shell llvm-config-11 --libs)

LIBS += -lreadline -ldl -pie -lSDL2 -lSDL2_image -lSDL2_ttf

LINK := g++