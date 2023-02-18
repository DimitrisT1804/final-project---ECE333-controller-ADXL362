// Top module for final lab

module top_final_lab(clk, reset, MISO, MOSI, SCLK, CS, TxD);

input clk, reset, MISO;
output MOSI, SCLK, CS, TxD;

wire master_enable, spi_idle;
wire [7:0] instruction, addr, data;
wire data_ready;
wire signed [7:0] data_acc;

wire signed [15:0] avg_Y;

wire [7:0] ascii_X1, ascii_X2, ascii_X3, ascii_X4;
wire [7:0] ascii_Y1, ascii_Y2, ascii_Y3, ascii_Y4;
wire [7:0] ascii_Z1, ascii_Z2, ascii_Z3, ascii_Z4;
wire [7:0] ascii_T0, ascii_T1, ascii_T2, ascii_T3, ascii_T4, ascii_T5, ascii_T6;

wire is_negative_X, is_negative_Y, is_negative_Z, is_negative_T;

wire start_transmision, locked;
wire data_ready_for_printing;


acc_instructions acc_instructions_inst(.clk(clk), .reset(reset), .spi_idle(spi_idle), .master_enable(master_enable), .instruction(instruction), .addr(addr), .data(data), .start_transmision(start_transmision), .locked(locked));

SPI_Master SPI_Master_inst(.clk(clk), .reset(reset), .instruction(instruction), .addr(addr), .data(data), .MISO(MISO), .clkout_5_mhz(SCLK), .MOSI(MOSI), .CS(CS), .master_enable(master_enable), .spi_idle(spi_idle), .data_ready(data_ready), .data_acc(data_acc), .locked(locked));

clock_mmcm clock_mmcm_inst(.clk(clk), .reset(reset), .clkout_5_mhz(SCLK), .locked(locked));    // to roloi einai sta 5 MHz telika

data_sort data_sort_inst (.clk(clk), .reset(reset), .addr_reg(addr), .data_ready(data_ready), .data_acc(data_acc), .avg_Y(avg_Y), .data_ready_for_printing(data_ready_for_printing),
.ascii_X1(ascii_X1), .ascii_X2(ascii_X2), .ascii_X3(ascii_X3), .ascii_X4(ascii_X4),
.ascii_Y1(ascii_Y1), .ascii_Y2(ascii_Y2), .ascii_Y3(ascii_Y3), .ascii_Y4(ascii_Y4),
.ascii_Z1(ascii_Z1), .ascii_Z2(ascii_Z2), .ascii_Z3(ascii_Z3), .ascii_Z4(ascii_Z4),
.ascii_T1(ascii_T1), .ascii_T2(ascii_T2), .ascii_T3(ascii_T3), .ascii_T4(ascii_T4), .ascii_T0(ascii_T0), .ascii_T5(ascii_T5), .ascii_T6(ascii_T6),
.is_negative_X(is_negative_X), .is_negative_Y(is_negative_Y), .is_negative_Z(is_negative_Z), .is_negative_T(is_negative_T)
);

UART_Controller_2 UART_Controller_2_inst(.clk(clk), .reset(reset), .TxD(TxD), .start_transmision(start_transmision), .data_ready_for_printing(data_ready_for_printing),
.ascii_X1(ascii_X1), .ascii_X2(ascii_X2), .ascii_X3(ascii_X3), .ascii_X4(ascii_X4),
.ascii_Y1(ascii_Y1), .ascii_Y2(ascii_Y2), .ascii_Y3(ascii_Y3), .ascii_Y4(ascii_Y4),
.ascii_Z1(ascii_Z1), .ascii_Z2(ascii_Z2), .ascii_Z3(ascii_Z3), .ascii_Z4(ascii_Z4),
.ascii_T1(ascii_T1), .ascii_T2(ascii_T2), .ascii_T3(ascii_T3), .ascii_T4(ascii_T4), .ascii_T0(ascii_T0), .ascii_T5(ascii_T5), .ascii_T6(ascii_T6),
.is_negative_X(is_negative_X), .is_negative_Y(is_negative_Y), .is_negative_Z(is_negative_Z), .is_negative_T(is_negative_T)
);

endmodule
