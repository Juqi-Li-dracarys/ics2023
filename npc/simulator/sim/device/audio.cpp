
#include <common.h>
#include <device/map.h>
#include <SDL2/SDL.h>

enum {
  reg_freq,
  reg_channels,
  reg_samples,
  reg_sbuf_size,
  reg_init,
  reg_count,
  reg_head,     // head of the quene
  reg_tail,     // tail of the quene(index of the next element)
  reg_overflow, // 1 is buf_overflow
  reg_state,    // 0 is playing, 1 is writing
  nr_reg
};

static uint8_t *sbuf = NULL;
static uint32_t *audio_base = NULL;

// Audio callback fucntion
void audio_callback(void *userdata, Uint8 *stream, int len) {
  while (audio_base[reg_state] == true);
  uint32_t count = audio_base[reg_count];
  uint32_t head = audio_base[reg_head];
  uint32_t tail = audio_base[reg_tail];
  while (len > 0) {
    if (head != tail) {
      *stream = sbuf[head];
      head = (head + 1) % CONFIG_SB_SIZE;
      count--;
    }
    else {
      *stream = 0;
    }
    stream++;
    len--;
  }
  audio_base[reg_count] = count;
  audio_base[reg_head] = head;
  audio_base[reg_tail] = tail;
  audio_base[reg_overflow] = false;
  return;
}

static void audio_io_handler(uint32_t offset, int len, bool is_write) {
  if(offset != 0x10 || is_write == 0)
    return;
  else {
    // 当 init 寄存器被写时，即开始初始化
    SDL_AudioSpec s = {};
    s.format = AUDIO_S16SYS;
    s.userdata = NULL;      
    s.freq = audio_base[reg_freq];
    s.channels = audio_base[reg_channels];
    s.samples = audio_base[reg_samples];
    s.callback = audio_callback;
    int ret = SDL_InitSubSystem(SDL_INIT_AUDIO);
    if (ret == 0) {
      SDL_OpenAudio(&s, NULL);
      SDL_PauseAudio(0);
      printf("Audio init success.\n");
    }
  }
}

void init_audio() {
  uint32_t space_size = sizeof(uint32_t) * nr_reg;
  audio_base = (uint32_t *)new_space(space_size);
#ifdef CONFIG_HAS_PORT_IO
  add_pio_map ("audio", CONFIG_AUDIO_CTL_PORT, audio_base, space_size, audio_io_handler);
#else
  add_mmio_map("audio", CONFIG_AUDIO_CTL_MMIO, audio_base, space_size, audio_io_handler);
#endif

  sbuf = (uint8_t *)new_space(CONFIG_SB_SIZE);
  add_mmio_map("audio-sbuf", CONFIG_SB_ADDR, sbuf, CONFIG_SB_SIZE, NULL);
}
