// only zero extend 5 bits to 32bits
// All are zero extend, will be used in sll, srl etc shift tool.
module Extend_5 (
        In,
        Out
    );

    input  wire [4 : 0]  In;

    output wire [31 : 0] Out;

    assign Out = {27'b0, In};

endmodule

module Extend_16(
        Num_16,
        EXT_Op,
        Num_32
    );

    input  [15 : 0] Num_16;
    input           EXT_Op;

    output [31 : 0] Num_32;

    // signed-extension(EXT_Op != 0) or zero extension(EXT_Op == 0)
    assign Num_32 = (EXT_Op) ? {{16{Num_16[15]}}, Num_16} : {16'b0, Num_16};

endmodule
