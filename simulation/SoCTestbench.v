`timescale 1ns/1ns
module testbench_SoC;

reg clk, reset;
reg Rx_D;
wire [7:0] decoded_data;

parameter number = 1;  ///  number of input codewords

reg [7:0] in_mem [0:(number*204)-1];
reg [7:0] input_byte; 
integer i;

wire output_valid;


top_module top_module_inst(.clk(clk), .reset(reset), .Rx_D(Rx_D), .decoded_data(decoded_data), .output_valid(output_valid));

initial 
begin

    $dumpfile("test.vcd");
    $dumpvars(1, testbench_SoC, testbench_SoC.top_module_inst, testbench_SoC.top_module_inst.uart_reciever_inst, testbench_SoC.top_module_inst.FSM_Reed_inst,testbench_SoC.top_module_inst.RS_dec_inst );
    clk = 0;
    reset = 1;
    $readmemb("input_RS_blocks",in_mem);
    Rx_D = 1;           // initializing value
    #10 reset = 0;
    // in_mem[0] = 8'b11101110;
    // in_mem[1] = 8'b11110110;
    // in_mem[2] = 8'b11011100;
    // in_mem[3] = 8'b01011110;
    // in_mem[4] = 8'b10100111;
    // in_mem[5] = 8'b01110101;
    // in_mem[6] = 8'b00110111;
    // in_mem[7] = 8'b11000100;


    for(i = 0; i < 204; i = i+ 1)
    begin
        input_byte = in_mem[i];
        #8640 Rx_D = 0;     // Start bit
        #8640 Rx_D = input_byte[0];
        #8640 Rx_D = input_byte[1];
        #8640 Rx_D = input_byte[2];
        #8640 Rx_D = input_byte[3];
        #8640 Rx_D = input_byte[4];
        #8640 Rx_D = input_byte[5];
        #8640 Rx_D = input_byte[6];
        #8640 Rx_D = input_byte[7];
        #8640 Rx_D = 0;     // parity bit
        #8640 Rx_D = 1;     // Stop bit
    end


    

end

always @(output_valid)
begin
    if(output_valid)
        $finish;
end


always #5 clk = ~clk;

endmodule
