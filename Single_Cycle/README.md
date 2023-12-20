# Experiment Part I -- Single-Cycle Implementation of CPU Based on MIPS Instruction Set

## Supported Instructions

- 对示例单周期CPU进行指令扩展，至少支持以下指令（<span style = "color:red">红色</span> 和 <span style = "color:blue">蓝色</span> 为增加的指令）
    - add/sub/and/or/slt/sltu/addu/subu   
    - addi/ori/lw/sw/beq
    - j/jal
    - <span style = "color:red">sll/nor/lui/slti/bne/andi/srl/sllv/srlv/jr/jalr</span>
    - <span style = "color:blue">xor/sra/srav</span>
    - <span style = "color:blue">lb/lh/lbu/lhu/sb/sh (数据在内存中以小端形式存储little endian)</span>

## Requirements and Report

验收要求&实验报告（占55%，以下二选一）

- 在ModelSim仿真中CPU加载mipstest_extloop.asm、extendedtest.asm和studentnosorting_cut.asm对应代码运行正确 （up to 45%）
    - 如果单周期SCPU只完成仿真，没有下载到开发板，需扩展上述 <span style = "color:red">红色</span> + <span style = "color:blue">蓝色</span> 指令
    - extendedtest.asm在Mars中做对比时，需设置为Settings -> Memory Configuration -> Compact, Data at address 0

- 在Nexys 4 DDR 开发板上正确实现学号排序 (up to 55%)
    - 具体说明见后
    - 如果单周期CPU实现下板仿真，也需扩展上述 <span style = "color:red">红色</span> + <span style = "color:blue">蓝色</span> 指令，对学号排序前和排序后的结果拍照并放入实验报告。

