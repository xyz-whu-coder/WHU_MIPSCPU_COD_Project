module MCCPU(
        clk,
        rst,
        instruction,
        Data_Read,
        PC,
        Mem_Write,
        address,
        Data_Write,
        Reg_Sel,
        Reg_Data
    );

    input           clk;          // clock
    input           rst;          // reset

    output [31 : 0] instruction;  // instruction
    output [31 : 0] PC;           // PC address

    input  [31 : 0] Data_Read;    // data from data memory

    output          Mem_Write;    // memory write
    output [31 : 0] address;      // memory address
    output [31 : 0] Data_Write;   // data to data memory

    input  [4 : 0]  Reg_Sel;      // register selection (for debug use)

    output [31 : 0] Reg_Data;     // selected register data (for debug use)

    wire          Reg_Write;      // control signal to register write
    wire          PC_Write;       // control signal for PC write
    wire          IR_Write;       // control signal for IR write
    wire          EXT_Op;         // control signal to signed extension
    wire [3 : 0]  ALU_Op;         // ALU opertion
    wire [1 : 0]  Next_PC_Op;     // next PC operation
    wire          Instr_Data_Mem; // memory access for instruction or data

    wire [1 : 0]  Write_Data_Sel; // (register) write data selection
    wire [1 : 0]  GPR_Sel;        // general purpose register selection

    wire          EXT_5_Src;      // source of ext 5
    wire [31 : 0] Ext_5;          // zero extended 5bits shamt or RS[4 : 0]

    wire [1 : 0]  ALU_Src_A;      // ALU source for S
    wire [1 : 0]  ALU_Src_B;      // ALU source for T
    wire          Zero;           // ALU ouput zero


    wire [31 : 0] ALU_Result;     // alu result
    wire [31 : 0] ALU_Out;        // alu out

    wire [4 : 0]  Reg_S;          // Reg_S
    wire [4 : 0]  Reg_T;          // Reg_T
    wire [4 : 0]  Reg_D;          // Reg_D
    wire [5 : 0]  opcode;         // opcode
    wire [5 : 0]  funct;          // funct
    wire [4 : 0]  shamt;
    wire [4 : 0]  Src_5_Bits;
    wire [15 : 0] Num_16;         // 16-bit immediate
    wire [31 : 0] Num_32;         // 32-bit immediate
    wire [25 : 0] Num_26;         // 26-bit immediate (address)
    wire [4 : 0]  Reg_Addr_Write; // register address for write
    wire [31 : 0] Reg_Data_Write; // register write data
    wire [31 : 0] Reg_Data_S;     // register data specified by Reg_S
    wire [31 : 0] Reg_Data_T;     // register data specified by Reg_T
    wire [31 : 0] S;              // register S
    wire [31 : 0] T;              // register T
    wire [31 : 0] ALU_A;          // ALU A
    wire [31 : 0] ALU_B;          // ALU B
    wire [31 : 0] data;           // data
    wire [31 : 0] Next_PC;        // Next_PC

    assign opcode = instruction[31 : 26];  // opcode
    assign funct  = instruction[5 : 0];    // funct
    assign Reg_S  = instruction[25 : 21];  // Reg_S
    assign Reg_T  = instruction[20 : 16];  // Reg_T
    assign Reg_D  = instruction[15 : 11];  // Reg_D
    assign shamt  = instruction[10 : 6];
    assign Num_16 = instruction[15 : 0];   // 16-bit immediate
    assign Num_26 = instruction[25 : 0];   // 26-bit immediate

    // instantiation of control unit
    Control_Unit U_CTRL (
                     .clk(clk),
                     .rst(rst),
                     .Zero(Zero),
                     .opcode(opcode),
                     .funct(funct),
                     .Reg_Write(Reg_Write),
                     .Mem_Write(Mem_Write),
                     .PC_Write(PC_Write),
                     .IR_Write(IR_Write),
                     .EXT_Op(EXT_Op),
                     .EXT_5_Src(EXT_5_Src),
                     .ALU_Op(ALU_Op),
                     .PC_Source(Next_PC_Op),
                     .ALU_Src_A(ALU_Src_A),
                     .ALU_Src_B(ALU_Src_B),
                     .GPR_Sel(GPR_Sel),
                     .Write_Data_Sel(Write_Data_Sel),
                     .Instr_Data_Mem(Instr_Data_Mem)
                 );

    // instantiation of PC
    flopenr #(32) U_PC (
                .clk(clk),
                .rst(rst),
                .enable(PC_Write),
                .d(Next_PC),
                .q(PC)
            );

    // mux for PC source
    mux4 #(32) U_MUX4_PC (
             .d0(ALU_Result), .d1(ALU_Out), .d2({PC[31 : 28], Num_26, 2'b00}), .d3(Reg_Data_S),     // 当beq的state3(exe)时，src=1，结果为state2的运算结果aluout(branch addr)
             .s(Next_PC_Op),
             .y(Next_PC)
         );

    mux2 #(32) U_MUX_ADR (
             .d0(PC), .d1(ALU_Out),
             .s(Instr_Data_Mem),
             .y(address)
         );

    // instantiation of IR
    // 保证instrution不因clk上升沿时readdata的变化而变
    flopenr #(32) U_IR (
                .clk(clk),
                .rst(rst),
                .enable(IR_Write),
                .d(Data_Read),
                .q(instruction)
            );

    // instantiation of Data Register
    flopr  #(32) U_DataR(
               .clk(clk),
               .rst(rst),
               .d(Data_Read),
               .q(data)
           );

    // instantiation of register file
    Reg_File U_RF (
                 .clk(clk),
                 .rst(rst),
                 .Reg_File_Write(Reg_Write),
                 .Reg_S(Reg_S),
                 .Reg_T(Reg_T),
                 .Reg_Addr_Write(Reg_Addr_Write),
                 .Reg_Data_Write(Reg_Data_Write),
                 .Reg_Sel(Reg_Sel),
                 .Reg_Data_S(Reg_Data_S),
                 .Reg_Data_T(Reg_Data_T),
                 .Reg_Data(Reg_Data)
             );

    // A register
    flopr  #(32) U_AR(
               .clk(clk),
               .rst(rst),
               .d(Reg_Data_S),
               .q(S)
           );

    // B register
    flopr  #(32) U_BR(
               .clk(clk),
               .rst(rst),
               .d(Reg_Data_T),
               .q(T)
           );

    // mux for ALU A
    mux4 #(32) U_MUX_ALU_A (
             .d0(PC), .d1(S), .d2(Ext_5), .d3(32'b0),
             .s(ALU_Src_A),
             .y(ALU_A)
         );

    // mux for zero extension 5bits
    mux2 #(5) u_mux_ext5(
             .d0(shamt), .d1(S[4 : 0]),
             .s(EXT_5_Src),
             .y(Src_5_Bits)
         );

    Extend_5 U_EXT_5(
                 .In(Src_5_Bits),
                 .Out(Ext_5)
             );


    // mux for signed extension or zero extension
    Extend_16 U_EXT_16 (
            .Num_16(Num_16),
            .EXT_Op(EXT_Op),
            .Num_32(Num_32)
        );

    // mux for ALU B
    mux4 #(32) U_MUX_ALU_B (
             .d0(T), .d1(4), .d2(Num_32), .d3({{14{Num_16[15]}}, Num_16, 2'b00}),
             .s(ALU_Src_B),
             .y(ALU_B)
         );

    // instantiation of ALU
    ALU U_ALU (
            .In_1(ALU_A),
            .In_2(ALU_B),
            .ALU_Op(ALU_Op),
            .Out(ALU_Result),
            .Zero_Out(Zero)
        );

    // instantiation of ALUout Register
    flopr  #(32) U_ALUR(
               .clk(clk),
               .rst(rst),
               .d(ALU_Result),
               .q(ALU_Out)
           );

    // mux for register data to write
    mux4 #(5) U_MUX4_GPR_A3 (
             .d0(Reg_D), .d1(Reg_T), .d2(5'b11111), .d3(5'b0),
             .s(GPR_Sel),
             .y(Reg_Addr_Write)
         );

    // mux for register address to write
    mux4 #(32) U_MUX4_GPR_WD (
             .d0(ALU_Out), .d1(data), .d2(PC), .d3(32'b0),
             .s(Write_Data_Sel),
             .y(Reg_Data_Write) // PC + 4 when in state1
         );

    assign Data_Write = T;

endmodule
