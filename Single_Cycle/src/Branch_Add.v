module Branch_Add (
        PC,
        EXT_16,
        Branch,
        Branch_Added
    );

    input [31 : 0] PC;
    input [31 : 0] EXT_16;
    input Branch;

    output [31 : 0] Branch_Added;

    assign Branch_Added = (Branch == 1'b1) ? PC + 4 + (EXT_16 <<< 2) : PC + 4;

endmodule
