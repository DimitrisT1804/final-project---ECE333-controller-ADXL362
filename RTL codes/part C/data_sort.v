// Module that sorts accelerometer data in Registers
module data_sort(clk, reset, addr_reg, data_ready, data_acc, avg_Y, data_ready_for_printing,
ascii_X1, ascii_X2, ascii_X3, ascii_X4,
ascii_Y1, ascii_Y2, ascii_Y3, ascii_Y4,
ascii_Z1, ascii_Z2, ascii_Z3, ascii_Z4,
ascii_T1, ascii_T2, ascii_T3, ascii_T4, ascii_T0, ascii_T5, ascii_T6,
is_negative_X, is_negative_Y, is_negative_Z, is_negative_T
);

input clk, reset, data_ready;
input [7:0] addr_reg;
input signed [7:0] data_acc;       // gia na epilexei se poion reg ua paei
output [15:0] avg_Y;

output [7:0] ascii_X1, ascii_X2, ascii_X3, ascii_X4;
output [7:0] ascii_Y1, ascii_Y2, ascii_Y3, ascii_Y4;
output [7:0] ascii_Z1, ascii_Z2, ascii_Z3, ascii_Z4;
output [7:0] ascii_T0, ascii_T1, ascii_T2, ascii_T3, ascii_T4, ascii_T5, ascii_T6;

output is_negative_X, is_negative_Y, is_negative_Z, is_negative_T;

parameter ascii_value_0 = 8'b00110000;

/*Variables thar stores all data to filter */
reg signed [15:0] data_X[127:0];
reg signed [15:0] data_Y[127:0];
reg signed [15:0] data_Z[127:0];
reg [19:0] data_T[127:0];

reg [7:0] addr;
reg addr_enable, data_X_enable, data_Y_enable, data_Z_enable, data_T_enable, avg_count, match_enable;

reg signed [15:0] avg_X, avg_Y, avg_Z;
reg [19:0] avg_T;
reg signed [15:0] value_X, value_Y, value_Z;
reg [19:0] value_T; 

reg [4:0] counter;
reg counter_enable;

reg [18:0] counter_next_measurment;
reg counter_next_measurment_enable;

reg convert_bcd;
wire [3:0] digit_0X, digit_1X, digit_2X, digit_3X, digit_4X, digit_5X;
wire [3:0] digit_0Y, digit_1Y, digit_2Y, digit_3Y, digit_4Y, digit_5Y;
wire [3:0] digit_0Z, digit_1Z, digit_2Z, digit_3Z, digit_4Z, digit_5Z;
wire [3:0] digit_0T, digit_1T, digit_2T, digit_3T, digit_4T, digit_5T, digit_6T;

wire [15:0] value_X_new, value_Y_new, value_Z_new, value_T_new;

output data_ready_for_printing;
reg is_signed, data_T_LSB_enable, data_T_MSB_enable;
reg [15:0] Temp_data;

/* Variables for FSM */
reg [3:0] current_state, next_state; 


parameter idle = 4'b0000,
            choose_reg = 4'b0001,
            write_x = 4'b0010,
            write_y = 4'b0011,
            write_z = 4'b0100,
            write_t = 4'b0101,
            wait_state = 4'b0111,
            wait_for_measurment = 4'b1000,
            avg_state = 4'b1001,
            match_value = 4'b1010,
            check_sign = 4'b1011,
            write_t_LSB = 4'b0110,
            write_t_MSB = 4'b1100,
            data_t_store = 4'b1111;


/* addr for registers */
always @(posedge clk or posedge reset)
begin
    if(reset)
        addr <= 0;
    else if (addr == 8'd129)
    //else if (addr == 8'd6)
        addr <= 8'b0;
    else
    begin
        if(addr_enable)
            addr <= addr + 8'b1;
    end
end

always @(posedge clk or posedge reset)
begin
    if(reset)
        counter <= 5'b0;
    else 
    begin
        if(counter_enable)
            counter <= counter + 5'b1;
        else
            counter <= 5'b0;
    end
end

/* always block that insert values on X array 128 times */
always @(posedge clk)
begin
    if(data_X_enable)
    begin
        if(addr == 8'b0)
            data_X[addr] <= data_acc;
        else
            data_X[addr] <= data_X[addr-1] + data_acc;
    end
end

always @(posedge clk or posedge reset)
begin
    if(reset)
        avg_X <= 16'b0;
    else
    begin
        if(avg_count)
            avg_X <= (data_X[addr - 1] >>> 2);
    end
end

/* always block gia na kanei tin praji gia antistoixia timis */
always @(posedge clk or posedge reset)
begin
    if(reset)
        value_X <= 16'b0;
    else if(match_enable)
    begin                                   // antistoixia timis se mg
                                            // proekipse i sinartisi y=0.0078+0.0157*x gia limit -+2g
        value_X <= (78 + 157*avg_X);  
    end
end


//assign value_X = 0.0078 + 0.0157*avg_X;

always @(posedge clk)
begin
    if(data_Y_enable)
    begin
        if(addr == 0)
            data_Y[addr] <= data_acc;
        else
            data_Y[addr] <= data_Y[addr-1] + data_acc;
    end
end

always @(posedge clk or posedge reset)
begin
    if(reset)
        avg_Y <= 16'b0;
    else
    begin
        if(avg_count)
            avg_Y <= data_Y[addr-1] >>> 2;  // >>> gia na einai signed
    end
end

always @(posedge clk or posedge reset)
begin
    if(reset)
        value_Y <= 16'b0;
    else if(match_enable)
    begin
        //value_Y = (0.0078 + 0.0157*avg_Y) * 1000;      // antistoixia timis se mg
                                            // proekipse i sinartisi y=0.0078+0.0157*x gia limit -+2g
        value_Y <= (78 + 157*avg_Y);
    end
end

always @(posedge clk)
begin
    if(data_Z_enable)
    begin
        if(addr == 8'b0)
            data_Z[addr] <= data_acc;
        else
            data_Z[addr] <= data_Z[addr-1] + data_acc;
    end
end

always @(posedge clk or posedge reset)
begin
    if(reset)
        avg_Z <= 16'b0;
    else
    begin
        if(avg_count)
            avg_Z <= data_Z[addr-1] >>> 7;
    end
end


always @(posedge clk or posedge reset)
begin
    if(reset)
        value_Z <= 16'b0;
    else if(match_enable)
    begin
        //value_Z = (0.0078 + 0.0157*avg_Z) * 1000;      // antistoixia timis se mg
                                            // proekipse i sinartisi y=0.0078+0.0157*x gia limit -+2g
        value_Z <= (78 + 157*avg_Z);
    end
end


always @(posedge clk or posedge reset)
begin
    if(reset)
        value_Z <= 16'b0;
    else if(match_enable)
    begin
        //value_Y = (0.0078 + 0.0157*avg_Y) * 1000;      // antistoixia timis se mg
                                            // proekipse i sinartisi y=0.0078+0.0157*x gia limit -+2g
        value_Z <= (78 + 157*avg_Z);
    end
end

always @(posedge clk)
begin
    if(data_T_enable)
    begin
        if(addr == 8'b0)
            data_T[addr] <= Temp_data[10:0];        // theoro oti einai thetiko
        else
            data_T[addr] <= data_T[addr-1] + Temp_data[10:0];
    end
end

always @(posedge clk or posedge reset)
begin
    if(reset)
        avg_T <= 20'b0;
    else
    begin
        if(avg_count)
            avg_T <= data_T[addr-1] >> 7;
    end
end


always @(posedge clk or posedge reset)
begin
    if(reset)
    begin
        value_T <= 20'b0;
        convert_bcd <= 0;
    end
    else
    begin
        if(match_enable)
        begin
            value_T <= 65*avg_T;        // kanonika thelei epi 0.065 ara i timi pou pairnoume einai *1000
            convert_bcd <= 1;
        end
        else
            convert_bcd <= 0;
    end
end



/* FSM */
always @(posedge clk or posedge reset)
begin
    if(reset)
        current_state <= idle;
    else    
        current_state <= next_state;
end

always @(current_state or addr_reg or data_ready or counter or counter_next_measurment)
begin
    data_X_enable = 0; 
    data_Y_enable = 0;
    data_Z_enable = 0;
    data_T_enable = 0;
    next_state = current_state;
    addr_enable = 0;
    counter_enable = 0;
    avg_count = 0;
    match_enable = 0;
    counter_next_measurment_enable = 0;
    is_signed = 0;
    data_T_LSB_enable = 0;
    data_T_MSB_enable = 0;

    case(current_state)
        idle:
        begin
            if(data_ready)
                next_state = choose_reg;
            else    
                next_state = current_state;
        end

        choose_reg:
        begin
            if(addr_reg == 8'h08)   // addr for x
                next_state = write_x;
            else if(addr_reg == 8'h09)
                next_state = write_y;
            else if(addr_reg == 8'h0A)
                next_state = write_z;
            else if(addr_reg == 8'h15)
                next_state = write_t_MSB; 
            else if (addr_reg == 8'h14)
                next_state = write_t_LSB;
            else
                next_state = idle;
        end

        write_x:
        begin
            data_X_enable = 1;
            next_state = wait_state;
        end

        write_y:
        begin
            data_Y_enable = 1;
            next_state = wait_state;
        end

        write_z:
        begin
            data_Z_enable = 1;
            next_state = wait_state;
        end
        
        write_t_MSB:
        begin
            data_T_MSB_enable = 1;
            next_state = wait_state;
        end

        write_t_LSB:
        begin
            data_T_LSB_enable = 1;
            next_state = data_t_store;
        end

        data_t_store:
        begin
            data_T_enable = 1;
            addr_enable = 1;
            next_state = wait_state;
        end

        wait_state:
        begin
            addr_enable = 0;
            counter_enable = 1;

            if(addr == 8'd128)
            //if(addr == 8'd5)
                next_state = check_sign;
            else if(counter == 5'd18)       // gia na prolavei na pesei to data_ready
                next_state = idle;
            else    
                next_state = current_state;
        end

        check_sign:
        begin
            is_signed = 1;
            next_state = avg_state;
        end

        avg_state:
        begin
            avg_count = 1;
            addr_enable = 0;

            next_state = match_value;
        end

        match_value:
        begin
            match_enable = 1;
            counter_next_measurment_enable = 1;
            next_state = idle;
        end
    endcase
end


// den einai mesa ston kodika pou douleuei
always @(posedge clk or posedge reset)
begin
    if(reset)
        Temp_data <= 16'b0;
    else
    begin
        if(data_T_MSB_enable)
            Temp_data[15:8] <= data_acc;
        else if(data_T_LSB_enable)
        begin
            Temp_data[7:0] <= data_acc;
        end
    end
end


assign ascii_X1 = ascii_value_0 + digit_1X;
assign ascii_X2 = ascii_value_0 + digit_2X;
assign ascii_X3 = ascii_value_0 + digit_3X;
assign ascii_X4 = ascii_value_0 + digit_4X;

assign ascii_Y1 = ascii_value_0 + digit_1Y;
assign ascii_Y2 = ascii_value_0 + digit_2Y;
assign ascii_Y3 = ascii_value_0 + digit_3Y;
assign ascii_Y4 = ascii_value_0 + digit_4Y;

assign ascii_Z1 = ascii_value_0 + digit_1Z;
assign ascii_Z2 = ascii_value_0 + digit_2Z;
assign ascii_Z3 = ascii_value_0 + digit_3Z;
assign ascii_Z4 = ascii_value_0 + digit_4Z;

assign ascii_T0 = ascii_value_0 + digit_0T;
assign ascii_T1 = ascii_value_0 + digit_1T;
assign ascii_T2 = ascii_value_0 + digit_2T;
assign ascii_T3 = ascii_value_0 + digit_3T;
assign ascii_T4 = ascii_value_0 + digit_4T;
assign ascii_T5 = ascii_value_0 + digit_5T;
assign ascii_T6 = ascii_value_0 + digit_6T;


/* Choose if it is signed or not */
assign value_X_new = (value_X[15] == 1 ) ? (~value_X)+1: value_X;
assign value_Y_new = (value_Y[15] == 1 ) ? (~value_Y)+1: value_Y;
assign value_Z_new = (value_Z[15] == 1 ) ? (~value_Z)+1: value_Z;
//assign value_T_new = (value_T[15] == 1 ) ? ~value_T: value_T;

/* Ean to MSB einai 1 tote einai negative */
assign is_negative_X = (value_X[15] == 1 ) ? 1 : 0;
assign is_negative_Y = (value_Y[15] == 1 ) ? 1 : 0;
assign is_negative_Z = (value_Z[15] == 1 ) ? 1 : 0;
//assign is_negative_T = (value_T[15] == 1 ) ? 1 : 0;

bin2bcd bin2bcd_init(.clk(clk), .reset(reset), .value(value_X_new), .convert_bcd(convert_bcd), .digit_0(digit_0X), .digit_1(digit_1X), .digit_2(digit_2X), .digit_3(digit_3X), .digit_4(digit_4X), .digit_5(digit_5X));
bin2bcd bin2bcd_2_init(.clk(clk), .reset(reset), .value(value_Y_new), .convert_bcd(convert_bcd), .digit_0(digit_0Y), .digit_1(digit_1Y), .digit_2(digit_2Y), .digit_3(digit_3Y), .digit_4(digit_4Y), .digit_5(digit_5Y));
bin2bcd bin2bcd_3_init(.clk(clk), .reset(reset), .value(value_Z_new), .convert_bcd(convert_bcd), .digit_0(digit_0Z), .digit_1(digit_1Z), .digit_2(digit_2Z), .digit_3(digit_3Z), .digit_4(digit_4Z), .digit_5(digit_5Z));
//bin2bcd bin2bcd_4_init(.clk(clk), .reset(reset), .value(value_T_new), .convert_bcd(convert_bcd), .data_ready_for_printing(data_ready_for_printing), .digit_0(digit_0T), .digit_1(digit_1T), .digit_2(digit_2T), .digit_3(digit_3T), .digit_4(digit_4T), .digit_5(digit_5T));

bin2bcd_temp bin2bcd_temp_init(.clk(clk), .reset(reset), .value(value_T), .convert_bcd(convert_bcd), .data_ready_for_printing(data_ready_for_printing), .digit_0(digit_0T), .digit_1(digit_1T), .digit_2(digit_2T), .digit_3(digit_3T), .digit_4(digit_4T), .digit_5(digit_5T), .digit_6(digit_6T));



endmodule
            
