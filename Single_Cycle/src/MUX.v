module MUX_2 #(parameter WIDTH = 32) (
        In_1,
        In_2,
        In_Sel, 
        Out
    );

    input [WIDTH - 1 : 0] In_1;
    input [WIDTH - 1 : 0] In_2;
    input wire In_Sel; // 0 then In_1, 1 then In_2

    output wire [WIDTH - 1 : 0] Out;

    reg [WIDTH - 1 : 0] temp;

    always@(*)
    begin
        if (In_Sel == 1'b0)
        begin
            temp = In_1;
        end
        else
        begin
            temp = In_2;
        end
    end

    assign Out = temp;

    // assign Out = (In_Sel == 1'b0) ? In_1 : In_2;

endmodule

module MUX_3 #(parameter WIDTH = 32) (
        In_1, 
        In_2,
        In_3,
        In_Sel,
        Out
    );

    input [WIDTH - 1 : 0] In_1; // 00
    input [WIDTH - 1 : 0] In_2; // 01
    input [WIDTH - 1 : 0] In_3; // 10 or 11
    input [1 : 0]  In_Sel;

    output [WIDTH - 1 : 0] Out;

    reg [WIDTH - 1 : 0] temp;

    always@(*)
    begin
        case (In_Sel)
            2'b00:
            begin
                temp = In_1;
            end
            2'b01:
            begin
                temp = In_2;
            end
            default:
            begin
                // 10 or 11
                temp = In_3;
            end
        endcase
    end

    assign Out = temp;

    // assign Out = ((In_Sel[1] == 1 ? In_3: ((In_Sel[0] == 1) ? In_2 : In_1)) );

endmodule
