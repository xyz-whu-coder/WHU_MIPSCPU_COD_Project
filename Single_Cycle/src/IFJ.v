module IFJ (
        PC,
        Num_b26,
        Reg_S,
        jump,
        IFJ
    );

    input [31 : 28] PC;
    input [25 : 0]  Num_b26;
    input [31 : 0]  Reg_S;
    input jump;
    
    output [31 : 0] IFJ;

    assign IFJ = (jump == 1'b0) ? {PC[31 : 28], Num_b26[25 : 0], 2'b00} : Reg_S;

endmodule
