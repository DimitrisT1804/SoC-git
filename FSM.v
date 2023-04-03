module FSM_Reed (clk, reset, Rx_DATA, Rx_VALID, ce_out, output_byte, output_valid);

input clk;
input reset;
input [7:0] Rx_DATA;
input Rx_VALID;
output ce_out;
output reg [7:0] output_byte;
input output_valid;

reg [7:0] counter;
reg [2:0] current_state, next_state;
reg counter_enable;

reg Q1, Q2, data_valid;
reg ce;

parameter
    state_off = 3'b000,
    state_sending = 3'b001,
    state_idle = 3'b010,
    waitning = 3'b011,
    counter_activate = 3'b100;

always @(posedge clk) 
begin
if (reset == 1)
    current_state <= state_off;
else
    current_state <= next_state;
end

always @(current_state or Rx_VALID or counter or Rx_DATA or output_valid) 
begin
    ce = 0;
    output_byte = 8'b0;
    next_state = current_state;
    counter_enable = 0;
    data_valid = 0;

    case(current_state)
        state_off : 
        begin
            next_state = waitning;
        end

        waitning:
        begin
            if(Rx_VALID)
                next_state = counter_activate;
            else
                next_state = waitning;
        end

        counter_activate:
        begin
            counter_enable = 1;
            next_state = state_sending;
        end

        state_sending : 
        begin 
            //output_byte = Rx_DATA;
            data_valid = 1;
            ce = 1;
            //counter_enable = 1;
            if(counter == 8'd204)       // na doume ligo tin timi
                next_state = state_idle;

            else if(Rx_VALID == 0)
                next_state = waitning;
            else
                next_state = state_sending;

        end
        state_idle:
        begin
            if(output_valid)
                next_state = waitning;
            else
                next_state = current_state;
        end
    endcase
end


always@(posedge clk)
begin
    if(reset)
        counter <= 8'b0;
    else
    begin
    if(counter_enable)
        counter <= counter + 8'b1;
    end
end


always @(posedge clk)       // kati san antibounce gia na kratiso ton palmo gia ena kiklo rologioy
begin
    Q1 <= ce;
end

always @(posedge clk)
begin
    Q2 <= Q1;
end

assign Q2_bar = ~Q2;
assign ce_out = (Q2_bar & Q1);


always @(posedge clk)
begin
    if(reset)
        output_byte <= 8'b0;
    else
    begin
        if(data_valid)
            output_byte <= Rx_DATA;
    end
end


// always @(posedge clk)
// begin
//     if(reset)
//         counter_for_RxValid <= 6'b0;
//     else
//     begin
//         if(counter_Rx_enable)
//             counter_for_RxValid <= counter_for_RxValid + 1;
//     end
// end

endmodule