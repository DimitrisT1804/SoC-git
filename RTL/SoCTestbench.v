//`timescale 1ns/1ns
module testbench_SoC;

reg clk, reset;
reg Rx_D;
wire [7:0] decoded_data;

parameter number = 2;  ///  number of input codewords
parameter iterations = 1;

reg [7:0] in_mem [0:(number*204)-1], out_mem[0:(number*188)-1];
reg [7:0] input_byte; 
integer i;
wire ce, CEO;

wire output_valid;
integer h,k,err;



initial 
begin

    $dumpfile("test.vcd");
    $dumpvars(1, testbench_SoC, testbench_SoC.top_module_inst, testbench_SoC.top_module_inst.uart_reciever_inst, testbench_SoC.top_module_inst.FSM_Reed_inst,testbench_SoC.top_module_inst.RS_dec_inst );
    clk = 0;
    reset = 1;
    h = 0;
    k = 0;
    err = 0;
    $readmemb("input_RS_blocks",in_mem);
    $readmemb("output_RS_blocks",out_mem);
    //$monitor("output_valid is: %d and flag is: %d and i is: %d, counter is: %d", output_valid, flag, i, counter_ce);
    Rx_D = 1;           // initializing value
    #10 reset = 0;


    for(i = 0; i < (205+(iterations*204)); i = i+ 1)
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

top_module top_module_inst(.clk(clk), .reset(reset), .Rx_D(Rx_D), .decoded_data(decoded_data), .output_valid(output_valid), .ce(ce), .CEO(CEO));

reg [1:0] flag = 2'b0;
always @(output_valid)
begin
    if(output_valid)
    begin
        flag <= flag + 2'b1;
    end
end

reg [7:0] counter_ce = 8'b0;
always @(ce)
begin
    if(ce)
        counter_ce <= counter_ce + 8'b1;
end


always #5 clk = ~clk;

reg [7:0] true_out;

always @ (posedge(clk))
begin
	if(output_valid && CEO)
		begin
			true_out = out_mem[h];
			
			if(true_out !== decoded_data)
				begin
					$display("Error at out no. %d !!!!!!!!!!!!!",h);
					err=err+1;
				end
			h=h+1;
			
			if(h == (number*188) )
				begin
					if (err == 0)
						$display("No Errors !!!!!!!!!!!!!");
					else
						$display("Total Errors =  %d !!!!!!!!!!!!!",err);
						
					$stop;
						
				end
			
		end
end

endmodule
