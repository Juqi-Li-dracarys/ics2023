/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-01-11 23:44:11 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-01-11 23:53:43
 */

#include <common.h>

#define buffer_size 10

typedef struct buffer
{
  char log_buf[80];
  bool use_state;
  struct buffer *next;
} 
ring_buffer;

ring_buffer* ring_head = NULL;

// 初始化环形链表
ring_buffer *init_ring_buffer(void) {
  ring_buffer *ptr = (ring_buffer *)malloc(sizeof(ring_buffer));
  ptr->log_buf[0] = '\0';
  ptr-> use_state = false;
  ring_buffer *head = ptr;
  for (int i = 1; i < buffer_size; i++) {
    ptr->next = (ring_buffer *)malloc(sizeof(ring_buffer));
    ptr = ptr->next;
    ptr->log_buf[0] = '\0';
    ptr-> use_state = false;
  }
  ptr->next = head;
  return head;
}

// 写入buffer
ring_buffer *write_ring_buffer(ring_buffer *head, char *log_str) {
  strcpy(head->log_buf, log_str);
  head->use_state = true;
  return head->next;
}

// 打印buffer的全部内容
void print_ring_buffer(ring_buffer *head) {
  ring_buffer *ptr = head;
  puts("The latest 10 ITRACE in ring buffer:");
  if (ptr->use_state == true) {
    while(1) {
      puts(ptr->log_buf);
      if (ptr->next == head) {
        break;
      }
      else {
        ptr = ptr->next;
      }
    }
  }
  //buf未填满
  else {
    while(ptr->use_state != true) {
      if(ptr->next == head) {
        return;
      }
      ptr = ptr->next;
    }
    while(1) {
      puts(ptr->log_buf);
      if (ptr->next == head) {
        break;
      }
      else {
        ptr = ptr->next;
      }
    }
  }
}

// 销毁buffer空间
void destroy_ring_buffer(ring_buffer *head) {
  ring_buffer *ptr = head;
  ring_buffer *next_;
  while(1) {
    next_ = ptr->next;
    free(ptr);
    if(next_ == head) {
      break;
    }
    else {
      ptr = next_;
    }
  }
}
