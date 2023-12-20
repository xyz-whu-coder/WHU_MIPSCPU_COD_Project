# Experiment Part II -- Multi-Cycle Implementation of CPU Based on MIPS Instruction Set

## Supported Instructions

- 实现多周期CPU，至少支持以下指令（<span style = "color:red">红色</span> 为增加的指令）
    - add/sub/and/or/slt/sltu/addu/subu   
    - addi/ori/lw/sw/beq
    - j/jal
    - <span style="color:red">sll/nor/lui/slti/bne/andi/srl/sllv/srlv/jr/jalr</span>
    
## Requirements and Report

- 能够正确处理多周期CPU中的状态机
- 指令和数据放在同一个存储器
- 验收要求&实验报告（占30%，以下二选一）
  - 在ModelSim仿真中CPU加载studentnosorting_cut.asm对应代码运行正确 （up to 18%）
  - 在Nexys 4 DDR2 开发板上正确实现学号排序，对学号排序前和排序后的结果拍照并放入实验报告(up to 30%) 。
