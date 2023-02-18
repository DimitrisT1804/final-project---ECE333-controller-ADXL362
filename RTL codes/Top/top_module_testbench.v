// Testbench for top module
`timescale 1ns/100ps
module testbench_top_module;
reg clk, reset, MISO;
wire MOSI, SCLK, CS;

top_final_lab top_final_lab_inst(clk, reset, MISO, MOSI, SCLK, CS);

initial 
begin
    clk = 0;
    reset = 1;
    #10 MISO = 0;
    #4000 reset = 1;
    #10 reset = 0;

    #1228380 MISO = 1;  // -78 
    #175 MISO = 0;
    #200 MISO = 1;
    #200 MISO = 1;
    #200 MISO = 0;
    #200 MISO = 0;
    #200 MISO = 1;
    #200 MISO = 0;

    // #3640 MISO = 1;   // times gia to Y  (-113)
    // #170 MISO = 0;
    // #200 MISO = 0;
    // #200 MISO = 0;
    // #200 MISO = 1;
    // #200 MISO = 1;
    // #200 MISO = 1;
    // #200 MISO = 1;

    #5023590 MISO = 1;  // -46
    #175 MISO = 1;
    #200 MISO = 0;
    #200 MISO = 1;
    #200 MISO = 0;
    #200 MISO = 0;
    #200 MISO = 1;
    #200 MISO = 0;

    // #3640 MISO = 1;   // times gia to Y   (-23)
    // #170 MISO = 1;
    // #200 MISO = 1;
    // #200 MISO = 0;
    // #200 MISO = 1;
    // #200 MISO = 0;
    // #200 MISO = 0;
    // #200 MISO = 1;


    #5023625 MISO = 1;  // -36
    #175 MISO = 1;
    #200 MISO = 0;
    #200 MISO = 1;
    #200 MISO = 1;
    #200 MISO = 1;
    #200 MISO = 0;
    #200 MISO = 0;

    // #3640 MISO = 1;   // times gia to Y   (-87)
    // #170 MISO = 0;
    // #200 MISO = 1;
    // #200 MISO = 0;
    // #200 MISO = 1;
    // #200 MISO = 0;
    // #200 MISO = 0;
    // #200 MISO = 1;

    #5023625 MISO = 1;  // -66
    #175 MISO = 0;
    #200 MISO = 1;
    #200 MISO = 1;
    #200 MISO = 1;
    #200 MISO = 1;
    #200 MISO = 1;
    #200 MISO = 0;

    // #3640 MISO = 1;   // times gia to Y (-67)
    // #170 MISO = 0;
    // #200 MISO = 1;
    // #200 MISO = 1;
    // #200 MISO = 1;
    // #200 MISO = 1;
    // #200 MISO = 0;
    // #200 MISO = 1;



end



always #5 clk = ~clk;

endmodule