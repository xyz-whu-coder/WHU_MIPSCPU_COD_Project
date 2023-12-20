
// testbench for simulation
module mccomp_tb();

    reg  clk, rstn;
    reg  [4:0] reg_sel;
    wire [31:0] reg_data;

    // instantiation of sccomp
    mccomp U_MCCOMP(
               .clk(clk), 
               .rstn(rstn), 
               .reg_sel(reg_sel), 
               .reg_data(reg_data)
           );

    initial
    begin
        // $readmemh( "../../Testing_Code/mipstest_extloop.dat" , U_MCCOMP.U_DM.dmem); // load instructions into instruction memory
        // $readmemh( "../../Testing_Code/mipstestloop_sim.dat" , U_MCCOMP.U_DM.dmem); // load instructions into instruction memory
        // $readmemh( "../../Testing_Code/mipstestloopjal_sim.dat" , U_MCCOMP.U_DM.dmem); // load instructions into instruction memory
        // $readmemh( "../../Testing_Code/extendedtest.dat" , U_MCCOMP.U_DM.dmem); // load instructions into instruction memory
        $readmemh( "../../Testing_Code/studentnosorting_cut.dat" , U_MCCOMP.U_DM.dmem); // load instructions into instruction memory
        // $readmemh( "../../Testing_Code/my_studentnosorting_cut.dat" , U_MCCOMP.U_DM.dmem); // load instructions into instruction memory
        $monitor("\t\t\t\t\t\tPC = 0x%8X,                                 instr = 0x%8X", U_MCCOMP.PC, U_MCCOMP.instr); // used for debug
        clk = 1;
        rstn = 1;
        #5 ;
        rstn = 0;
        #20 ;
        rstn = 1;
        #1000 ;
        reg_sel = 7;
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
