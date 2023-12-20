module Next_PC (
        PC,
        IFJ,
        PC_MUX,
        Next_PC
    );

    input [31 : 0] PC; // 来自pc+4 or branch
    input [31 : 0] IFJ;
    input PC_MUX;

    output [31 : 0] Next_PC;

    assign Next_PC = (PC_MUX == 1'b0) ? PC : IFJ;

endmodule
