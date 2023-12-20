// `include "./ctrl_encode_def.v"
// 组合单元
// validated!
/*
 ALUop need to suuport
 add/sub/and/or/xor/nor   all need one spectified ALUop
 slt/sltu/addu/subu
 lui
 sll/bne/srl/sra
 
 from mux choose one data, read from regfile or instruction itself
 these cmd only need one ALUop that mentioned above
 srav
 andi
 slti
 sllv
 srlv
 
 sum 14
 4bits ALUop
 
 deposited: these cmd need to immigrant to other unit
 
 */
// ALU control signal
`define ALU_ADD   4'b0001     // also addi,lw,sw
`define ALU_SUB   4'b0010     // also beq,bne
`define ALU_AND   4'b0011     // also andi
`define ALU_OR    4'b0100     // also ori
// `define ALU_XOR   4'b0101
`define ALU_NOR   4'b0110
`define ALU_SLT   4'b0111     // also slti
`define ALU_SLTU  4'b1000
`define ALU_ADDU  4'b1001
`define ALU_SUBU  4'b1010
`define ALU_SLL   4'b1011     // also sllv
`define ALU_LUI   4'b1100
`define ALU_SRL   4'b1101     // also srlv
// `define ALU_SRA// also srav
`define ALU_NOP   4'b0000

module ALU (
        A,
        B,
        ALUop,
        C,
        Zero
    );

    input wire signed [31:0] A; // operand 1, rs or s(shift used)
    input wire signed [31:0] B; // operand 2, rt or immediate
    input wire [3:0] ALUop;
    output reg signed [31:0] C; //C
    output wire Zero;

    reg [32:0] tmp;

    always @(*)
    begin
        case (ALUop)
            /* 算数,immediate comes from mux*/
            `ALU_NOP:
                C <= A;                                  // nop
            `ALU_ADD:
                C <= A + B;                              // add , addi
            `ALU_SUB:
                C <= A - B;                              // sub , beq
            `ALU_AND:
                C <= A & B;                              // and , andi
            `ALU_OR:
                C <= A | B;                              // or
            // `ALU_XOR: C <= A ^ B;                              // xor
            `ALU_NOR:
                C <= ~(A | B);                           // nor
            /* 比较*/
            `ALU_SLT:
                C <= (A < B) ? 32'b1 : 32'b0;            // slt lower set 1
            `ALU_SLTU:
                C <= ({1'b0,A} < {1'b0,B}) ? 32'b1:32'b0;//unsigned slt, lower set 1
            /* unsigned add and sub*/
            `ALU_ADDU:
            begin
                /* addu*/
                tmp = {1'b0,A} + {1'b0,B};
                C   = tmp[31:0];
            end
            `ALU_SUBU:
            begin
                /* subu*/
                tmp = {1'b0,A} - {1'b0,B};
                C   = tmp[31:0];
            end
            // shift sll/srl/sra
            `ALU_SLL:
            begin
                /* sll or sllv*/
                C <= B << {1'b0,A[4:0]} ;// from mux
            end
            // lui immediate load to highest bits, left shift 16 bits
            `ALU_LUI:
            begin
                C <= B << 'd16;
            end
            // srl or srlv
            `ALU_SRL :
            begin
                C <= B >> {1'b0,A[4:0]};  // from mux
            end
            // // sra,right shift with arthibary
            // 4'b1101 : begin
            //     C <= B >>> {1'b0,A[4:0]} ;// from mux
            // end
            default:
            begin
                C <= A;
            end
        endcase
        $display("opr1 0x%8X, opr2 0x%8X, aluop 0b%4b", A, B,ALUop);
    end
    assign   Zero = ((C == 32'b0) ? 1'b1 : 1'b0);


endmodule

