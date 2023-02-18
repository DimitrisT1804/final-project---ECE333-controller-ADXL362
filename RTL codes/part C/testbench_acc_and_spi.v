// Testbench for MMCM
`timescale 1ns/1ps
module testbench_SPI;

wire is_negative_X, is_negative_Y, is_negative_Z, is_negative_T;

wire start_transmision, locked;
wire data_ready_for_printing;

reg clk, reset, MISO;
wire MOSI, SCLK, CS, TxD;

wire [7:0] instruction, addr, data;
wire data_ready;
wire signed [7:0] data_acc;

wire signed [15:0] avg_Y;

wire master_enable;

//SPI_Master SPI_Master_inst(.clk(clk), .reset(reset), .instruction(instruction), .addr(addr), .data(data), .MISO(MISO), .clkout_8mhz(clkout_8mhz), .MOSI(MOSI), .master_enable(master_enable), .spi_idle(spi_idle), .data_acc(data_acc), .CS(CS));

acc_instructions acc_instructions_inst(.clk(clk), .reset(reset), .spi_idle(spi_idle), .master_enable(master_enable), .instruction(instruction), .addr(addr), .data(data), .start_transmision(start_transmision), .locked(locked));

SPI_Master SPI_Master_inst(.clk(clk), .reset(reset), .instruction(instruction), .addr(addr), .data(data), .MISO(MISO), .clkout_8mhz(SCLK), .MOSI(MOSI), .CS(CS), .master_enable(master_enable), .spi_idle(spi_idle), .data_ready(data_ready), .data_acc(data_acc), .locked(locked));

clock_mmcm clock_mmcm_inst(.clk(clk), .reset(reset), .clkout_8mhz(SCLK), .locked(locked));    // to roloi einai sta 5 MHz telika

initial 
begin
    clk = 0;
    reset = 1;
    MISO = 0;
    #100 reset = 0;

    #1227775 MISO = 1;     // tote jekinaei na grafei to acc sto MISO 
    #177 MISO = 0;
    #200 MISO = 1;    
    #200 MISO = 1;
    #200 MISO = 0;
    #200 MISO = 0;
    #200 MISO = 1;
    #200 MISO = 0;

end

always #5 clk = ~clk;

endmodule