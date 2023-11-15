#include <am.h>
#include <nemu.h>

// Register in memory
#define AUDIO_FREQ_ADDR      (AUDIO_ADDR + 0x00)
#define AUDIO_CHANNELS_ADDR  (AUDIO_ADDR + 0x04)
#define AUDIO_SAMPLES_ADDR   (AUDIO_ADDR + 0x08)
#define AUDIO_SBUF_SIZE_ADDR (AUDIO_ADDR + 0x0c)
#define AUDIO_INIT_ADDR      (AUDIO_ADDR + 0x10)
#define AUDIO_COUNT_ADDR     (AUDIO_ADDR + 0x14)
#define AUDIO_HEAD_ADDR      (AUDIO_ADDR + 0x18)
#define AUDIO_TAIL_ADDR      (AUDIO_ADDR + 0x1C)
#define AUDIO_OF_ADDR        (AUDIO_ADDR + 0x20)
#define AUDIO_STATE_ADDR     (AUDIO_ADDR + 0x24)
#define SB_SIZE 0x10000

static bool present = false;

void __am_audio_init() {

}

void __am_audio_config(AM_AUDIO_CONFIG_T *cfg) {
  cfg->present = present;
  cfg->bufsize = inl(AUDIO_SBUF_SIZE_ADDR);
}

// 控制声音参数, 同时初始化
void __am_audio_ctrl(AM_AUDIO_CTRL_T *ctrl) {
  outl(AUDIO_FREQ_ADDR, (uint32_t)ctrl->freq);
  outl(AUDIO_CHANNELS_ADDR, (uint32_t)ctrl->channels);
  outl(AUDIO_SAMPLES_ADDR, (uint32_t)ctrl->samples);
  outl(AUDIO_INIT_ADDR, (uint32_t)true);
  if(present == false) {
    present = true;
    // outl(AUDIO_SBUF_SIZE_ADDR, SB_SIZE);
    outl(AUDIO_COUNT_ADDR, 0);
    outl(AUDIO_HEAD_ADDR, 0);
    outl(AUDIO_TAIL_ADDR, 0);
    outl(AUDIO_OF_ADDR, 0);
    outl(AUDIO_STATE_ADDR, 0);
  }
}

void __am_audio_status(AM_AUDIO_STATUS_T *stat) {
  stat->count = inl(AUDIO_COUNT_ADDR);
}

void __am_audio_play(AM_AUDIO_PLAY_T *ctl) {
  uint32_t head = 0;
  uint32_t tail = 0;
  uint32_t count = 0;
  uint8_t *start = (uint8_t *)((ctl->buf).start);
  uint8_t *end = (uint8_t *)((ctl->buf).start);
  while(1) {
    outl(AUDIO_STATE_ADDR, 1);
    head = inl(AUDIO_HEAD_ADDR);
    tail = inl(AUDIO_TAIL_ADDR);
    count = inl(AUDIO_COUNT_ADDR);
    while(start != end) {
      if((tail + 1) % SB_SIZE != head) {
        outb(AUDIO_SBUF_ADDR + tail, *start);
        tail = (tail + 1) % SB_SIZE;
        start++;
        count++;
      }
      else {
        outl(AUDIO_OF_ADDR, 1);
        break;
      }
    }
    outl(AUDIO_HEAD_ADDR, head);
    outl(AUDIO_TAIL_ADDR, tail);
    outl(AUDIO_COUNT_ADDR, count);
    outl(AUDIO_STATE_ADDR, 0);
    if(inl(AUDIO_OF_ADDR) == 0) 
      break;
    else {
      // 等待回调函数将一些数据出队列
      while(inl(AUDIO_OF_ADDR) == 1);
    }
  }
  return;
}
