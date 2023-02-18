// Testbench for MMCM
`timescale 1ns/100ps
module testbench_double_dabble;
reg clk, reset, convert_bcd;
reg [15:0] value;

wire [3:0] digit_0, digit_1, digit_2, digit_3, digit_4, digit_5;

//SPI_Master SPI_Master_inst(.clk(clk), .reset(reset), .instruction(instruction), .addr(addr), .data(data), .MISO(MISO), .clkout_8mhz(clkout_8mhz), .MOSI(MOSI), .cs_new(cs_new), .master_enable(master_enable));
bin2bcd bin2bcd_init(.clk(clk), .reset(reset), .value(value), .convert_bcd(convert_bcd), .digit_0(digit_0), .digit_1(digit_1), .digit_2(digit_2), .digit_3(digit_3), .digit_4(digit_4), .digit_5(digit_5));

initial 
begin
    clk = 0;
    reset = 1;
    value = 16'd255;
    convert_bcd = 0;
    #100 reset = 0;
    //#10 value = ~value;
    #1000 convert_bcd = 1;
    #100 convert_bcd = 0;
    #1000 convert_bcd = 1;
    value = 15'd4578;
    #100 convert_bcd = 0;
end

always #5 clk = ~clk;

endmodule