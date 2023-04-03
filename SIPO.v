// serial to parrarel 
module SIPO(clk, reset, SI, shift, PO);
input SI, clk, reset, shift;
output [7:0] PO;        // pararel output 
reg [0:7] tmp;

always @(posedge clk)
begin
    if(reset)   
        tmp <= 0;
    else
    begin
        if(shift == 1)
            tmp = {SI, tmp[0:6]};
    end
end
assign PO = tmp;

endmodule