// testbench for simulation
module mccomp_tb();

    reg  clk;
    reg  rstn;
    reg  [4 : 0]  Reg_Sel;
    wire [31 : 0] Reg_Data;

    // instantiation of sccomp
    mccomp U_MCCOMP(
               .clk(clk),
               .rstn(rstn),
               .Reg_Sel(Reg_Sel),
               .Reg_Data(Reg_Data)
           );

    initial
    begin 
        // $readmemh( "../../Testing_Code/studentnosorting_cut.dat" , U_MCCOMP.U_DM.Data_Memory); // load instructions into data memory
        $readmemh( "../../Testing_Code/my_studentnosorting_cut.dat" , U_MCCOMP.U_DM.Data_Memory); // load instructions into data memory
        $monitor("\nPC = 0x%8X, instr = 0x%8X\n", U_MCCOMP.PC, U_MCCOMP.instruction); // used for debug
        clk = 1;
        rstn = 1;
        #5 ;
        rstn = 0;
        #20 ;
        rstn = 1;
        #1000 ;
        Reg_Sel = 7;
    end

    always
    begin
        #(50) clk = ~clk;
    end //end always

    initial
    begin
        $dumpfile("mccomp_tb.vcd");
        $dumpvars(0, mccomp_tb);
    end

endmodule

