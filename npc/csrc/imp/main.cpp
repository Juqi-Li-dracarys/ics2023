/*
- `void nvboard_init()`: 初始化NVBoard
- `void nvboard_quit()`: 退出NVBoard
- `void nvboard_bind_pin(void *signal, bool is_rt, bool is_output, int len, ...)`: 将HDL的信号signal连接到NVBoard里的引脚上，具体地
  - `is_rt`为`true`时，表示该信号为实时信号，每个周期都要更新才能正确工作，如键盘和VGA相关信号；
    `is_rt`为`false`时，表示该信号为普通信号，可以在NVBoard更新画面时才更新，从而提升NVBoard的性能，如拨码开关和LED灯等，无需每个周期都更新
  - `is_output`为`true`时，表示该信号方向为输出方向(从RTL代码到NVBoard)；否则为输入方向(从NVBoard到RTL代码)
  - `len`为信号的长度，大于1时为向量信号
  - 可变参数列表`...`为引脚编号列表，编号为整数；绑定向量信号时，引脚编号列表从MSB到LSB排列
- `void nvboard_update()`: 更新NVBoard中各组件的状态，每当电路状态发生改变时都需要调用该函数
*/

#include <nvboard.h>
#include <Vtop.h>


static TOP_NAME dut;

void nvboard_bind_all_pins(Vtop* top);

static void single_cycle() {
  dut.clk = 0; dut.eval();
  dut.clk = 1; dut.eval();
}

static void reset(int n) {
  dut.rst = 1;
  while (n -- > 0) single_cycle();
  dut.rst = 0;
}

int main() {
  nvboard_bind_all_pins(&dut);
  nvboard_init();

  reset(10);

  while(1) {
    nvboard_update();
    single_cycle();
  }
}
