// Controller for Transmitter version 2
module UART_Controller_2(clk, reset, TxD, start_transmision, data_ready_for_printing, ascii_X1, ascii_X2, ascii_X3, ascii_X4,
ascii_Y1, ascii_Y2, ascii_Y3, ascii_Y4,
ascii_Z1, ascii_Z2, ascii_Z3, ascii_Z4,
ascii_T1, ascii_T2, ascii_T3, ascii_T4, ascii_T0, ascii_T5, ascii_T6,
is_negative_X, is_negative_Y, is_negative_Z, is_negative_T
);

input clk, reset, start_transmision, data_ready_for_printing;

input [7:0] ascii_X1, ascii_X2, ascii_X3, ascii_X4;
input [7:0] ascii_Y1, ascii_Y2, ascii_Y3, ascii_Y4;
input [7:0] ascii_Z1, ascii_Z2, ascii_Z3, ascii_Z4;
input [7:0] ascii_T0, ascii_T1, ascii_T2, ascii_T3, ascii_T4, ascii_T5, ascii_T6;

input is_negative_X, is_negative_Y, is_negative_Z, is_negative_T;   // gia na jeroume an einai negative

output TxD;
parameter ADDR_VALUE = 6'd52;

reg [7:0] Tx_DATA;
reg Tx_EN;

reg [5:0] addr;
reg addr_enable;

reg [3:0] current_state, next_state;
wire Tx_BUSY;

reg [3:0] counter_next_transmision;
reg counter_next_transmision_enable;

reg [7:0] message[ADDR_VALUE:0];
reg load;

// counter gia to baud rate oste na stelnei ta simvola x: ...
always @(posedge clk or posedge reset)
begin
    if(reset)
        addr <= 6'b0;
    else
    begin
        if(addr == ADDR_VALUE + 1)
            addr <= 6'b0;
        else if(addr_enable)
            addr <= addr + 6'b1;
    end
end

always @(posedge clk or posedge reset)
begin
    if(reset)
    begin
        message[0] <= 8'd27;       // ESC
        message[1] <= 8'b01011011;   // [
        message[2] <= 8'b00110010;    // 2
        message[3] <= 8'b01001010;    // J

        message[4] <= 8'd27;         // ESC
        message[5] <= 8'b01011011;   // [
        message[6] <= 8'b01001000;  // H

        message[7] <= 8'b00001010;   //new line      111010
        message[8] <= 8'd13;   //arxi grammis
        message[9] <= 8'b01111000;   // x state
        message[10] <= 8'b00111010;   // : state
        message[11] <= 8'b00100000;   // - state
        message[12] <= 8'b00000000;   // x value 1
        message[13] <= 8'b00101110;    // . 
        message[14] <= 8'b00000000;   // x value 2
        message[15] <= 8'b00000000;   // x value 3
        message[16] <= 8'b00000000;   // x value 4
        message[17] <= 8'b01100111;    // g
        message[18] <= 8'b00001010;   // new line
        message[19] <= 8'd13;   // arxi grammis
        message[20] <= 8'b01011001;  //Y state
        message[21] <= 8'b00111010;   // : state  
        message[22] <= 8'b00100000;   // - state
        message[23] <= 8'b00000000;   // y value 1
        message[24] <= 8'b00101110;    // . 
        message[25] <= 8'b00000000;   // y value 2
        message[26] <= 8'b00000000;   // y value 3
        message[27] <= 8'b00000000;   // y value 4
        message[28] <= 8'b01100111;    // g
        message[29] <= 8'b00001010;   //new line
        message[30] <= 8'd13;   //arxi grammis
        message[31] <= 8'b01011010;  //Z state
        message[32] <= 8'b00111010;   // : state
        message[33] <= 8'b00100000;   // - state  
        message[34] <= 8'b00000000;   // Z value 1
        message[35] <= 8'b00101110;   // . 
        message[36] <= 8'b00000000;   // Z value 2
        message[37] <= 8'b00000000;   // Z value 3
        message[38] <= 8'b00000000;   // Z value 4
        message[39] <= 8'b01100111;    // g
        message[40] <= 8'b00001010;   //new line
        message[41] <= 8'd13;   //arxi grammis
        message[42] <= 8'b01010100;  //T state
        message[43] <= 8'b00111010;   // : state
        message[44] <= 8'b00100000;   // - state
        message[45] <= 8'b00000000;   // T value 1
        message[46] <= 8'b00000000;   // T value 2
        message[47] <= 8'b00000000;   // T value 3
        message[48] <= 8'b00101110;   // . 
        message[49] <= 8'b00000000;   // T value 4
        message[50] <= 8'b00000000;   // T value 5
        message[51] <= 8'b00000000;   // T value 6
        message[52] <= 8'b01000011;   // C (celsius)


    end

    else
    begin
        if(load)
        begin
            message[12] <= ascii_X1;
            message[14] <= ascii_X2;
            message[15] <= ascii_X3;
            message[16] <= ascii_X4;

            message[23] <= ascii_Y1;
            message[25] <= ascii_Y2;
            message[26] <= ascii_Y3;
            message[27] <= ascii_Y4;

            message[34] <= ascii_Z1;
            message[36] <= ascii_Z2;
            message[37] <= ascii_Z3;
            message[38] <= ascii_Z4;

            message[45] <= ascii_T1;
            message[46] <= ascii_T2;
            message[47] <= ascii_T3;
            message[49] <= ascii_T4;
            message[50] <= ascii_T5;
            message[51] <= ascii_T6;

            if(is_negative_X)
                message[11] <= 8'b00101101;      // (-) gia otan einai arnitiki timi
            else
                message[11] <= 8'b00100000;      // (space)

            if(is_negative_Y)
                message[22] <= 8'b00101101;
            else
                message[22] <= 8'b00100000;

            if(is_negative_Z)
                message[33] <= 8'b00101101;
            else
                message[33] <= 8'b00100000;

            if(is_negative_T)
                message[44] <= 8'b00101101;
            else
                message[44] <= 8'b00100000;

        end
    end
end

parameter idle = 4'b0000,
            addr_add = 4'b0001,
            waiting = 4'b0010,
            next_transmision = 4'b0011,
            active_transmitter = 4'b0100,
            off = 4'b0101,
            waiting_for_loading = 4'b0111,
            loading = 4'b1000;



always @(posedge clk or posedge reset)
begin
    if(reset)
        current_state <= off;
    else
        current_state <= next_state;
end

always @(current_state or Tx_BUSY or counter_next_transmision or addr or start_transmision or data_ready_for_printing)
begin
    Tx_DATA = 8'b0;
    next_state = current_state;
    Tx_EN = 1;
    counter_next_transmision_enable = 0;
    addr_enable = 0;
    load = 0;



    case(current_state)
        off:
        begin
            if(start_transmision)
                next_state = next_transmision;
            else    
                next_state = current_state;
        end  

        idle:
        begin
            Tx_DATA = message[addr];
            if(Tx_BUSY == 0)
                next_state = addr_add;
            else
                next_state = current_state;
        end

        addr_add:
        begin
            addr_enable = 1;
            if(addr == ADDR_VALUE)
                next_state = next_transmision;
            else
                next_state = idle;
        end

        next_transmision:
        begin
            Tx_EN = 0;
            if(data_ready_for_printing)
                next_state = active_transmitter;
            else
                next_state = current_state;
        end

        active_transmitter:
        begin
            load = 1;
            Tx_EN = 1;
            counter_next_transmision_enable = 1;
            if(counter_next_transmision == 4'd5)   // 50 ns gia na pesei to TxBusy
                next_state = idle;
            else
                next_state = current_state;
        end

    endcase
end

/* Counter pou metraei xrono mexri to epomeno transmision */
always @(posedge clk or posedge reset)
begin
    if(reset)
        counter_next_transmision <= 4'b0;
    else
    begin
        if(counter_next_transmision_enable)
            counter_next_transmision <= counter_next_transmision + 4'b1;
        else    
            counter_next_transmision <= 4'b0;
    end
end



uart_transmitter uart_transmitter_inst(.reset(reset), .clk(clk), .TxD(TxD), .Tx_DATA(Tx_DATA), .Tx_BUSY(Tx_BUSY), .Tx_EN(Tx_EN));



endmodule