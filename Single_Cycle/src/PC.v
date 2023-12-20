module PC (
        clk,
        rst,
        Next_PC,
        PC
    );

    input clk;
    input rst;
    input [31 : 0] Next_PC;
    output reg [31 : 0] PC;

    always @(posedge clk,  posedge rst)
    begin
        if (rst)
        begin
            PC <= 32'h00000000;
        end
        else
        begin
            PC <= Next_PC;
        end
    end

endmodule
