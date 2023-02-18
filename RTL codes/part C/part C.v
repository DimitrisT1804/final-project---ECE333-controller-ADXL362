// diamorfosi accelerometer
module acc_instructions(clk, reset, spi_idle, master_enable, instruction, addr, data, start_transmision, locked);
input clk, reset, spi_idle, locked;
output reg master_enable, start_transmision;
output [7:0] instruction, addr, data;

//SPI_Master SPI_Master_inst(clk, reset, instruction, addr, data, MISO, clkout_8mhz, MOSI, cs_new, master_enable, spi_idle);

/* FSM vvariables */
reg [4:0] current_state, next_state;
reg [7:0] instruction, addr, data;

reg [18:0] counter_next_measurment;
reg counter_next_measurment_enable;

parameter idle = 5'b00000,
            soft_reset = 5'b00001,
            wait_1 = 5'b00010,
            power_control = 5'b00011,
            wait_2 = 5'b00100,
            filter_control = 5'b00101,
            wait_3 = 5'b00111,
            data_x_state = 5'b01000,
            data_y_state = 5'b01001,
            data_z_state = 5'b01010,
            data_t_state = 5'b01011,
            wait_for_measurment = 5'b01100,
            soft_clear = 5'b01110,
            master_up_1 = 5'b01111,
            master_up_2 = 5'b10000,
            master_up_3 = 5'b10001,
            wait_for_locking = 5'b10010,
            data_t_state_LSB = 5'b10011;

always @(posedge clk or posedge reset)
begin
    if(reset)
        current_state <= wait_for_locking;
    else
        current_state <= next_state;
end

always @(current_state or spi_idle or counter_next_measurment or locked)
begin
    next_state = current_state;
    master_enable = 0;
    instruction = 8'b0;
    addr = 8'b0;
    data = 8'b0;
    counter_next_measurment_enable = 0;
    start_transmision = 0;

    case(current_state)

        wait_for_locking:
        begin
            if(locked)
                next_state = idle;
            else
                next_state = current_state;
        end

        idle:
        begin
            master_enable = 1;
             
            if(spi_idle)
                next_state = soft_reset;
            else
                next_state = current_state;
        end

        soft_reset:
        begin
            master_enable = 1;
            instruction = 8'b00001010;      // write register
            addr = 8'h1F;
            data = 8'h52;
            counter_next_measurment_enable = 0;

            if(spi_idle)
                next_state = wait_1;
            else
                next_state = current_state;

        end
        
        wait_1:
        begin
            master_enable = 0;
            counter_next_measurment_enable = 1;
            
            if(counter_next_measurment == 19'd60000)
                next_state = master_up_1;
            else
                next_state = current_state;   
        end       

        master_up_1:
        begin
            master_enable = 1;

            next_state = soft_clear;
        end  
            

        soft_clear:
        begin
            master_enable = 1;
            instruction = 8'b00001010;      // write register
            addr = 8'h1F;
            data = 8'h0;
            counter_next_measurment_enable = 0;

            if(spi_idle)
                next_state = wait_2;
            else
                next_state = current_state;
        end
        
        wait_2:
        begin
            master_enable = 0;
            counter_next_measurment_enable = 1;
            
            if(counter_next_measurment == 19'd60000)
                next_state = master_up_2;
            else
                next_state = current_state;   
        end         

        master_up_2:
        begin
            master_enable = 1;
            next_state = power_control;
        end  

        power_control:
        begin
            master_enable = 1;
            instruction = 8'b00001010;      // write register
            addr = 8'h2D;
            data = 8'b00000010;
             

            if(spi_idle)
                next_state = filter_control;
            else
                next_state = current_state;
        end

        filter_control:
        begin
            master_enable = 1;
            instruction = 8'b00001010;      // write register
            addr = 8'h2C;
            data = 8'b00010100;

             

            if(spi_idle)
                next_state = data_x_state;
            else
                next_state = current_state;
        end

        data_x_state:
        begin
             
            master_enable = 1;
            instruction = 8'b00001011;      // read register
            //instruction = 8'b10101010;
            addr = 8'h08;
            start_transmision = 1;
            //data = 8'b00010100;

            if(spi_idle)
                next_state = data_y_state;
            else
                next_state = current_state;
        end

        data_y_state:
        begin
             
            master_enable = 1;
            instruction = 8'b00001011;      // read register
            addr = 8'h09;
            //data = 8'b00010100;

            if(spi_idle)
                next_state = data_z_state;
            else
                next_state = current_state;
        end

        data_z_state:
        begin
             
            master_enable = 1;
            instruction = 8'b00001011;      // read register
            addr = 8'h0A;
            //data = 8'b00010100;

            if(spi_idle)
                next_state = data_t_state;
            else
                next_state = current_state;
        end

        data_t_state:
        begin
             
            master_enable = 1;
            instruction = 8'b00001011;      // read register
            addr = 8'h15;
            //data = 8'b00010100;

            if(spi_idle)
                next_state = data_t_state_LSB;  //data_x_state
            else
                next_state = current_state;
        end

        data_t_state_LSB:
        begin
             
            master_enable = 1;
            instruction = 8'b00001011;      // read register
            addr = 8'h14;
            //data = 8'b00010100;

            if(spi_idle)
                next_state = wait_for_measurment;  //data_x_state
            else
                next_state = current_state;
        end

        wait_for_measurment:
        begin
            counter_next_measurment_enable = 1;
             
            master_enable = 0;

            if(counter_next_measurment == 19'd500000)  // kathe 0.005 sec metrisi
                next_state = master_up_3;
            else
                next_state = current_state;
        end      

        master_up_3:
        begin
            master_enable = 1;

            next_state = data_x_state;

        end    



    endcase
end

/* Counter gia na metraei xrono mexri tin epomeni meterisi tou accelerometer */
always @(posedge clk or posedge reset)
begin
    if(reset)
        counter_next_measurment <= 19'b0;
    else 
    begin
        if(counter_next_measurment_enable)
            counter_next_measurment <= counter_next_measurment + 19'b1;
        else
            counter_next_measurment <= 19'b0;
    end
end


endmodule
