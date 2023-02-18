// Testbench for MMCM
`timescale 1ns/100ps
module testbench_UART_Controller;
reg clk, reset;
wire TxD;
reg [14:0] value_X;

UART_Controller_2 UART_Controller_2_inst(.clk(clk), .reset(reset), .TxD(TxD), .value_X(value_X));

initial 
begin
    clk = 0;
    reset = 1;
    value_X = 15'b0;
    #100 reset = 0;
    #640000000 value_X = 15'd102;
    #640000000 value_X = 15'd70;
end

always #5 clk = ~clk;

endmodule