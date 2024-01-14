module mccomp(
        clk,
        rstn,
        Reg_Sel,
        Reg_Data
    );

    input           clk;
    input           rstn;
    input  [4 : 0]  Reg_Sel;
    output [31 : 0] Reg_Data;

    wire   [31 : 0] instruction;
    wire   [31 : 0] PC;
    wire            Mem_Write;
    wire   [31 : 0] DM_Address;
    wire   [31 : 0] DM_Data_In;
    wire   [31 : 0] DM_Data_Out;

    wire rst = ~rstn;

    // instantiation of single-cycle CPU
    MCCPU U_MCCPU(
              .clk(clk),                 // input:  cpu clock
              .rst(rst),                 // input:  reset
              .instruction(instruction), // input:  instruction
              .Data_Read(DM_Data_Out),   // input:  data to cpu
              .Mem_Write(Mem_Write),     // output: memory write signal
              .PC(PC),                   // output: PC
              .address(DM_Address),      // output: address from cpu to memory
              .Data_Write(DM_Data_In),   // output: data from cpu to memory
              .Reg_Sel(Reg_Sel),         // input:  register selection
              .Reg_Data(Reg_Data)        // output: register data
          );

    // instantiation of data memory
    Data_Memory U_DM(
           .clk(clk),                   // input:  cpu clock
           .DM_Write(Mem_Write),        // input:  ram write
           .address(DM_Address[8 : 2]), // input:  ram address
           .Data_In(DM_Data_In),        // input:  data to ram
           .Data_Out(DM_Data_Out)       // output: data from ram
       );


endmodule

