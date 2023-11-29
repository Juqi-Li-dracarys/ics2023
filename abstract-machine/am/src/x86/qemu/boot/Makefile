SRCS := start.S main.c
bootblock.o: $(SRCS) Makefile
	@echo + CC $(SRCS)
	@$(CROSS_COMPILE)gcc -static -m32 -fno-pic -Os -nostdlib -Ttext 0x7c00 -I$(_AM_HOME_)/am/src -o bootblock.o $(SRCS)
	@python3 genboot.py bootblock.o

clean:
	rm -rf *.o
