module Data_Memory(
        clk,
        Data_Memory_Write,
        address, // 8 ~ 2 word; 1 ~ 0 byte
        Data_In,
        Memory_Byte,
        Data_Out
    );

    input clk;
    input Data_Memory_Write;
    input [8 : 0] address; // 8 ~ 2 word; 1 ~ 0 byte
    input [31 : 0] Data_In;
    input [1 : 0] Memory_Byte;

    output [31 : 0] Data_Out;

    reg [31 : 0] Data_Memory[127 : 0];
    reg [31 : 0] Temp_Dmem;

    integer idx;

    always @(posedge clk)
    begin
        if (Data_Memory_Write)
        begin
            $display("Data_In = 0x%8X, Data_Out = 0x%8X, address = 0b%9b", Data_In, Data_Out, address);
            case (Memory_Byte)
                2'b10:
                begin
                    // case (address[1 : 0])
                    // 2'b00: 
                    // begin
                    //     Data_Memory[address[8 : 2]] ={Data_Out[31 : 16], Data_In[15 : 0]};
                    // end
                    // 2'b01: 
                    // begin
                    //     Data_Memory[address[8 : 2]] = {Data_Out[31 : 16], Data_In[15 : 0]};
                    // end
                    // default: 
                    // begin
                    //     Data_Memory[address[8 : 2]] = {Data_In[15 : 0], Data_Out[15 : 0]};
                    // end
                    // endcase
                    Data_Memory[address[8 : 2]] = (address[1] == 0) ? {Data_Out[31 : 16], Data_In[15 : 0]} : {Data_In[15 : 0], Data_Out[15 : 0]};
                end
                2'b11:
                begin
                    case (address[1 : 0])
                        2'b00: 
                        begin
                            Data_Memory[address[8 : 2]] = {Data_Out[31 : 8], Data_In[7 : 0]};
                        end
                        2'b01: 
                        begin
                            Data_Memory[address[8 : 2]] = {Data_Out[31 : 16], Data_In[7 : 0], Data_Out[7 : 0]};
                        end
                        2'b10: 
                        begin
                            Data_Memory[address[8 : 2]] = {Data_Out[31 : 24], Data_In[7 : 0], Data_Out[15 : 0]};
                        end
                        default: 
                        begin
                            Data_Memory[address[8 : 2]] = {Data_In[7 : 0], Data_Out[23 : 0]};
                        end
                    endcase
                end
                default:
                begin
                    Data_Memory[address[8 : 2]] = Data_In;
                end
            endcase

            Temp_Dmem = Data_Memory[address[8 : 2]];
            $display("Memory_Byte = %2b", Memory_Byte[1 : 0]);
            
            for (idx = 0; idx < 66; idx = idx + 1)
            begin
                $display("\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\tData_Memory[0x%8X] = 0x%8X", idx << 2, Data_Memory[idx]);
            end
        end
    end

    assign Data_Out = Data_Memory[address[8 : 2]];

endmodule
