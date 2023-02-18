// Testbench for MMCM
`timescale 1ns/1ps
module clk_testbench;
reg clk, reset;
wire clkout_8mhz;

clock_mmcm clock_mmcm_inst(.clk(clk), .reset(reset), .clkout_8mhz(clkout_8mhz));

initial 
begin
    clk = 0;
    reset = 1;
    #100 reset = 0;    
end

always #5 clk = ~clk;

endmodule