
#ifndef __MEMORY_H__
#define __MEMORY_H__

extern "C" int vaddr_ifetch(int addr, int len);

extern "C" int vaddr_read(int addr, int len);

extern "C" void vaddr_write(int addr, int len, int data);


#endif