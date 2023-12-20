module Instruction_Memory(
        address,
        Instr_Out
    );

    input  [8 : 2]  address;
    output [31 : 0] Instr_Out;

    reg [31 : 0] ROM [127 : 0];

    assign Instr_Out = ROM[address]; // word aligned

endmodule
