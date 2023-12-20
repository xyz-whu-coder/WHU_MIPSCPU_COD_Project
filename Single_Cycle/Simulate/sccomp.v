module sccomp(
        clk,
        rstn,
        Reg_Sel,
        Reg_Data
    );

    input           clk;
    input           rstn;
    input [4 : 0]   Reg_Sel;

    output [31 : 0] Reg_Data;

    wire [31 : 0]   instr;
    wire [31 : 0]   PC;
    wire            Mem_Write;
    wire [1 : 0]    Memory_Byte;
    wire [31 : 0]   Data_Memory_Addr;
    wire [31 : 0]   Data_Memory_In;
    wire [31 : 0]   Data_Memory_Out;

    wire rst = ~rstn;

    // instantiation of single-cycle CPU
    SCCPU   U_SCCPU(
                .clk(clk),                    // input:   cpu clock
                .rst(rst),                    // input:   reset
                .instr(instr),                // input:   instruction
                .Data_Read(Data_Memory_Out),  // input:   data to cpu
                .Mem_Write(Mem_Write),        // output:  memory write signal
                .PC(PC),                      // output:  PC
                .ALU_Out(Data_Memory_Addr),   // output:  address from cpu to memory
                .Data_Write(Data_Memory_In),  // output:  data from cpu to memory
                .Memory_Byte(Memory_Byte),    // output:  length of data out
                .Reg_Sel(Reg_Sel),            // input:   register selection
                .Reg_Data(Reg_Data)           // output:  register data
            );

    // instantiation of data memory
    Data_Memory U_Data_Memory(
                    .clk(clk),                          // input:  cpu clock
                    .Data_Memory_Write(Mem_Write),      // input:  ram write
                    .address(Data_Memory_Addr[8 : 0]),  // input:  ram address
                    .Data_In(Data_Memory_In),           // input:  data to ram
                    .Memory_Byte(Memory_Byte),          // input:  length of write data
                    .Data_Out(Data_Memory_Out)          // output: data from ram
                );

    // instantiation of intruction memory (used for simulation)
    Instruction_Memory  U_IM (
                            .address(PC[8 : 2]),     // input:  rom address
                            .Instr_Out(instr)        // output: instruction
                        );

endmodule

