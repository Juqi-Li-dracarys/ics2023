/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-01-16 16:33:49 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-04-12 12:05:07
 */

#include <common.h>
#include <getopt.h>
#include <debug.h>
#include <disasm.h>
#include <trace.h>

extern unsigned char isa_logo[];

static void welcome() {
  Log("Trace: %s", MUXDEF(CONFIG_TRACE, ANSI_FMT("ON", ANSI_FG_GREEN), ANSI_FMT("OFF", ANSI_FG_RED)));
  IFDEF(CONFIG_TRACE, Log("If trace is enabled, a log file will be generated "
        "to record the trace. This may lead to a large log file. "
        "If it is not necessary, you can disable it in menuconfig"));
  Log("Build time: %s, %s", __TIME__, __DATE__);
  Log("Welcome to %s %s season-5 NPC Simulator!\n", ANSI_FMT(str(__GUEST_ISA__), ANSI_FG_YELLOW ANSI_BG_RED),  ANSI_FMT(str(__CPU_ARCH__), ANSI_FG_YELLOW ANSI_BG_RED));
}

static const uint32_t img [] = {
  0x00000297,  // auipc t0,0
  0x00028823,  // sb  zero,16(t0)
  0x0102c503,  // lbu a0,16(t0)
  0x00100073,  // ebreak (used as nemu_trap)
  0x00000013,  // add nop to avoid bug in BHT
  0x00000013,
  0x00000013,
  0x00000013,
  0xdeadbeef   // some data
};

void init_isa() {
  // load built-in image size
  memcpy(guest_to_host(CONFIG_MBASE), img, sizeof(img));
  sim_cpu.csr.mstatus = 0xa00001800;
  Log("Reset mstatus, Init ISA done!");
  return ;
}

void sdb_set_batch_mode();

static char *log_file = NULL;
static char *elf_file = NULL;
static char *diff_so_file = NULL;
static char *img_file = NULL;
static int difftest_port = 1234;

static long load_img() {
  if (img_file == NULL) {
    Log("No image is given. Use the default build-in image.");
    return 4096; // built-in image size
  }

  FILE *fp = fopen(img_file, "rb");
  Assert(fp, "Can not open '%s'", img_file);

  fseek(fp, 0, SEEK_END);
  long size = ftell(fp);

  Log("The image is %s, size = %ld", img_file, size);

  fseek(fp, 0, SEEK_SET);
  int ret = fread(guest_to_host(CONFIG_MBASE), size, 1, fp);
  assert(ret == 1);

  fclose(fp);
  return size;
}

// Analysis the information for the terminal input
static int parse_args(int argc, char *argv[]) {
  const struct option table[] = {
    {"batch"    , no_argument      , NULL, 'b'},
    {"log"      , required_argument, NULL, 'l'},
    {"diff"     , required_argument, NULL, 'd'},
    {"port"     , required_argument, NULL, 'p'},
    {"ftrace"   , required_argument, NULL, 'f'},
    {"help"     , no_argument      , NULL, 'h'},
    {0          , 0                , NULL,  0 },
  };
  int o;
  // This is a Linux function used in the condition that you need
  // to get the information of the terminal _ dracarcys
  while ( (o = getopt_long(argc, argv, "-bhl:d:p:f:", table, NULL)) != -1) {
    switch (o) {
      case 'b': sdb_set_batch_mode(); break;
      case 'p': sscanf(optarg, "%d", &difftest_port); break;
      case 'l': log_file = optarg; break;
      case 'd': diff_so_file = optarg; break;
      case 'f': elf_file = optarg; break;
      case 1:   img_file = optarg; return 0;
      default:
        printf("Usage: %s [OPTION...] IMAGE [args]\n\n", argv[0]);
        printf("\t-b,--batch              run with batch mode\n");
        printf("\t-l,--log=FILE           output log to FILE\n");
        printf("\t-d,--diff=REF_SO        run DiffTest with reference REF_SO\n");
        printf("\t-p,--port=PORT          run DiffTest with port PORT\n");
        printf("\n");
        exit(0);
    }
  }
  return 0;
}

void init_monitor(int argc, char *argv[]) {
  /* Perform some global initialization. */
   
  /* Parse arguments. */
  // analyze syntactically by assigning a constituent structure to (a sentence)
  parse_args(argc, argv);

  /* Open the log file. */
  init_log(log_file);

  /* Open the elf file. */
  IFDEF(CONFIG_FTRACE, init_ftrace(elf_file));

  init_isa();

  /* Load the image to memory. This will overwrite the built-in image. */
  long img_size = load_img();

  /* Initialize differential testing. */
  init_difftest(diff_so_file, img_size, difftest_port);

  /* Initialize the simple debugger. */
  init_sdb();

  init_disasm("riscv64");

  init_device(" ");

  /* Display welcome message. */
  welcome();
}

