module ctrl(
        clk,
        rst,
        Zero,
        opcode,
        Funct,
        RegWrite,
        MemWrite,
        PCWrite,
        IRWrite,
        EXTOp,
        EXT5Src,
        ALUOp,
        PCSource,
        ALUSrcA,
        ALUSrcB,
        GPRSel,
        WDSel,
        IorD
    );

    input clk;
    input rst;
    input Zero;
    input  [5 : 0] opcode;       // opcode
    input  [5 : 0] Funct;    // funct

    output reg         RegWrite; // control signal for register write
    output reg         MemWrite; // control signal for memory write
    output reg         PCWrite;  // control signal for PC write
    output reg         IRWrite;  // control signal for IR write
    output reg         EXTOp;    // control signal to signed extension
    output reg         EXT5Src;  // source of zero extended 5bits, 0 - shamt, 1- reg A(rs[4 : 0])
    output reg [1 : 0] ALUSrcA;  // ALU source for A, 0 - PC, 1 - ReadData1, 2 - zero extended 5bits
    output reg [1 : 0] ALUSrcB;  // ALU source for B, 0 - ReadData2, 1 - 4, 2 - extended immediate, 3 - branch offset
    output reg [3 : 0] ALUOp;    // ALU opertion
    output reg [1 : 0] PCSource; // PC source, 0- ALU, 1-ALUOut, 2-JUMP address, 3-RD1(才读出的)
    output reg [1 : 0] GPRSel;   // general purpose register selection
    output reg [1 : 0] WDSel;    // (register) write data selection
    output reg         IorD;     // 0-memory access for instruction, 1 - memory access for data

    parameter  [2 : 0] state_IF  = 3'b000;                // IF  state
    parameter  [2 : 0] state_ID  = 3'b001;                // ID  state
    parameter  [2 : 0] state_EXE = 3'b010;                // EXE state
    parameter  [2 : 0] state_MEM = 3'b011;                // MEM state
    parameter  [2 : 0] state_WB  = 3'b100;                // WB  state

    // r format
    wire rtype  = ~| opcode;
    wire i_add  = rtype & (Funct == 6'b100000);
    wire i_sub  = rtype & (Funct == 6'b100010);
    wire i_and  = rtype & (Funct == 6'b100100);
    wire i_or   = rtype & (Funct == 6'b100101);
    wire i_slt  = rtype & (Funct == 6'b101010);
    wire i_sltu = rtype & (Funct == 6'b101011);
    wire i_addu = rtype & (Funct == 6'b100001);
    wire i_subu = rtype & (Funct == 6'b100011);
    wire i_srl  = rtype & (Funct == 6'b000010);
    wire i_sllv = rtype & (Funct == 6'b000100);
    wire i_srlv = rtype & (Funct == 6'b000110);
    wire i_jr   = rtype & (Funct == 6'b001000);
    wire i_jalr = rtype & (Funct == 6'b001001);
    wire i_sll  = rtype & (Funct == 6'b000000);
    wire i_nor  = rtype & (Funct == 6'b100111);

    // i format
    wire i_addi = (opcode == 6'b001000);
    wire i_ori  = (opcode == 6'b001101);
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
            state <= state_IF;
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
        RegWrite = 0;
        MemWrite = 0;
        PCWrite  = 0;
        IRWrite  = 0;
        EXTOp    = 1;           // signed extension
        EXT5Src  = 0;
        ALUSrcA  = 2'b01;       // 1 - ReadData1
        ALUSrcB  = 2'b00;       // 0 - ReadData2
        ALUOp    = 4'b0001;      // ALU_ADD       4'b0001
        GPRSel   = 2'b00;       // GPRSel_RD     2'b00
        WDSel    = 2'b00;       // WDSel_FromALU 2'b00
        PCSource = 2'b00;       // PC + 4 (ALU)
        IorD     = 0;           // 0-memory access for instruction

        case (state)
            state_IF:
            begin
                PCWrite = 1;
                IRWrite = 1;
                ALUSrcA = 2'b00;  // PC
                ALUSrcB = 2'b01;  // 4
                nextstate = state_ID;
            end
            state_ID:
            begin
                if (i_j)
                begin
                    PCSource = 2'b10; // JUMP address
                    PCWrite = 1;
                    nextstate = state_IF;
                end
                else if (i_jal)
                begin
                    PCSource = 2'b10; // JUMP address
                    PCWrite = 1;
                    RegWrite = 1;
                    WDSel = 2'b10;    // WDSel_FromPC  2'b10
                    GPRSel = 2'b10;   // GPRSel_31     2'b10
                    nextstate = state_IF;
                end
                else if (i_jr)
                begin
                    PCSource = 2'b11; // just read RD1 as address
                    PCWrite = 1;
                    nextstate = state_IF;
                end
                else if (i_jalr)
                begin
                    PCSource = 2'b11; // just read RD1 as address
                    PCWrite = 1;
                    RegWrite = 1;
                    WDSel = 2'b10;    // WDSel_FromPC  2'b10
                    GPRSel = 2'b10;   // GPRSel_31     2'b10
                    nextstate = state_IF;
                end
                else
                begin
                    // 暂时计算并存储至aluout
                    ALUSrcA = 0;       // PC
                    ALUSrcB = 2'b11;   // branch offset
                    nextstate = state_EXE;
                end
            end
            state_EXE:
            begin
                ALUOp[0] = i_add | i_addi | i_lw | i_sw | i_and | i_andi | i_slt | i_slti | i_addu | i_sll | i_sllv | i_srl | i_srlv;
                ALUOp[1] = i_sub | i_beq | i_bne | i_and | i_andi | i_nor | i_slt | i_slti | i_subu | i_sll | i_sllv;
                ALUOp[2] = i_or | i_ori | i_nor | i_slt | i_slti | i_lui | i_srl | i_srlv;
                ALUOp[3] = i_sltu | i_addu | i_subu | i_sll | i_sllv | i_lui | i_srl | i_srlv;
                if (i_beq)
                begin
                    PCSource = 2'b01; // ALUout, branch address
                    PCWrite = i_beq  & Zero;
                    nextstate = state_IF;
                end
                else if (i_bne)
                begin
                    PCSource = 2'b01; // ALUout, branch address
                    PCWrite = i_bne  & (~Zero);
                    nextstate = state_IF;
                end
                else if (i_lw || i_sw)
                begin
                    ALUSrcB = 2'b10; // select offset
                    nextstate = state_MEM;
                end
                else
                begin
                    if (i_addi || i_ori || i_slti || i_andi || i_lui)
                        ALUSrcB = 2'b10; // select immediate
                    if (i_ori || i_andi)
                        EXTOp = 0; // zero extension
                    if (i_sll || i_srl || i_sllv || i_srlv)
                        ALUSrcA = 2'b10;
                    if (i_sllv || i_srlv)
                        EXT5Src = 1;
                    nextstate = state_WB;
                end
            end
            state_MEM:
            begin
                IorD = 1;  // memory address  = ALUout
                if (i_lw)
                begin
                    nextstate = state_WB;
                end
                else
                begin  // i_sw
                    MemWrite = 1;
                    nextstate = state_IF;
                end
            end
            state_WB:
            begin
                if (i_lw)
                begin
                    WDSel = 2'b01;     // WDSel_FromMEM 2'b01
                end
                if (i_lw | i_addi | i_ori | i_andi | i_lui | i_slti)
                begin
                    GPRSel = 2'b01;    // GPRSel_RT     2'b01
                end
                RegWrite = 1;
                nextstate = state_IF;
            end
            default:
            begin
                nextstate = state_IF;
            end
        endcase
    end // end always

endmodule
