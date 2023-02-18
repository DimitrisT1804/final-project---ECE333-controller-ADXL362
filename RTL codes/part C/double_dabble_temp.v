module bin2bcd_temp(clk, reset, value, convert_bcd, data_ready_for_printing, digit_0, digit_1, digit_2, digit_3, digit_4, digit_5, digit_6);
input clk, reset, convert_bcd;
input [19:0] value;
output [3:0] digit_0, digit_1, digit_2, digit_3, digit_4, digit_5, digit_6;
output reg data_ready_for_printing;   

reg [2:0] current_state, next_state;
reg [4:0] counter;
reg counter_enable;
reg [47:0] bcd_value;
reg bcd_enable, initialize_value, shift_enable, start;


always @(posedge clk or posedge reset)
begin
    if(reset)
        counter <= 5'b0;
    else
    begin
        if(counter == 5'd16)
            counter <= 5'd0;
        else if(counter_enable)
            counter <= counter + 5'b1;
    end
end

always @(posedge clk or posedge reset)
begin
    if(reset)
        bcd_value <= 48'b0;
    else
    begin
        if(initialize_value)
            bcd_value <= {28'b0, value};
        else if(bcd_enable)
        begin
            if(bcd_value[47:44] >= 4'd5)
                bcd_value[47:44] <= bcd_value[47:44] + 4'd3;
            if(bcd_value[43:40] >= 4'd5)
                bcd_value[43:40] <= bcd_value[43:40] + 4'd3;
            if(bcd_value[39:36] >= 4'd5)
                bcd_value[39:36] <= bcd_value[39:36] + 4'd3;
            if(bcd_value[35:32] >= 4'd5)
                bcd_value[35:32] <= bcd_value[35:32] + 4'd3; 
            if(bcd_value[31:28] >= 4'd5)
                bcd_value[31:28] <= bcd_value[31:28] + 4'd3; 
            if(bcd_value[27:24] >= 4'd5)
                bcd_value[27:24] <= bcd_value[27:24] + 4'd3; 
            if(bcd_value[23:20] >= 4'd5)
                bcd_value[23:20] <= bcd_value[23:20] + 4'd3; 
        end
        else if (shift_enable)
            bcd_value <= bcd_value << 1;
    end
end


assign digit_0 = bcd_value[47:44];
assign digit_1 = bcd_value[43:40];
assign digit_2 = bcd_value[39:36];
assign digit_3 = bcd_value[35:32];
assign digit_4 = bcd_value[31:28];
assign digit_5 = bcd_value[27:24];
assign digit_6 = bcd_value[23:20];

parameter   off = 3'b000,
            idle = 3'b001,
            bcd_conversion = 3'b010,
            shift = 3'b011,
            counter_add = 3'b100,
            data_ready_print = 3'b101;


always @(posedge clk or posedge reset)
begin
    if(reset)
        current_state <= off;
    else
        current_state <= next_state;
end

always @(current_state or counter or convert_bcd)
begin

    counter_enable = 0;
    bcd_enable = 0;
    next_state = current_state;
    initialize_value = 0;
    shift_enable = 0;
    data_ready_for_printing = 0;

    case(current_state)
        off:
        begin
            if(convert_bcd)
                next_state = idle;
            else    
                next_state = current_state;
        end
        idle:
        begin
            initialize_value = 1;

            next_state = bcd_conversion;
        end

        bcd_conversion:
        begin
            bcd_enable = 1;
            next_state = shift;
        end

        shift:
        begin
            shift_enable = 1;
            next_state = counter_add;
        end

        counter_add:
        begin
            counter_enable = 1;
            if(counter == 5'd15)
                next_state = data_ready_print;
            else
                next_state = bcd_conversion;
        end

        data_ready_print:
        begin
            data_ready_for_printing = 1;
            next_state = off;
        end 
    endcase
end

endmodule