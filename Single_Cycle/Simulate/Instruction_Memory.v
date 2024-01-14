module Instruction_Memory(
        address,
        Instr_Out
    );

    input  [8 : 2]  address;
    output [31 : 0] Instr_Out;

    reg [31 : 0] ROM [127 : 0];

    integer idx;

    always @(*)
    begin
        for (idx = 0; idx < 66; idx = idx + 1)
        begin
            $display("Instruction_Memory[0x%8X] = 0x%8X", idx << 2, ROM[idx]);
        end
    end

    assign Instr_Out = ROM[address]; // word aligned

endmodule
