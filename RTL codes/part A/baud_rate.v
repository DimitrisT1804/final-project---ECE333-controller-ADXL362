//part A
module Baud_controller (reset, clk, baud_select, sample_ENABLE);
input reset, clk;
input [2:0] baud_select;
output reg sample_ENABLE;

reg [14:0] counter;
reg [14:0] limit;
reg check;

always @(baud_select)
begin
    case (baud_select)
        3'b000: limit = 20833;
        3'b001: limit = 5208;
        3'b010: limit = 1302;  
        3'b011: limit = 651;   
        3'b100: limit = 326;   
        3'b101: limit = 163;     
        3'b110: limit = 109;     
        3'b111: limit = 54;     

    endcase 
end

always @(posedge clk or posedge reset)
begin
    if(reset)
        counter <= 0;
    else
        if(check == 1)
            counter <= counter + 15'b1; 
        else
            counter <= 0;
end

always @(counter or limit)
begin
    if(counter == limit-1)  // limit-1 dioti otan metraei o counter anevainei sto epomeno posedge. opote vazoyme -1 gia na einai sostos o xronos
    begin
        sample_ENABLE = 1;
    end
    else
        sample_ENABLE = 0;

end

always @(sample_ENABLE)
begin
    if(sample_ENABLE == 1)
        check = 0;
    else 
        check = 1;
end

endmodule