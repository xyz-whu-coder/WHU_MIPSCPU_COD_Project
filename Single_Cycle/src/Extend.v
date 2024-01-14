module Extend_5 (
        In,
        Out
    );

    input  wire [4 : 0]  In;
    output wire [31 : 0] Out;

    assign Out = {27'b0, In}; // zero-extension(5 -> 32)

endmodule

module Extend_16 (
        In,
        sign, // 0: zero-extension; 1: signed extension
        Out
    );

    input wire [15 : 0] In;
    input wire sign;

    output wire [31 : 0] Out;

    assign Out = (sign == 1) ? ({{16{In[15]}}, In}) : {{16'b0}, In};

endmodule
