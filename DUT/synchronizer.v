module synchronizer 
	#(parameter LEN = 4)
    ( input clk, rst_n,
      input [LEN-1:0] d,
	  output reg [LEN-1:0] q
    );
  	reg [LEN-1:0] q0;
  	always@(posedge clk or negedge rst_n) begin
    	if(!rst_n) begin
      		q0 <= 0;
      		q <= 0;
    	end
    	else begin
      		q0 <= d;
      		q <= q0;
    	end
 	end
endmodule