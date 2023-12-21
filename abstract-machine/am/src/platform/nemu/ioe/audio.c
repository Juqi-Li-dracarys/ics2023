#include <am.h>
#include <nemu.h>

/*
   目前版本还有很严重的 bug，
   单独播放可以，启动音频播放后
   超级玛丽会黑屏
*/

// 这里手动设置 audio 是否使用
// #define CONFIG_HAS_AUDIO 1

// Register in memory
#define AUDIO_FREQ_ADDR      (AUDIO_ADDR + 0x00)
#define AUDIO_CHANNELS_ADDR  (AUDIO_ADDR + 0x04)
#define AUDIO_SAMPLES_ADDR   (AUDIO_ADDR + 0x08)
#define AUDIO_SBUF_SIZE_ADDR (AUDIO_ADDR + 0x0c)
#define AUDIO_INIT_ADDR      (AUDIO_ADDR + 0x10)
#define AUDIO_COUNT_ADDR     (AUDIO_ADDR + 0x14)
#define AUDIO_HEAD_ADDR      (AUDIO_ADDR + 0x18) // head of the quene
#define AUDIO_TAIL_ADDR      (AUDIO_ADDR + 0x1C) // tail of the quene
#define AUDIO_OF_ADDR        (AUDIO_ADDR + 0x20) // 1 is buf_overflow
#define AUDIO_STATE_ADDR     (AUDIO_ADDR + 0x24) // 0 is playing, 1 is writing
#define SB_SIZE 0x10000

#ifdef CONFIG_HAS_AUDIO
static bool present = false;
#endif

void __am_audio_init() {

}

void __am_audio_config(AM_AUDIO_CONFIG_T *cfg) {
#ifdef CONFIG_HAS_AUDIO
  cfg->present = true;
  cfg->bufsize = 0x10000;
#else
  cfg->present = false;
#endif
}

// 声音参数设置, 同时初始化物理寄存器
void __am_audio_ctrl(AM_AUDIO_CTRL_T *ctrl) {
#ifdef CONFIG_HAS_AUDIO
  outl(AUDIO_FREQ_ADDR, (uint32_t)ctrl->freq);
  outl(AUDIO_CHANNELS_ADDR, (uint32_t)ctrl->channels);
  outl(AUDIO_SAMPLES_ADDR, (uint32_t)ctrl->samples);
  outl(AUDIO_INIT_ADDR, (uint32_t)true);
  if(present == false) {
    present = true;
    outl(AUDIO_SBUF_SIZE_ADDR, SB_SIZE);
    outl(AUDIO_COUNT_ADDR, 0);
    outl(AUDIO_HEAD_ADDR, 0);
    outl(AUDIO_TAIL_ADDR, 0);
    outl(AUDIO_OF_ADDR, false);
    outl(AUDIO_STATE_ADDR, false);
  }
#endif
}

void __am_audio_status(AM_AUDIO_STATUS_T *stat) {
#ifdef CONFIG_HAS_AUDIO
  stat->count = inl(AUDIO_COUNT_ADDR);
#endif
}

void __am_audio_play(AM_AUDIO_PLAY_T *ctl) {
#ifdef CONFIG_HAS_AUDIO
  uint32_t head = 0;
  uint32_t tail = 0;
  uint32_t count = 0;
  uint8_t *start = (uint8_t *)((ctl->buf).start);
  uint8_t *end = (uint8_t *)((ctl->buf).end);
  while(1) {
    outl(AUDIO_STATE_ADDR, true);
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
        outl(AUDIO_OF_ADDR, true);
        break;
      }
    }
    outl(AUDIO_HEAD_ADDR, head);
    outl(AUDIO_TAIL_ADDR, tail);
    outl(AUDIO_COUNT_ADDR, count);
    outl(AUDIO_STATE_ADDR, false);
    if(inl(AUDIO_OF_ADDR) == 0) 
      break;
    else {
      // 等待回调函数将一些数据出队列
      while(inl(AUDIO_OF_ADDR) == true);
    }
  }
  return;
#endif
}
