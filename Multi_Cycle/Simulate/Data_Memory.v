// data memory
module Data_Memory(
        clk,
        DM_Write,
        address,
        Data_In,
        Data_Out
    );

    input           clk;
    input           DM_Write;
    input  [8 : 2]  address;
    input  [31 : 0] Data_In;

    output [31 : 0] Data_Out;

    reg    [31 : 0] Data_Memory[127 : 0];

    wire   [31 : 0] Address_Byte;

    assign Address_Byte = address << 2;
    assign Data_Out = Data_Memory[Address_Byte[8 : 2]];

    integer idx;

    always @(posedge clk)
    begin
        if (DM_Write)
        begin
            for (idx = 0; idx < 66; idx = idx + 1)
            begin
                $display("\tData_Memory[0x%8X] = 0x%8X", idx << 2, Data_Memory[idx]);
            end
            Data_Memory[Address_Byte[8 : 2]] <= Data_In;
            $display("\nData_Memory[0x%8X] = 0x%8X\n", Address_Byte, Data_In);
        end
    end

endmodule
