/*
add / addi
sub / beq
and / andi
or
xor
nor
slt
sltu
addu
subu
sll / sllv
lui
srl / srlv
sra
bne
*/
module ALU (
        In_1,
        In_2,
        ALU_Op,
        Out,
        Zero_Out
    );

    input   wire signed [31 : 0]  In_1;   // operand 1, rs or s(shift used)
    input   wire signed [31 : 0]  In_2;   // operand 2, rt or immediate
    input   wire        [3 : 0]   ALU_Op; // operator

    output  reg  signed [31 : 0]  Out;        // Out
    output  wire                  Zero_Out;   // If it's zero

    reg [32 : 0] temp;

    always @(*)
    begin
        case (ALU_Op)
            // immediate number comes from mux
            4'b0000:
            begin
                // add, addi
                Out <= In_1 + In_2;
            end
            4'b0001:
            begin
                // sub, beq
                Out <= In_1 - In_2;
            end
            4'b0010:
            begin
                // and, andi
                Out <= In_1 & In_2;
            end
            4'b0011:
            begin
                // or, ori
                Out <= In_1 | In_2;
            end
            4'b0100:
            begin
                // xor
                Out <= In_1 ^ In_2;
            end
            4'b0101:
            begin
                // nor
                Out <= ~(In_1 | In_2);
            end
            4'b0110:
            begin
                // slt, set 1 if lower than
                Out <= (In_1 < In_2) ? 32'b1 : 32'b0;
            end
            4'b0111:
            begin
                // sltu, unsigned slt, if unsigned lower than, then set 1
                Out <= ({1'b0, In_1} < {1'b0, In_2}) ? 32'b1 : 32'b0;
            end
            4'b1000:
            begin
                // addu
                temp = {1'b0, In_1} + {1'b0, In_2};
                Out = temp[31 : 0];
            end
            4'b1001:
            begin
                // subu
                temp = {1'b0, In_1} - {1'b0, In_2};
                Out = temp[31 : 0];
            end
            4'b1010:
            begin
                // sll or sllv, shift left
                Out <= (In_2 << {1'b0, In_1[4 : 0]});
            end
            4'b1011:
            begin
                // lui, reg <- immediate << 16
                Out <= (In_2 << 'd16);
            end
            4'b1100:
            begin
                // srl or srlv, shift right logically
                Out <= (In_2 >> {1'b0, In_1[4 : 0]});
            end
            4'b1101:
            begin
                // sra, right shift arithmetically
                Out <= (In_2 >>> {1'b0, In_1[4 : 0]});
            end
            4'b1110:
            begin
                // bne, branch if not equal
                Out <= (In_1 == In_2) ? 32'b1 : 32'b0;
            end
            default:
            begin
                Out <= In_1;
            end
        endcase
        $display("In_1: 0x%8X, ALU_Op: 0x%4b, In_2: 0x%8X, Out: 0x%8x", In_1, ALU_Op, In_2, Out);
    end

    assign Zero_Out = (Out == 32'b0) ? 1'b1 : 1'b0;

endmodule

