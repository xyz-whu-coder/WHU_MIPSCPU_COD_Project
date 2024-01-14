// 组合单元
/*
 ALU_Op need to suuport
 add/sub/and/or/xor/nor   all need one spectified ALU_Op
 slt/sltu/addu/subu
 lui
 sll/bne/srl/sra
 
 from mux choose one data, read from regfile or instruction itself
 these cmd only need one ALU_Op that mentioned above
 srav
 andi
 slti
 sllv
 srlv
 
 sum 14
 4bits ALU_Op
 
 deposited: these cmds need to immigrant to other unit
 */
// ALU control signal
`define ALU_NOP   4'b0000
`define ALU_ADD   4'b0001     // also addi,lw,sw
`define ALU_SUB   4'b0010     // also beq,bne
`define ALU_AND   4'b0011     // also andi
`define ALU_OR    4'b0100     // also ori
`define ALU_XOR   4'b0101
`define ALU_NOR   4'b0110
`define ALU_SLT   4'b0111     // also slti
`define ALU_SLTU  4'b1000
`define ALU_ADDU  4'b1001
`define ALU_SUBU  4'b1010
`define ALU_SLL   4'b1011     // also sllv
`define ALU_LUI   4'b1100
`define ALU_SRL   4'b1101     // also srlv
`define ALU_SRA   4'b1110     // also srav

module ALU (
        In_1,
        In_2,
        ALU_Op,
        Out,
        Zero_Out
    );

    input   wire signed [31 : 0] In_1; // operand 1, rs or s(shift used)
    input   wire signed [31 : 0] In_2; // operand 2, rt or immediate
    input   wire        [3 : 0]  ALU_Op;

    output  reg  signed [31 : 0] Out; // Out
    output  wire                 Zero_Out;

    reg [32:0] tmp;

    always @(*)
    begin
        case (ALU_Op)
            // 算数,immediate comes from mux
            `ALU_NOP:
            begin
                // nop
                Out <= In_1;
            end
            `ALU_ADD:
            begin
                // add , addi
                Out <= In_1 + In_2;
            end
            `ALU_SUB:
            begin
                // sub , beq
                Out <= In_1 - In_2;
            end
            `ALU_AND:
            begin
                // and , andi
                Out <= In_1 & In_2;
            end
            `ALU_OR:
            begin
                // or
                Out <= In_1 | In_2;
            end
            `ALU_XOR:
            begin
                // xor
                Out <= In_1 ^ In_2;
            end
            `ALU_NOR:
            begin
                // nor
                Out <= ~(In_1 | In_2);
            end
            // 比较
            `ALU_SLT:
            begin
                // slt lower set 1
                Out <= (In_1 < In_2) ? 32'b1 : 32'b0;
            end
            `ALU_SLTU:
            begin
                // unsigned slt, lower set 1
                Out <= ({1'b0, In_1} < {1'b0, In_2}) ? 32'b1 : 32'b0;
            end
            `ALU_ADDU:
            begin
                // addu
                tmp = {1'b0, In_1} + {1'b0, In_2};
                Out = tmp[31 : 0];
            end
            `ALU_SUBU:
            begin
                // subu
                tmp = {1'b0, In_1} - {1'b0, In_2};
                Out = tmp[31 : 0];
            end
            `ALU_SLL:
            begin
                // sll or sllv
                Out <= In_2 << {1'b0, In_1[4 : 0]} ; // from mux
            end
            `ALU_LUI:
            begin
                 // lui immediate load to highest bits, left shift 16 bits
                Out <= In_2 << 'd16;
            end
            `ALU_SRL:
            begin
                 // srl or srlv
                Out <= In_2 >> {1'b0, In_1[4 : 0]};  // from mux
            end
            `ALU_SRA: 
            begin
                // sra or srav, right shift with arthibary
                Out <= (In_2 >>> {1'b0, In_1[4 : 0]}); // from mux
            end
            default:
            begin
                Out <= In_1;
            end
        endcase
        $display("opr1 0x%8X, opr2 0x%8X, aluop 0b%4b", In_1, In_2, ALU_Op);
    end

    assign   Zero_Out = ((Out == 32'b0) ? 1'b1 : 1'b0);

endmodule

