
// testbench for simulation
module sccomp_tb();

    reg clk;
    reg rstn;
    reg [4:0] Reg_Sel;

    wire [31:0] Reg_Data;

    // instantiation of sccomp
    sccomp U_SCCOMP(
               .clk(clk),
               .rstn(rstn),
               .Reg_Sel(Reg_Sel),
               .Reg_Data(Reg_Data)
           );

    initial
    begin
        // $readmemh( "../../Testing_Code/mipstest_extloop.dat" , U_SCCOMP.U_IM.ROM); // load instructions into instruction memory
        // $readmemh( "../../Testing_Code/mipstestloop_sim.dat" , U_SCCOMP.U_IM.ROM); // load instructions into instruction memory
        // $readmemh( "../../Testing_Code/mipstestloopjal_sim.dat" , U_SCCOMP.U_IM.ROM); // load instructions into instruction memory
        $readmemh( "../../Testing_Code/extendedtest.dat" , U_SCCOMP.U_IM.ROM); // load instructions into instruction memory
        // $readmemh( "../../Testing_Code/studentnosorting_cut.dat" , U_SCCOMP.U_IM.ROM); // load instructions into instruction memory
        // $readmemh( "../../Testing_Code/my_studentnosorting_cut.dat" , U_SCCOMP.U_IM.ROM); // load instructions into instruction memory
        $monitor("\t\t\t\t\t\tPC = 0x%8X,                                 instr = 0x%8X", U_SCCOMP.PC, U_SCCOMP.instr); // used for debug
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
        $dumpfile("sccomp_tb.vcd");
        $dumpvars(0, sccomp_tb);
    end

endmodule
