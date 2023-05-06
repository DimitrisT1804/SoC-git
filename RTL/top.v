module top_module(clk, reset, Rx_D, decoded_data, output_valid, ce, CEO);

input clk, reset;
input Rx_D;
output [7:0] decoded_data;
output output_valid, CEO;

//reg Rx_D = 1;

//reg[2:0] baud_select = 3'b111;
wire [7:0] Rx_DATA;
wire Rx_VALID;
output ce;
wire [7:0] output_byte;
//reg Rx_EN = 1'b1;


uart_reciever uart_reciever_inst(.clk(clk), .reset(reset), .Rx_DATA(Rx_DATA), .baud_select(3'b111), .Rx_EN(1'b1), .Rx_D(Rx_D),
.Rx_VALID(Rx_VALID));

FSM_Reed FSM_Reed_inst(.clk(clk), .reset(reset), .Rx_DATA(Rx_DATA), . Rx_VALID(Rx_VALID), .ce_out(ce), .output_byte(output_byte));

RS_dec RS_dec_inst(.clk(clk), .reset(reset), .CE(ce), .input_byte(output_byte), .Out_byte(decoded_data), .CEO(CEO),
.Valid_out(output_valid));


endmodule
