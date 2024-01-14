module Control_Unit (
        opcode,
        Funct,
        Zero,
        Reg_Dst,
        Extend_5,
        Extend_Sign,
        ALU_Op_1,
        ALU_Op_2,
        To_Reg,
        Reg_Write,
        Mem_Write,
        Memory_Byte,
        Mem_Sign,
        PC_MUX,
        IFJ,
        Branch,
        ALU_OP
    );

    input wire [5 : 0] opcode;
    input wire [5 : 0] Funct;        // used by r-type,
    input wire Zero;

    output [1 : 0] Reg_Dst;          // rd,rt,[31] as the addr
    output Extend_5;                 // 无符号拓展5bits，rs[4:0]或shamt
    output wire Extend_Sign;         // extend 16的符号,1为符号拓展
    output ALU_Op_1;                 // 0 means rs, 1 means zero extended shamt
    output ALU_Op_2;                 // 0 means rt, 1 means extended imm16无论是零还是符号拓展
    output [1 : 0] To_Reg;           // 哪个数据去rf，alu, mem, pc+4
    output Reg_Write;                // 是否写入寄存器

    inout  Mem_Write;                // 是否写入dm

    output wire [1 : 0] Memory_Byte; // control the data have been get before MemRead mux and the length of data ready to write to data memory
    output Mem_Sign;                 // 读出的数据是否需要无符号拓展
    output PC_MUX;                   // PC(Branch)或者IFJ
    output IFJ;                      // 无条件地址，j型或者寄存器
    output Branch;                   // directly used by
    output wire [3 : 0] ALU_OP;

    wire is_r_type = ~| opcode; // opcode == 6'b000000;
    /*
    当且仅当是R型指令，此值为1
    所以缩位或非操作
    （就是第一位和第二位或，结果再跟第三位或，如此到结尾）
    可以确定这个值（opcode）是否为全0，
    这个结果再取非，如果为1就意味着是R型指令，
    相当于这是个R型指令的flag
    R-R
    */
    // R
    wire i_add  = is_r_type & (Funct == 6'b100000); // add
    wire i_addu = is_r_type & (Funct == 6'b100001); // addu
    wire i_sub  = is_r_type & (Funct == 6'b100010); // sub
    wire i_subu = is_r_type & (Funct == 6'b100011); // subu
    wire i_and  = is_r_type & (Funct == 6'b100100); // and
    wire i_or   = is_r_type & (Funct == 6'b100101); // or
    wire i_xor  = is_r_type & (Funct == 6'b100110); // xor
    wire i_nor  = is_r_type & (Funct == 6'b100111); // nor
    wire i_slt  = is_r_type & (Funct == 6'b101010); // slt
    wire i_sltu = is_r_type & (Funct == 6'b101011); // sltu
    wire i_sll  = is_r_type & (Funct == 6'b000000); // sll
    wire i_sllv = is_r_type & (Funct == 6'b000100); // sllv
    wire i_srl  = is_r_type & (Funct == 6'b000010); // srl
    wire i_srlv = is_r_type & (Funct == 6'b000110); // srlv
    wire i_sra  = is_r_type & (Funct == 6'b000011); // sra
    wire i_srav = is_r_type & (Funct == 6'b000111); // srav
    wire i_jr   = is_r_type & (Funct == 6'b001000); // jr
    wire i_jalr = is_r_type & (Funct == 6'b001001); // jalr

    // I 
    wire i_addi = (opcode == 6'b001000); // addi
    wire i_andi = (opcode == 6'b001100); // andi
    wire i_ori  = (opcode == 6'b001101); // ori
    wire i_slti = (opcode == 6'b001010); // slti
    wire i_lui  = (opcode == 6'b001111); // lui
    wire i_beq  = (opcode == 6'b000100); // beq
    wire i_bne  = (opcode == 6'b000101); // bne
    wire i_lw   = (opcode == 6'b100011); // lw
    wire i_lh   = (opcode == 6'b100001); // lh
    wire i_lhu  = (opcode == 6'b100101); // lhu
    wire i_lb   = (opcode == 6'b100000); // lb
    wire i_lbu  = (opcode == 6'b100100); // lbu
    wire i_sw   = (opcode == 6'b101011); // sw
    wire i_sh   = (opcode == 6'b101001); // sh
    wire i_sb   = (opcode == 6'b101000); // sb

    // J
    wire i_j    = (opcode == 6'b000010); // j
    wire i_jal  = (opcode == 6'b000011); // jal

    // bind wire to output signal wire
    assign Reg_Dst[1]       = i_jal  | i_jalr ;
    assign Reg_Dst[0]       = i_addi | i_andi | i_ori  | i_lui  | i_lw   | i_slti | i_lb | i_lbu | i_lh | i_lhu;
    assign Extend_5         = i_sll  | i_srl  | i_sra;
    assign Extend_Sign      = i_addi | i_lw   | i_sw   | i_slti | i_lb   | i_lbu  | i_lh | i_lhu | i_sb | i_sh;
    assign ALU_Op_1         = i_sll  | i_srl  | i_sra  | i_sllv | i_srlv | i_srav;
    assign ALU_Op_2         = Extend_Sign     | i_andi | i_ori  | i_lui;
    assign To_Reg[1]        = i_jal  | i_jalr;
    assign To_Reg[0]        = i_lw   | i_lh   | i_lhu  | i_lb   | i_lbu;
    assign Reg_Write        = ~(i_jr & i_sw   & i_beq  & i_bne  & i_j    & i_sb   & i_sh);
    assign Mem_Write        = i_sw   | i_sb   | i_sh;
    assign Memory_Byte[1]   = i_lb   | i_lbu  | i_lh   | i_lhu  | i_sh   | i_sb;
    assign Memory_Byte[0]   = i_lb   | i_lbu  | i_sb;
    assign Mem_Sign         = i_lw   | i_lb   | i_lh;
    assign PC_MUX           = i_jr   | i_j    | i_jal  | i_jalr;
    assign IFJ              = i_jr   | i_jalr;

    assign ALU_OP[3] = i_addu | i_sll | i_sllv | i_sra  | i_srav | i_srl  | i_srlv | i_subu | i_lui;
    assign ALU_OP[2] = i_nor  | i_slt | i_sltu | i_sra  | i_srav | i_srl  | i_srlv | i_xor  | i_slti;
    assign ALU_OP[1] = i_and  | i_or  | i_sll  | i_sllv | i_slt  | i_sltu | i_andi | i_lui  | i_ori | i_slti;
    assign ALU_OP[0] = i_nor  | i_or  | i_sltu | i_sra  | i_srav | i_sub  | i_subu | i_lui  | i_ori | i_beq | i_bne ;

    assign Branch = (i_beq  &  Zero) | (i_bne  &  (~Zero));

    always @(opcode)
    begin
        $display("\t\topcode: %6b, andi: %1b, aluop2=%4b, funct: %6b", opcode, i_andi, ALU_OP, Funct);
    end

endmodule
