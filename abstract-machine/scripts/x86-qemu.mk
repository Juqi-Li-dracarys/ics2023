include $(_AM_HOME_)/scripts/isa/x86.mk
include $(_AM_HOME_)/scripts/platform/qemu.mk

AM_SRCS := x86/qemu/start32.S \
           x86/qemu/trap32.S \
           x86/qemu/trm.c \
           x86/qemu/cte.c \
           x86/qemu/ioe.c \
           x86/qemu/vme.c \
           x86/qemu/mpe.c

run: build-arg
	@qemu-system-i386 $(QEMU_FLAGS)
