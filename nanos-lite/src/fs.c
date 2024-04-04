/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2023-12-28 16:55:52 
 * @Last Modified by:   Juqi Li @ NJU 
 * @Last Modified time: 2023-12-28 16:55:52 
 */

#include <fs.h>

typedef size_t (*ReadFn) (void *buf, size_t offset, size_t len);
typedef size_t (*WriteFn) (const void *buf, size_t offset, size_t len);

typedef struct {
  char *name;
  size_t size;
  size_t disk_offset;
  ReadFn read;
  WriteFn write;
  size_t open_offset; // 文件指针
} Finfo;

// 虚拟文件数量
# define DEVICE_NUM 7

enum {FD_STDIN, FD_STDOUT, FD_STDERR, FD_EVENTS, FD_INFO, FD_FB, FD_QUIT};

size_t invalid_read(void *buf, size_t offset, size_t len) {
  panic("should not read here, son of bitch.");
  return 0;
}

size_t invalid_write(const void *buf, size_t offset, size_t len) {
  panic("should not write here, son of bitch.");
  return 0;
}

/* This is the information about all files in disk. */
// 我们假设所有虚拟设备的大小足够大
static Finfo file_table[] __attribute__((used)) = {
    // virtual device file
    [FD_STDIN]  = {"stdin", 0x80000000, 0, invalid_read, invalid_write},
    [FD_STDOUT] = {"stdout", 0x80000000, 0, invalid_read, serial_write},
    [FD_STDERR] = {"stderr", 0x80000000, 0, invalid_read, serial_write},
    [FD_EVENTS] = {"/dev/events", 0x80000000, 0, events_read, invalid_write},
    [FD_INFO]   = {"/proc/dispinfo", 0x80000000, 0, dispinfo_read, invalid_write},
    // frame buffer of VGA
    [FD_FB]     = {"/dev/fb", 0x80000000, 0, invalid_read, fb_write},
    [FD_QUIT]   = {"/bin/quit", 0x80000000, 0, invalid_read, invalid_write},
    // application file
    #include "files.h"
};

void init_fs() {
  file_table[FD_FB].size = io_read(AM_GPU_CONFIG).vmemsz;
  // 真实文件，读取磁盘即可
  // 虚拟文件，调用对应的读写函数
  for(uintptr_t i = DEVICE_NUM; i < sizeof(file_table) / sizeof(Finfo); i++) {
    file_table[i].read =  ramdisk_read;
    file_table[i].write = ramdisk_write;
  }
  return;
}

/*

The  open()  system  call opens the file specified by pathname.  If the
specified file does not exist, it may optionally (if O_CREAT is  speci‐
fied in flags) be created by open().

The  return  value of open() is a file descriptor, a small, nonnegative
integer that is used in subsequent  system  calls  (read(2),  write(2),
lseek(2), fcntl(2), etc.) to refer to the open file.  The file descrip‐
tor returned by a successful call will be the lowest-numbered file  de‐
scriptor not currently open for the process.

*/

int fs_open(const char *pathname, int flags, int mode) {
  if(pathname == NULL) {
    Log("warning: can't open file pathname = %s.", pathname); 
    return -1;
  }
  for(uintptr_t i = 0; i < sizeof(file_table) / sizeof(Finfo); i++) {
    if(strcmp(pathname, file_table[i].name) == 0) {
      if(i == FD_QUIT) {
        printf("\nsystem halt in EXIT CODE: %p\n", 0);
        halt(0);
      }
      file_table[i].open_offset = 0;
      return i;
    }
  }
  Log("warning: can't find file, pathname = %s.", pathname);
  return -1;
}

/*

lseek()  repositions the file offset of the open file description asso‐
ciated with the file descriptor fd to the argument offset according  to
the directive whence as follows:

*/

size_t lseek(int fd, size_t offset, int whence) {
  if(fd == FD_STDIN || fd == FD_STDOUT || fd == FD_STDERR || fd >= sizeof(file_table) / sizeof(Finfo)) {
    panic("error: can't support set offset of std file");
    return -1;
  }
  switch (whence) {
    case SEEK_SET: {
      file_table[fd].open_offset = offset;
      break;
    }
    case SEEK_CUR: {
      file_table[fd].open_offset += offset;
      break;
    }
    case SEEK_END: {
      file_table[fd].open_offset = file_table[fd].size + offset;
      break;
    }
    default: {
      panic("error: unknown type of whence");
      return -1;
    }
  }
  return file_table[fd].open_offset;
}

/*

read() attempts to read up to count bytes from file descriptor fd into
the buffer starting at buf.

On files that support seeking, the read operation commences at the file
offset, and the file offset is incremented by the number of bytes read.
If the file offset is at or past the end of file, no  bytes  are  read,
and read() returns zero.

*/

size_t fs_read(int fd, void *buf, size_t len) {
  if(fd >= sizeof(file_table) / sizeof(Finfo) || buf == NULL) {
    panic("error: fd or buf is out of range");
    return -1;
  }
  // 文件越界检查
  if((fd < DEVICE_NUM) || (file_table[fd].open_offset <= file_table[fd].size && file_table[fd].open_offset >= 0))  {
    size_t length = len < file_table[fd].size - file_table[fd].open_offset ? len : file_table[fd].size - file_table[fd].open_offset;
    size_t f_size = file_table[fd].read(buf, file_table[fd].open_offset + file_table[fd].disk_offset, length);
    file_table[fd].open_offset += f_size;
    return f_size;
  }
  else {
    panic("error: offset overflow: fd = %d", fd);
    return -1;
  }
}

/*

read()  attempts to read up to count bytes from file descriptor fd into
the buffer starting at buf.

On files that support seeking, the read operation commences at the file
offset, and the file offset is incremented by the number of bytes read.
If the file offset is at or past the end of file, no  bytes  are  read,
and read() returns zero.

*/

size_t fs_write(int fd, const void *buf, size_t len) {
  if(fd >= sizeof(file_table) / sizeof(Finfo) || buf == NULL) {
    panic("error: fd/buf out of range");
    return -1;
  }
  // 文件越界检查
  if((fd < DEVICE_NUM) || (file_table[fd].open_offset <= file_table[fd].size && file_table[fd].open_offset >= 0)) {
    size_t length = len < file_table[fd].size - file_table[fd].open_offset ? len : file_table[fd].size - file_table[fd].open_offset;
    size_t f_size = file_table[fd].write(buf, file_table[fd].open_offset + file_table[fd].disk_offset, length);
    file_table[fd].open_offset += f_size;
    return f_size;
  }
  else {
    panic("error: offset overflow: fd = %d", fd);
    return -1;
  }
}

int fs_close(int fd) {
  file_table[fd].open_offset = 0;
  return 0;
}


