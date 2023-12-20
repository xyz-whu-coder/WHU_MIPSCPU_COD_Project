module SCCPU(
        clk,
        rst,
        instr,
        Data_Read,
        Mem_Write,
        PC,
        ALU_Out,
        Data_Write,
        Memory_Byte,
        Reg_Sel,
        Reg_Data
    );

    input clk;                  // input :  cpu clock
    input rst;                  // input :  reset
    input [31 : 0] instr;       // input :  instruction
    input [31 : 0] Data_Read;   // input :  data to cpu
    inout Mem_Write;            // output :  memory write signal

    output [31 : 0] PC;         // output :  PC
    output [31 : 0] ALU_Out;    // output :  address from cpu to memory
    output [31 : 0] Data_Write; // output :  RD2, data from cpu to memory
    output [1 : 0] Memory_Byte; // output :  length of data out

    input [4 : 0] Reg_Sel;      // input :  register selection

    output [31 : 0] Reg_Data;   // output :  register data

    // 控制信号
    wire [5 : 0] opcode;
    wire [5 : 0] Funct;
    wire [1 : 0] Reg_Dst;
    wire Extend_5;
    wire ALU_Op_1;
    wire ALU_Op_2;
    wire [1 : 0] To_Reg;
    wire Reg_Write;
    wire Mem_Sign;
    wire PC_MUX;
    wire IFJ;
    wire Branch;
    wire [3 : 0] ALU_OP;

    // 数据线
    // address
    wire [4 : 0] Reg_S;
    wire [4 : 0] Reg_T;
    wire [4 : 0] Reg_D;

    // data
    wire [4 : 0]  shamt;
    wire [15 : 0] Num_b16; // also as offset(the same position)
    wire [25 : 0] Num_b26;
    wire [31 : 0] Reg_Data_1;

    /* Next_PC*/
    wire [31 : 0] Next_PC;   // the final next pc out to sim top

    /* RegFile*/
    wire [31 : 0] Write_Data; // data to regfile
    wire [4 : 0]  Reg_Addr;   // write address of reg, also known as A3
    wire [31 : 0] RD1;
    //RD2 :  Data_Write, directly picked from RD2(Reg_T)

    /*ALU*/
    wire [31 : 0] ALU_In_1;
    wire [31 : 0] ALU_In_2;
    wire Zero;
    // out :  ALU_Out

    /*Extended 16bits*/
    wire [31 : 0] EXT_16; // 区分符号和零拓展，使用模块得到其一结果
    wire Extend_Sign;

    wire [4 : 0]  In_b5;  // 去零拓展5bits
    wire [31 : 0] EXT_5;  // shamt和rs[4 : 0]拓展到32位都是零拓展

    wire [31 : 0] Branch_Added; // pc+4 or pc+4+offset

    wire [31 : 0] J_Slice;

    wire [31 : 0] Load_Data;

    // 读取instruction
    assign opcode  = instr[31 : 26];
    assign Funct   = instr[5 : 0];
    assign Reg_S   = instr[25 : 21];
    assign Reg_T   = instr[20 : 16];
    assign Reg_D   = instr[15 : 11];
    assign Num_b16 = instr[15 : 0];
    assign Num_b26 = instr[25 : 0];
    assign shamt   = instr[10 : 6];

    Control_Unit u_cu(
                     .opcode        (opcode),
                     .Funct         (Funct),
                     .Zero          (Zero),
                     .Reg_Dst       (Reg_Dst),
                     .Extend_5      (Extend_5),
                     .Extend_Sign   (Extend_Sign),
                     .ALU_Op_1      (ALU_Op_1),
                     .ALU_Op_2      (ALU_Op_2),
                     .To_Reg        (To_Reg),
                     .Reg_Write     (Reg_Write),
                     .Mem_Write     (Mem_Write),
                     .Memory_Byte   (Memory_Byte),
                     .Mem_Sign      (Mem_Sign),
                     .PC_MUX        (PC_MUX),
                     .IFJ           (IFJ),
                     .Branch        (Branch),
                     .ALU_OP        (ALU_OP)
                 );

    PC u_PC(
           .clk     (clk),
           .rst     (rst),
           .Next_PC (Next_PC),
           .PC      (PC)
       );

    Next_PC u_NPC(
                .PC         (Branch_Added),
                .IFJ        (J_Slice),
                .PC_MUX     (PC_MUX),
                .Next_PC    (Next_PC)
            );

    Branch_Add u_Branch_Add(
                   .PC              (PC),
                   .EXT_16          (EXT_16),
                   .Branch          (Branch),
                   .Branch_Added    (Branch_Added)
               );

    IFJ u_IFJ(
            .PC      (PC[31 : 28]),
            .Num_b26 (Num_b26),
            .Reg_S   (RD1),
            .jump    (IFJ),
            .IFJ     (J_Slice)
        );

    Reg_File u_Reg_File(
                 .clk           (clk),
                 .rst           (rst),
                 .Reg_S         (Reg_S),
                 .Reg_T         (Reg_T),
                 .Reg_D         (Reg_Addr),
                 .Data_Write    (Write_Data),
                 .Write_RF_Ctrl (Reg_Write),
                 .Reg_Sel       (Reg_Sel),
                 .RD1           (RD1),
                 .RD2           (Data_Write),
                 .Reg_Data      (Reg_Data)
             );

    Extend_16 u_Extend_16(
                  .In   (Num_b16),
                  .sign (Extend_Sign),
                  .Out  (EXT_16)
              );

    MUX_2 #(5) u_mux2_WhotoEx5(
              .In_1     (RD1[4 : 0]),
              .In_2     (shamt),
              .In_Sel   (Extend_5),
              .Out      (In_b5)
          );


    Extend_5 u_ext5(
                 .In    (In_b5 ),
                 .Out   (EXT_5 )
             );

    MUX_2 #(32) u_mux2_ALUoprand1(
              .In_1     (RD1),
              .In_2     (EXT_5),
              .In_Sel   (ALU_Op_1),
              .Out      (ALU_In_1)
          );

    MUX_2 #(32) u_mux2_ALUoprand2(
              .In_1     (Data_Write),
              .In_2     (EXT_16),
              .In_Sel   (ALU_Op_2),
              .Out      (ALU_In_2)
          );

    ALU u_ALU(
            .In_1       (ALU_In_1),
            .In_2       (ALU_In_2),
            .ALU_Op     (ALU_OP),
            .Out        (ALU_Out),
            .Zero_Out   (Zero)
        );

    Load_Data u_Load_Data(
                  .Memory_Byte  (Memory_Byte),
                  .address      (ALU_Out[1 : 0]),
                  .sign         (Mem_Sign),
                  .Data_In      (Data_Read),
                  .Data_Out     (Load_Data)
              );

    MUX_3 #(5) u_mux3_regdst(
              .In_1     (Reg_D),
              .In_2     (Reg_T),
              .In_3     (5'd31),
              .In_Sel   (Reg_Dst),
              .Out      (Reg_Addr)
          );

    MUX_3 #(32) u_mux3_toreg(
              .In_1     (ALU_Out),
              .In_2     (Load_Data),
              .In_3     (PC + 'd4),
              .In_Sel   (To_Reg),
              .Out      (Write_Data)
          );



endmodule
