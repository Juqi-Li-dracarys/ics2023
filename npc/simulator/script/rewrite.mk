# /*
#  * @Author: Juqi Li @ NJU 
#  * @Date: 2024-01-16 19:39:44 
#  * @Last Modified by:   Juqi Li @ NJU 
#  * @Last Modified time: 2024-01-16 19:39:44 
#  */

# Makefile for compiling C++ files
# 我们修改一部分编译选项，使其能够和 NEMU 实现类似的功能

default: VCPU_TOP_ysyx23060136

include VCPU_TOP_ysyx23060136.mk

CXXFLAGS += -MMD -O3 -g -std=c++14 -fno-exceptions -fPIE -Wall
CXXFLAGS += $(filter-out -D__STDC_FORMAT_MACROS, $(shell llvm-config-11 --cxxflags)) \
			-fPIC -DDEVICE -D__GUEST_ISA__=$(ISA) -D__CPU_ARCH__=$(CPU_ARCH)
LDFLAGS += -O3 -rdynamic -shared -fPIC
LIBS += $(shell llvm-config-11 --libs)
LIBS += -lreadline -ldl -pie -lSDL2
LINK := g++