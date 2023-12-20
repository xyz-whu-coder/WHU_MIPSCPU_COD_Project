
// data memory
module dm(
        clk,
        DMWr,
        addr,
        din,
        dout
    );
    input          clk;
    input          DMWr;
    input  [8 : 2]   addr;
    input  [31 : 0]  din;
    output [31 : 0]  dout;

    reg [31 : 0] dmem[127 : 0];
    wire [31 : 0] addrByte;

    assign addrByte = addr<<2;

    assign dout = dmem[addrByte[8 : 2]];

    integer idx;

    always @(posedge clk)
    begin
        for (idx = 0; idx < 66; idx = idx + 1)
        begin
            $display("\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\tData_Memory[0x%8X] = 0x%8X", idx << 2, dmem[idx]);
        end
        if (DMWr)
        begin
            dmem[addrByte[8 : 2]] <= din;
            $display("Data_Memory[0x%8X] = 0x%8X,", addrByte, din);
        end
    end

endmodule
