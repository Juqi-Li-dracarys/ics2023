# /*
#  * @Author: Juqi Li @ NJU 
#  * @Date: 2024-01-16 19:39:44 
#  * @Last Modified by:   Juqi Li @ NJU 
#  * @Last Modified time: 2024-01-16 19:39:44 
#  */

# Makefile for compiling C++ files

default: VCPU_TOP

include VCPU_TOP.mk

CXXFLAGS += -MMD -O3 -std=c++14 -fno-exceptions -fPIE -Wno-unused-result
CXXFLAGS += $(shell llvm-config-11 --cxxflags) -fPIC -DDEVICE -D__GUEST_ISA__=$(ISA)
LDFLAGS += -O3 -rdynamic -shared -fPIC
LIBS += $(shell llvm-config-11 --libs)
LIBS += -lreadline -ldl -pie -lSDL2
LINK := g++