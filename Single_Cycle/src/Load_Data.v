// 从读取的数据中，根据lh, lw, lbu来确定mem的结果
module Load_Data (
        Memory_Byte,
        address,
        sign,
        Data_In,
        Data_Out
    );

    input [1 : 0] Memory_Byte;
    input [1 : 0] address;
    input sign;
    input [31 : 0] Data_In;

    output wire [31 : 0] Data_Out;

    reg [31 : 0] result;

    always @(*)
    begin
        if (sign == 1'b1)
        begin
            case (Memory_Byte)
                2'b10:
                begin
                    // lh
                    if (address[1] == 0)
                    begin
                        result <= {{16{Data_In[15]}}, Data_In[15 : 0]};
                    end
                    else
                    begin
                        result <= {{16{Data_In[31]}}, Data_In[31 : 16]};
                    end
                end
                2'b11:
                begin
                    // lb
                    case (address)
                        2'b00:
                        begin
                            result <= {{24{Data_In[7]}}, Data_In[7 : 0]};
                        end
                        2'b01:
                        begin
                            result <= {{24{Data_In[15]}}, Data_In[15 : 8]};
                        end
                        2'b10:
                        begin
                            result <= {{24{Data_In[23]}}, Data_In[23 : 16]};
                        end
                        default:
                        begin
                            result <= {{24{Data_In[31]}}, Data_In[31 : 24]};
                        end
                    endcase
                end
                default:
                begin
                    // lw
                    result <= Data_In ;
                end
            endcase
        end
        else
        begin
            case (Memory_Byte)
                2'b10:
                begin
                    // lhu
                    if (address[1] == 0)
                    begin
                        result <= {{16'b0}, Data_In[15 : 0]};
                    end
                    else
                    begin
                        result <= {{16'b0}, Data_In[31 : 16]};
                    end
                end
                2'b11:
                begin
                    // lbu
                    case (address)
                        2'b00:
                        begin
                            result <= {24'b0, Data_In[7 : 0]};
                        end
                        2'b01:
                        begin
                            result <= {24'b0, Data_In[15 : 8]};
                        end
                        2'b10:
                        begin
                            result <= {24'b0, Data_In[23 : 16]};
                        end
                        default:
                        begin
                            result <= {24'b0, Data_In[31 : 24]};
                        end
                    endcase
                end
                default:
                begin
                    // lw
                    result <= Data_In ;
                end
            endcase
        end
    end

    assign Data_Out = result;

endmodule
