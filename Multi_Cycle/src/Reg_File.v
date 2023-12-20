module RF(
        clk,
        rst,
        RFWr,
        A1, A2, A3,
        WD,
        RD1, RD2,
        reg_sel,
        reg_data
    );

    input         clk;
    input         rst;
    input         RFWr;
    input  [4 : 0]  A1, A2, A3;
    input  [31 : 0] WD;
    output [31 : 0] RD1, RD2;
    input  [4 : 0]  reg_sel;

    output [31 : 0] reg_data;

    reg [31:0] Reg_File[31:0];

    integer idx;

    always @(posedge clk, posedge rst)
    begin
        if (rst)
        begin    //  reset
            for (idx = 0; idx < 32; idx = idx + 1)
            begin
                Reg_File[idx] <= 0;
            end
        end
        else
        begin
            if (RFWr)
            begin
                Reg_File[A3] <= WD;
                for(idx = 0; idx < 32; idx = idx + 1)
                begin
                    $display("\t\t\t\t\t\tr[%02d] ($%02d) = 0x%8X", idx, idx, Reg_File[idx]);
                end
                // $display("r[00-07]=0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X", 0, Reg_File[1], Reg_File[2], Reg_File[3], Reg_File[4], Reg_File[5], Reg_File[6], Reg_File[7]);
                // $display("r[08-15]=0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X", Reg_File[8], Reg_File[9], Reg_File[10], Reg_File[11], Reg_File[12], Reg_File[13], Reg_File[14], Reg_File[15]);
                // $display("r[16-23]=0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X", Reg_File[16], Reg_File[17], Reg_File[18], Reg_File[19], Reg_File[20], Reg_File[21], Reg_File[22], Reg_File[23]);
                // $display("r[24-31]=0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X", Reg_File[24], Reg_File[25], Reg_File[26], Reg_File[27], Reg_File[28], Reg_File[29], Reg_File[30], Reg_File[31]);
                $display("r[%2d] = 0x%8X,", A3, WD);
            end
        end
    end

    assign RD1 = (A1 == 0) ? 0 : Reg_File[A1];
    assign RD2 = (A2 == 0) ? 0 : Reg_File[A2];
    assign reg_data = (reg_sel == 0) ? 0 : Reg_File[reg_sel];

endmodule
