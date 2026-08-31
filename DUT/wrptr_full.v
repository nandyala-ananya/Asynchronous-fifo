module wrptr_full
  #(parameter ADR_LEN = 3)
  ( input wr_clk, wrst_n, wr_en,
   	input [ADR_LEN:0] rd_gray_sync,	
   	output reg [ADR_LEN:0] wr_bin, wr_gray,
    output reg full
  );
  
  	wire [ADR_LEN:0] wr_bin_next;
	wire [ADR_LEN:0] wr_gray_next;
  	wire wfull;

  	assign wr_bin_next  = wr_bin + (wr_en & !full);
	assign wr_gray_next = (wr_bin_next >> 1) ^ wr_bin_next;
  
  	always @(posedge wr_clk or negedge wrst_n) begin
      	if(!wrst_n) begin
        	wr_bin <= 0;
        	wr_gray <= 0;
          	full <= 0;
    	end
    	else begin
        	wr_bin <= wr_bin_next;
        	wr_gray <= wr_gray_next;
          	full <= wfull;
    	end
	end
  
  assign wfull = (wr_gray_next == {~rd_gray_sync[ADR_LEN:ADR_LEN-1], rd_gray_sync[ADR_LEN-2:0]});
endmodule