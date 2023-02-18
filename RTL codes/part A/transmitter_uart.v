// Transmitter UART
module uart_transmitter(reset, clk, TxD, Tx_DATA, Tx_BUSY, Tx_EN);

parameter off = 4'b0000, 
        idle = 4'b0001,
        transfer = 4'b0010,
        start_bit = 4'b0011,
        data0 = 4'b0100,
        data1 = 4'b0101,
        data2 = 4'b0110,
        data3 = 4'b0111,
        data4 = 4'b1000,
        data5 = 4'b1001,
        data6 = 4'b1010,
        data7 = 4'b1011,
        parity_bit = 4'b1100,
        stop_bit = 4'b1101;


input reset, clk;
input [7:0] Tx_DATA;
//input [7:0] Tx_DATA;
//input [2:0] baud_select;
//input Tx_EN;
//input Tx_WR;
//reg[7:0] Tx_DATA = 8'b01011101;
input Tx_EN;
reg Tx_WR = 1;
output reg Tx_BUSY;

output reg TxD;
//output reg Tx_BUSY;

reg [2:0] baud_select = 3'b110;

wire sample_ENABLE;
reg [3:0]counter;

reg send;  // sima gia na steilei o transmitter

reg [3:0] current_state, next_state;

reg load;   // gia ton shifter register
wire so;    // serial output

reg Q1, Q2;
wire Q2_bar;
wire send_out;

// metavlites gia ton counter pou metraei bytes
//reg [4:0] counter_bytes;
reg counter_bytes_enable;


always @(posedge clk or posedge reset)
begin
    if(reset)
        counter <= 0;
    else
    begin
        if(sample_ENABLE == 1)
            counter <= counter + 4'b1;
    end
end

// always @(posedge clk or posedge reset)
// begin
//     if(reset)
//         send <= 0;
//     else if(enable == 1)
//     begin
//         if(sample_ENABLE == 1)
//         begin
//             if(counter == 4'b1111)
//             begin
//                 send <= send + 4'b0001;
//             end
//         end
//     end
// end

always @(counter)       // stelnei sima send meta apo xrono 16*baud_rate
begin
    if(counter == 4'b1111)
        send = 1;
    else
        send = 0;
end

always @(posedge clk)       // kati san antibounce gia na kratiso ton palmo gia ena kiklo rologioy
begin
    Q1 <= send;
end

always @(posedge clk)
begin
    Q2 <= Q1;
end

assign Q2_bar = ~Q2;
assign send_out = (Q2_bar & Q1);

always @(posedge clk or posedge reset)      // FSM change states
begin
    if(reset)
        current_state <= off;
    else
        current_state <= next_state;
end

always @(Tx_WR or send_out or current_state or Tx_DATA or Tx_EN)     //FSM combinational block
begin
    next_state = current_state;
    TxD = 1'b1;
    Tx_BUSY = 0;
    counter_bytes_enable = 0;

    case (current_state)
        off:
        begin
            TxD = 1;
            if(Tx_EN == 1)
                next_state = idle;
            else
                next_state = off;
        end

        idle: 
        begin
            TxD = 1'b1;
            Tx_BUSY = 0;
            //counter_bytes_enable = 1;
            if(Tx_EN == 0)
                next_state = off;
            else if(Tx_WR == 1)
                next_state = transfer;
            else
                next_state = idle;
        end

        transfer:
        begin
            TxD = 1'b1;
            Tx_BUSY = 1;
            //counter_bytes_enable = 1;
            if(send_out == 1)
            begin
                next_state = start_bit;
            end
            else
                next_state = transfer;
        end

        start_bit: 
        begin
            TxD = 0;
            Tx_BUSY = 1;
            if(send_out == 1)
            begin
                next_state = data0;
            end
            else
                next_state = start_bit;
        end

        data0:
        begin
            TxD = Tx_DATA[0];
            Tx_BUSY = 1;
            if (send_out == 1)
                next_state = data1;
            else
                next_state = data0;
        end

        data1:
        begin
            TxD = Tx_DATA[1];
            Tx_BUSY = 1;
            if (send_out == 1)
                next_state = data2;
            else
                next_state = data1;
        end

        data2:
        begin
            TxD = Tx_DATA[2];
            Tx_BUSY = 1;
            if (send_out == 1)
                next_state = data3;
            else
                next_state = data2;
        end

        data3:
        begin
            TxD = Tx_DATA[3];
            Tx_BUSY = 1;
            if (send_out == 1)
                next_state = data4;
            else
                next_state = data3;
        end

        data4:
        begin
            TxD = Tx_DATA[4];
            Tx_BUSY = 1;
            if (send_out == 1)
                next_state = data5;
            else
                next_state = data4;
        end

        data5:
        begin
            TxD = Tx_DATA[5];
            Tx_BUSY = 1;
            if (send_out == 1)
                next_state = data6;
            else
                next_state = data5;
        end

        data6:
        begin
            TxD = Tx_DATA[6];
            Tx_BUSY = 1;
            if (send_out == 1)
                next_state = data7;
            else
                next_state = data6;
        end

        data7:
        begin
            TxD = Tx_DATA[7];
            Tx_BUSY = 1;
            if (send_out == 1)
                next_state = parity_bit;
            else
                next_state = data7;
        end

        parity_bit:
        begin
            TxD = ^Tx_DATA;
            Tx_BUSY = 1;
            if(send_out == 1)
                next_state = stop_bit;
            else
                next_state = parity_bit;
        end

        stop_bit:
        begin
            TxD = 1;
            Tx_BUSY = 1;
            counter_bytes_enable = 1;
            if(send_out == 1)
                next_state = idle;   // kanonika idle
            else
                next_state = stop_bit;
        end
        default:
        begin
            next_state = off;
        end
    endcase
end

// /* Counter pou metraei se poio byte tou transmission vriskomaste */
// always @(posedge clk or posedge reset)
// begin
//     if(reset)
//         counter_bytes <= 0;
//     else    
//     begin 
//         if(counter_bytes == 4'd2)   // gia na midenizei
//             counter_bytes <= 0;
//         else if (counter_bytes_enable)
//             counter_bytes <= counter_bytes + 4'b1;
//     end
// end

/* Baud controller instantiation */
Baud_controller Baud_controller_tx_inst(.reset(reset), .clk(clk), .baud_select(baud_select), .sample_ENABLE(sample_ENABLE));

endmodule