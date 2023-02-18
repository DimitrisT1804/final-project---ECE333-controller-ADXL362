//testbench Transmitter
`timescale 1ns/1ps
module testbench;
reg clk, reset;
wire sample_ENABLE;
reg [2:0] baud_select;


reg [7:0] Tx_DATA;
reg Tx_EN, Tx_WR;

wire TxD, Tx_BUSY;

realtime sig, toggle_time;

initial 
begin
    clk = 0;
    reset = 1;
    Tx_DATA = 8'b10101101;
    Tx_WR = 0;
    Tx_EN = 0;
    baud_select = 3'b010;
    #1000 reset = 0;
    #10000 Tx_EN = 1;
    #500 Tx_WR = 1;
    #16000 Tx_WR = 0;
    #2400000 Tx_DATA = 8'b10101011;
    #1000 Tx_WR = 1;
    #16000 Tx_WR = 0;
end

always @(posedge TxD)
begin
    sig = $realtime;
end
always @(negedge TxD)
begin
    toggle_time = $realtime - sig;
    $monitor("TxD was on 1 for %d ns", toggle_time);
end

uart_transmitter uart_transmitter_init (.reset(reset), .clk(clk), .Tx_DATA(Tx_DATA), .Tx_EN(Tx_EN), .TxD(TxD), .Tx_BUSY(Tx_BUSY));

always #5 clk = ~clk;
endmodule