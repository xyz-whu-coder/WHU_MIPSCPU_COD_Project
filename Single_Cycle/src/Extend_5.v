module Extend_5 (
        In,
        Out
    );

    input  wire [4 : 0]  In;
    output wire [31 : 0] Out;

    assign Out = {27'b0, In}; // zero-extension

endmodule
