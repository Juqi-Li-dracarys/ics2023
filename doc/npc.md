### READ ME to get the detail of NPC

* Simulator: the behavior simulation environment whose architecture is similar to NEMU
* Core: hardware design and RTL code of CPU
  * IFU: instruction fetch unit
  * IDU: instruction decode unit
  * EXU: Execute unit
  * MEM: read/write memory control(LSU)
  * WB: write back unit
  * SEG: segment register in each pipeline stage
  * PUBLIC: Common modules like AXI-arbiter or macro definition
* Type `make run` in shell under the sub-directory `simulator` to run bare code.

  
  