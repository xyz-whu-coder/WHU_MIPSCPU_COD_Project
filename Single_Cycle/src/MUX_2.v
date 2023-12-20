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
