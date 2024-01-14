module Reg_File(
        clk,
        rst,
        Reg_File_Write,
        Reg_S,
        Reg_T,
        Reg_Addr_Write,
        Reg_Data_Write,
        Reg_Sel,
        Reg_Data_S,
        Reg_Data_T,
        Reg_Data
    );

    input           clk;
    input           rst;
    input           Reg_File_Write;
    input  [4 : 0]  Reg_S;
    input  [4 : 0]  Reg_T;
    input  [4 : 0]  Reg_Addr_Write;
    input  [31 : 0] Reg_Data_Write;
    input  [4 : 0]  Reg_Sel;

    output [31 : 0] Reg_Data_S;
    output [31 : 0] Reg_Data_T;
    output [31 : 0] Reg_Data;

    reg    [31 : 0] Reg_File[31 : 0];

    integer idx;

    always @(posedge clk, posedge rst)
    begin
        if (rst)
        begin
            // reset
            for (idx = 0; idx < 32; idx = idx + 1)
            begin
                Reg_File[idx] <= 0;
            end
        end
        else
        begin
            if (Reg_File_Write)
            begin
                Reg_File[Reg_Addr_Write] <= Reg_Data_Write;
                $display("r[%02d] = 0x%8X,", Reg_Addr_Write, Reg_Data_Write);
                for(idx = 0; idx < 32; idx = idx + 1)
                begin
                    $display("\t\t\t\t\t\tr[%02d] ($%02d) = 0x%8X", idx, idx, Reg_File[idx]);
                end
            end
        end
    end

    assign Reg_Data_S = (Reg_S == 0) ? 0 : Reg_File[Reg_S];
    assign Reg_Data_T = (Reg_T == 0) ? 0 : Reg_File[Reg_T];
    assign Reg_Data = (Reg_Sel == 0) ? 0 : Reg_File[Reg_Sel];

endmodule
