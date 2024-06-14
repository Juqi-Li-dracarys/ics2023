### READ ME before the initialization of the project


* Execute the configuration script as below:
  ```
  cd ysyx-exam
  source exam-init.sh
  ```

* Test whether the env-setting is all right, if everything is OK, then build the dynamic lib for difftest, which will be applied in later testcase for NPC
    ```
    cd ../nemu
    make menuconfig ## Switch the build target from Difftest to Linux native
    make run
    ```
    ```
    make menuconfig ## Switch the build target from Linux native to Difftest
    ```
    
* Update and execute the application ramdisk in navy-app on the NEMU
    ```
    cd ../nanos-lite
    make ARCH=riscv64-nemu update
    make ARCH=riscv64-nemu run
    ```

*  Execute the application ramdisk in navy-app on the NPC
    ```
    make ARCH=riscv64-npc run
    ```



