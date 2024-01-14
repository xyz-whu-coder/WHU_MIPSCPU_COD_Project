module Reg_File (
        clk,
        rst,
        Reg_S,
        Reg_T,
        Reg_D,
        Data_Write,
        Write_RF_Ctrl,         
        Reg_Sel,
        RD1,
        RD2,
        Reg_Data
    );

    input wire clk;                 // clock signal
    input wire rst;                 // reset signal
    input wire [4 : 0]  Reg_S;      // Reg_S
    input wire [4 : 0]  Reg_T;      // Reg_T
    input wire [4 : 0]  Reg_D;      // Reg_D
    input wire [31 : 0] Data_Write; // if used, write to Reg_D(Reg_D)
    input wire Write_RF_Ctrl;       // whether write to rf now, Reg_D<-Data_Write
    input [4 : 0] Reg_Sel;

    output wire [31 : 0] RD1;
    output wire [31 : 0] RD2;
    output [31 : 0] Reg_Data;

    reg [31 : 0] Reg_File[31 : 0];  // 32 registers

    integer idx;

    // read
    assign RD1 = (Reg_S == 5'b0) ? 32'b0 : Reg_File[Reg_S];
    assign RD2 = (Reg_T == 5'b0) ? 32'b0 : Reg_File[Reg_T];

    always @(posedge clk, posedge rst)
    begin
        for(idx = 0; idx < 32; idx = idx + 1)
        begin
            $display("\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\tr[%02d] ($%02d) = 0x%8X", idx, idx, Reg_File[idx]);
        end
        if (rst)
        begin
            //reset
            for(idx = 0; idx < 32; idx = idx + 1)
            begin
                Reg_File[idx] <= 32'b0;
            end
        end
        else
        begin
            if (Write_RF_Ctrl)
            begin
                Reg_File[Reg_D] <= (Reg_D == 0) ? 32'b0 : Data_Write;
                $display("\n\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\tr[%02d] ($%02d) = 0x%8X,", Reg_D, Reg_D, Data_Write);
            end
        end
    end

    assign Reg_Data = (Reg_Sel != 0) ? Reg_File[Reg_Sel] : 0;

endmodule
