### README


#### Part1：实验波形仿真和 nvboard

* $(NPC_HOME)/lab 目录用来保存工程，需要对工程操作请 cd 到目录下再运行
* 该部分集成 sim（输出波形），imp（nvboard 板上验证）两个功能，两个功能独立使用激励文件
* 每个工程子文件目录的命名格式必须严格按照模板存放，否则编译会报错


#### Part2：单周期 CPU 波形仿真和 simulator(nemu)

* $(NPC_HOME)/naive_cpu 目录用来保存单周期 CPU 工程
* 该部分集成 sim（输出波形），run（加载到仿真环境）两个功能，两个功能独立使用激励文件