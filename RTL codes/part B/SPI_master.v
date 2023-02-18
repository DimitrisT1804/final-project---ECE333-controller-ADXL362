// SPI Master version 2
// new version
module SPI_Master(clk, reset, instruction, addr, data, MISO, clkout_5_mhz, MOSI, master_enable, spi_idle, data_ready, data_acc, CS, locked);

input clk, reset, MISO, master_enable, clkout_5_mhz, locked;
input [7:0] instruction, addr, data;
output MOSI, spi_idle, data_acc, CS;
output reg data_ready;
reg CS, spi_idle;
reg [7:0] data_acc;

reg [7:0] instructions [2:0];

reg [4:0] counter_5mhz;
reg counter_5mhz_enable;

reg [3:0] addr_of_instructions, counter_shifter;
reg addr_enable, addr_reset, counter_shifter_enable;

reg [7:0] shift;
reg read_from_acc, load, shift_enable, recieve;

reg [3:0] current_state, next_state;

parameter idle = 4'b0000,
            load_shifter = 4'b0001,
            cs_down = 4'b0010,
            send_data = 4'b0011,
            addr_add = 4'b0100,
            check_if_last_data = 4'b0101,
            cs_up = 4'b0111,
            choose_func = 4'b1000,
            read_data = 4'b1001,
            load_data_2 = 4'b1010,
            waiting = 4'b1011, 
            recieving = 4'b1110,
            data_is_ready = 4'b1111,
            send_MSB = 4'b0110;


always @(posedge clk or posedge reset)
begin
    if(reset)
    begin
        instructions[0] <= 8'b0;
        instructions[1] <= 8'b0;
        instructions[2] <= 8'b0;
    end
    else
    begin
        instructions[0] <= instruction;
        instructions[1] <= addr;
        instructions[2] <= data;
    end
end


always @(posedge clk or posedge reset)
begin
    if(reset)
    begin
        shift <= 8'b0;
        counter_shifter <= 4'b0;
    end
    else
    begin
        if(load)
            shift <= instructions[addr_of_instructions];
        else if (shift_enable)
        begin
            if(counter_5mhz == 5'd12)
            begin
                shift <= {shift[6:0], MISO};
                counter_shifter <= counter_shifter + 4'b1;
            end
        end
        else if(recieve)
        begin
            if(counter_5mhz == 5'd0)
            begin
                shift <= {shift[6:0], MISO};
                counter_shifter <= counter_shifter + 4'b1;
            end
        end
        else
            counter_shifter <= 4'b0;
    end
end

assign MOSI = (recieve) ? 0 : shift[7];


always @(posedge clk or posedge reset)
begin
    if(reset)
        current_state <= idle;
    else
        current_state <= next_state;
end

always @(current_state or master_enable or counter_5mhz or counter_shifter or addr_of_instructions)
begin
    CS = 0;
    load = 0;
    shift_enable = 0;
    addr_enable = 0;
    addr_reset = 0;
    read_from_acc = 0;
    data_ready = 0;
    spi_idle = 0;
    recieve = 0;
    next_state = current_state;

    case(current_state)
        idle:
        begin
            spi_idle = 1;
            CS = 1;
            if(master_enable)
                next_state = load_shifter;
            else
                next_state = current_state;
        end

        load_shifter:
        begin
            load = 1;
            CS = 1;
            if(master_enable == 0)
                next_state = idle;
            else if(counter_5mhz == 5'd8)  
                next_state = cs_down;
            else
                next_state = current_state;
        end

        cs_down:
        begin
            CS = 0;

            if(counter_5mhz == 5'd0)
                next_state = send_MSB;
            else
                next_state = current_state;
        end

        send_MSB:
        begin
            if(counter_5mhz == 5'd11)
                next_state = send_data;
            else
                next_state = current_state;
        end

        send_data:
        begin
            shift_enable = 1;
            if(counter_shifter == 4'd7)
                next_state = waiting;
            else
                next_state = current_state;
        end

        waiting:
        begin
            if(counter_5mhz == 5'd11)
                next_state = addr_add;
            else
                next_state = current_state;
        end

        addr_add:
        begin
            addr_enable = 1;
            next_state = check_if_last_data;

        end

        check_if_last_data:
        begin
            if(addr_of_instructions == 2'd3)      
                next_state = cs_up;
            else if(addr_of_instructions == 2'd2)
                next_state = choose_func;
            else 
                next_state = load_data_2;
        end

        load_data_2:
        begin
            load = 1;
            CS = 0;
            if(counter_5mhz == 5'd16)
                next_state = send_data;
            else
                next_state = current_state;
        end

        cs_up:
        begin
            CS = 1;
            addr_reset = 1;
            if(counter_5mhz == 5'd0)
                next_state = idle;
            else
                next_state = current_state;
        end

        choose_func:
        begin
            if(instruction == 8'b00001011)  //read data
                next_state = recieving;
            else if (instruction == 8'b00001010)
                next_state = load_data_2;
            else
                next_state = idle;
        end

        recieving:
        begin
            CS = 0;
            recieve = 1;
            if(counter_shifter == 4'd8)
                next_state = read_data;
            else
                next_state = current_state;
        end

        read_data:
        begin
            read_from_acc = 1;
            
            next_state = data_is_ready;
        end

        data_is_ready:
        begin
            data_ready = 1;
            if(counter_5mhz == 5'd12)
                next_state = cs_up;
            else
                next_state = current_state;
        end

        endcase
end




always @(posedge clkout_5_mhz or posedge reset)
begin
    if(reset)
        counter_5mhz_enable <= 0;
    else
    begin
        if(locked)
            counter_5mhz_enable <= 1;
        else
            counter_5mhz_enable <= 0;
    end
end

/* Counter gia na metrao ton xrono anamesa stis periodous tou rologiou tou SPI */
always @(posedge clk or posedge reset)
begin
    if(reset)
        counter_5mhz <= 5'b0;
    else
    begin
        if(counter_5mhz == 5'd19)
            counter_5mhz <= 5'b0;
        else if(counter_5mhz_enable)
            counter_5mhz <= counter_5mhz + 5'b1;
        else
            counter_5mhz <= 5'b0;
    end
end

/* Deixnei apo poia dieuthinsi na steilei data */
always @(posedge clk or posedge reset)
begin
    if(reset)
        addr_of_instructions <= 2'b0;
    else
    begin
        if(addr_enable)
            addr_of_instructions <= addr_of_instructions + 2'b1;
        else if (addr_reset)
            addr_of_instructions <= 2'b0;
    end
end

always @(posedge clk or posedge reset)
begin
    if(reset)
        data_acc <= 8'b0;
    else
    begin
        if(read_from_acc)
            data_acc <= shift;
    end
end

//clock_mmcm clock_mmcm_inst(clk, reset, clkout_8mhz);

endmodule

