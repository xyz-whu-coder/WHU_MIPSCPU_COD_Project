module Control_Unit(
        clk,
        rst,
        Zero,
        opcode,
        funct,
        Reg_Write,
        Mem_Write,
        PC_Write,
        IR_Write,
        EXT_Op,
        EXT_5_Src,
        ALU_Op,
        PC_Source,
        ALU_Src_A,
        ALU_Src_B,
        GPR_Sel,
        Write_Data_Sel,
        Instr_Data_Mem
    );

    input clk;
    input rst;
    input Zero;
    input  [5 : 0] opcode; // opcode
    input  [5 : 0] funct;  // funct

    output reg         Reg_Write;      // control signal for register write
    output reg         Mem_Write;      // control signal for memory write
    output reg         PC_Write;       // control signal for PC write
    output reg         IR_Write;       // control signal for IR write
    output reg         EXT_Op;         // control signal to signed extension
    output reg         EXT_5_Src;      // source of zero extended 5bits, 0 - shamt, 1- reg A(rs[4 : 0])
    output reg [1 : 0] ALU_Src_A;      // ALU source for A, 0 - PC, 1 - ReadData1, 2 - zero extended 5bits
    output reg [1 : 0] ALU_Src_B;      // ALU source for B, 0 - ReadData2, 1 - 4, 2 - extended immediate, 3 - branch offset
    output reg [3 : 0] ALU_Op;         // ALU opertion
    output reg [1 : 0] PC_Source;      // PC source, 0- ALU, 1-ALUOut, 2-JUMP address, 3-RD1(才读出的)
    output reg [1 : 0] GPR_Sel;        // general purpose register selection
    output reg [1 : 0] Write_Data_Sel; // (register) write data selection
    output reg         Instr_Data_Mem; // 0-memory access for instruction, 1 - memory access for data

    parameter  [2 : 0] State_IF  = 3'b000; // IF  state
    parameter  [2 : 0] State_ID  = 3'b001; // ID  state
    parameter  [2 : 0] State_EXE = 3'b010; // EXE state
    parameter  [2 : 0] State_MEM = 3'b011; // MEM state
    parameter  [2 : 0] State_WB  = 3'b100; // WB  state

    // r format
    wire rtype  = ~| opcode;
    wire i_add  = rtype & (funct == 6'b100000);
    wire i_addu = rtype & (funct == 6'b100001);
    wire i_sub  = rtype & (funct == 6'b100010);
    wire i_subu = rtype & (funct == 6'b100011);
    wire i_and  = rtype & (funct == 6'b100100);
    wire i_or   = rtype & (funct == 6'b100101);
    wire i_xor  = rtype & (funct == 6'b100110);
    wire i_nor  = rtype & (funct == 6'b100111);
    wire i_slt  = rtype & (funct == 6'b101010);
    wire i_sltu = rtype & (funct == 6'b101011);
    wire i_srl  = rtype & (funct == 6'b000010);
    wire i_sra  = rtype & (funct == 6'b000011);
    wire i_srav = rtype & (funct == 6'b000111);
    wire i_sllv = rtype & (funct == 6'b000100);
    wire i_srlv = rtype & (funct == 6'b000110);
    wire i_jr   = rtype & (funct == 6'b001000);
    wire i_jalr = rtype & (funct == 6'b001001);
    wire i_sll  = rtype & (funct == 6'b000000);
    
    // i format
    wire i_addi = (opcode == 6'b001000);
    wire i_ori  = (opcode == 6'b001101);
    wire i_xori = (opcode == 6'b001110);
    wire i_lw   = (opcode == 6'b100011);
    wire i_sw   = (opcode == 6'b101011);
    wire i_beq  = (opcode == 6'b000100);
    wire i_lui  = (opcode == 6'b001111);
    wire i_slti = (opcode == 6'b001010);
    wire i_bne  = (opcode == 6'b000101);
    wire i_andi = (opcode == 6'b001100);

    // j format
    wire i_j    = (opcode == 6'b000010);
    wire i_jal  = (opcode == 6'b000011);

    /*************************************************/
    /******               FSM                   ******/
    reg [2 : 0] nextstate;
    reg [2 : 0] state;

    always @(posedge clk or posedge rst)
    begin
        if (rst)
        begin
            state <= State_IF;
        end
        else
        begin
            state <= nextstate;
        end
    end // end always

    /*************************************************/
    /******         Control Signal              ******/
    always @(*)
    begin
        Reg_Write = 0;
        Mem_Write = 0;
        PC_Write  = 0;
        IR_Write  = 0;
        EXT_Op    = 1;          // signed extension
        EXT_5_Src = 0;
        ALU_Src_A = 2'b01;      // 1 - ReadData1
        ALU_Src_B = 2'b00;      // 0 - ReadData2
        ALU_Op    = 4'b0001;    // ALU_ADD   4'b0001
        GPR_Sel   = 2'b00;      // GPRSel_RD 2'b00
        Write_Data_Sel = 2'b00; // WDSel_FromALU 2'b00
        PC_Source      = 2'b00; // PC + 4 (ALU)
        Instr_Data_Mem = 0;     // 0-memory access for instruction

        case (state)
            State_IF:
            begin
                PC_Write = 1;
                IR_Write = 1;
                ALU_Src_A = 2'b00;  // PC
                ALU_Src_B = 2'b01;  // 4
                nextstate = State_ID;
            end
            State_ID:
            begin
                if (i_j)
                begin
                    PC_Source = 2'b10; // JUMP address
                    PC_Write = 1;
                    nextstate = State_IF;
                end
                else if (i_jal)
                begin
                    PC_Source = 2'b10; // JUMP address
                    PC_Write = 1;
                    Reg_Write = 1;
                    Write_Data_Sel = 2'b10; // WDSel_FromPC  2'b10
                    GPR_Sel = 2'b10;        // GPRSel_31     2'b10
                    nextstate = State_IF;
                end
                else if (i_jr)
                begin
                    PC_Source = 2'b11; // just read RD1 as address
                    PC_Write = 1;
                    nextstate = State_IF;
                end
                else if (i_jalr)
                begin
                    PC_Source = 2'b11; // just read RD1 as address
                    PC_Write = 1;
                    Reg_Write = 1;
                    Write_Data_Sel = 2'b10; // WDSel_FromPC  2'b10
                    GPR_Sel = 2'b10;        // GPRSel_31     2'b10
                    nextstate = State_IF;
                end
                else
                begin
                    // 暂时计算并存储至aluout
                    ALU_Src_A = 0;       // PC
                    ALU_Src_B = 2'b11;   // branch offset
                    nextstate = State_EXE;
                end
            end
            State_EXE:
            begin
                ALU_Op[0] = i_add  | i_addi | i_lw   | i_sw  | i_and  | i_andi | i_slt | i_slti | i_addu | i_sll  | i_sllv | i_srl  | i_srlv | i_xor | i_xori;
                ALU_Op[1] = i_sub  | i_beq  | i_bne  | i_and | i_andi | i_nor  | i_slt | i_slti | i_subu | i_sll  | i_sllv | i_sra  | i_srav;
                ALU_Op[2] = i_or   | i_ori  | i_nor  | i_slt | i_slti | i_lui  | i_srl | i_srlv | i_xor  | i_xori | i_sra  | i_srav;
                ALU_Op[3] = i_sltu | i_addu | i_subu | i_sll | i_sllv | i_lui  | i_srl | i_srlv | i_sra  | i_srav;
                if (i_beq)
                begin
                    PC_Source = 2'b01; // ALUout, branch address
                    PC_Write = i_beq  & Zero;
                    nextstate = State_IF;
                end
                else if (i_bne)
                begin
                    PC_Source = 2'b01; // ALUout, branch address
                    PC_Write = i_bne  & (~Zero);
                    nextstate = State_IF;
                end
                else if (i_lw || i_sw)
                begin
                    ALU_Src_B = 2'b10; // select offset
                    nextstate = State_MEM;
                end
                else
                begin
                    if (i_addi || i_ori || i_slti || i_andi || i_lui)
                    begin
                        ALU_Src_B = 2'b10; // select immediate
                    end
                    if (i_ori || i_andi)
                    begin
                        EXT_Op = 0; // zero extension
                    end
                    if (i_sll || i_srl || i_sllv || i_srlv || i_sra)
                    begin
                        ALU_Src_A = 2'b10;
                    end
                    if (i_sllv || i_srlv)
                    begin
                        EXT_5_Src = 1;
                    end
                    nextstate = State_WB;
                end
            end
            State_MEM:
            begin
                Instr_Data_Mem = 1; // memory address  = ALUout
                if (i_lw)
                begin
                    nextstate = State_WB;
                end
                else
                begin  
                    // i_sw
                    Mem_Write = 1;
                    nextstate = State_IF;
                end
            end
            State_WB:
            begin
                if (i_lw)
                begin
                    Write_Data_Sel = 2'b01; // WDSel_From_MEM 2'b01
                end
                if (i_lw | i_addi | i_ori | i_andi | i_lui | i_slti)
                begin
                    GPR_Sel = 2'b01; // GPRSel_RT     2'b01
                end
                Reg_Write = 1;
                nextstate = State_IF;
            end
            default:
            begin
                nextstate = State_IF;
            end
        endcase
    end // end always

endmodule
