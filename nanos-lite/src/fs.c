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

# define DEVICE_NUM 6

enum {FD_STDIN, FD_STDOUT, FD_STDERR, FD_EVENTS, FD_INFO, FD_FB};

size_t invalid_read(void *buf, size_t offset, size_t len) {
  panic("should read here");
  return 0;
}

size_t invalid_write(const void *buf, size_t offset, size_t len) {
  panic("should write here");
  return 0;
}

/* This is the information about all files in disk. */
static Finfo file_table[] __attribute__((used)) = {
  [FD_STDIN]  = {"stdin", 0, 0, invalid_read, invalid_write},
  [FD_STDOUT] = {"stdout", 0, 0, invalid_read, serial_write},
  [FD_STDERR] = {"stderr", 0, 0, invalid_read, serial_write},
  [FD_EVENTS] = {"/dev/events", 0, 0, events_read, invalid_write},
  [FD_INFO]   = {"/proc/dispinfo", 0, 0, dispinfo_read, invalid_write},
  [FD_FB]     = {"/dev/fb", 0, 0, invalid_read, fb_write},
#include "files.h"
};

void init_fs() {
  file_table[FD_FB].size = io_read(AM_GPU_CONFIG).vmemsz;
  // 真实文件
  for(uintptr_t i = DEVICE_NUM; i < sizeof(file_table) / sizeof(Finfo); i++) {
    file_table[i].read =  ramdisk_read;
    file_table[i].write = ramdisk_write;
  }
  return;
}

int fs_open(const char *pathname, int flags, int mode) {
  if(pathname == NULL) {
    Log("warning: can't open file pathname = %s.", pathname); 
    return -1;
  }
  // just for real file open
  for(uintptr_t i = 0; i < sizeof(file_table) / sizeof(Finfo); i++) {
    if(strcmp(pathname, file_table[i].name) == 0) {
      file_table[i].open_offset = 0;
      return i;
    }
  }
  Log("warning: can't find file, pathname = %s.", pathname);
  return -1;
}

size_t lseek(int fd, size_t offset, int whence) {
  if(fd == FD_STDIN || fd == FD_STDOUT || fd == FD_STDERR || fd >= sizeof(file_table) / sizeof(Finfo)) {
    panic("error: can't set offset of std file");
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

// all files read
size_t fs_read(int fd, void *buf, size_t len) {
  if(fd >= sizeof(file_table) / sizeof(Finfo) || buf == NULL) {
    panic("error: fd/buf out of range");
    return -1;
  }
  // 文件越界检查, std 跳过
  if((fd < DEVICE_NUM) || (file_table[fd].open_offset <= file_table[fd].size && file_table[fd].open_offset >= 0))  {
    len = len < file_table[fd].size - file_table[fd].open_offset ? len : file_table[fd].size - file_table[fd].open_offset;
    size_t f_size = file_table[fd].read(buf, file_table[fd].open_offset + file_table[fd].disk_offset, len);
    file_table[fd].open_offset += f_size;
    return f_size;
  }
  else {
    panic("error: offset overflow: fd = %d", fd);
    return -1;
  }
}

// all files write
size_t fs_write(int fd, const void *buf, size_t len) {
  if(fd >= sizeof(file_table) / sizeof(Finfo) || buf == NULL) {
    panic("error: fd/buf out of range");
    return -1;
  }
  // 文件越界检查, std 跳过
  if((fd < DEVICE_NUM) || (file_table[fd].open_offset <= file_table[fd].size && file_table[fd].open_offset >= 0)) {
    len = len < file_table[fd].size - file_table[fd].open_offset ? len : file_table[fd].size - file_table[fd].open_offset;
    size_t f_size = file_table[fd].write(buf, file_table[fd].open_offset + file_table[fd].disk_offset, len);
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


