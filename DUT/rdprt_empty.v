module rdptr_empty
  #(parameter ADR_LEN = 3)
  ( input rd_clk, rdrst_n, rd_en,
   	input [ADR_LEN:0] wr_gray_sync,	
   	output reg [ADR_LEN:0] rd_bin, rd_gray,
    output reg empty
  );
  
  	wire [ADR_LEN:0] rd_bin_next;
  	wire [ADR_LEN:0] rd_gray_next;
  	wire rempty;

  	assign rd_bin_next  = rd_bin + (rd_en & !empty);
  	assign rd_gray_next = (rd_bin_next >> 1) ^ rd_bin_next;
  
  	always @(posedge rd_clk or negedge rdrst_n) begin
      if(!rdrst_n) begin
        	rd_bin <= 0;
        	rd_gray <= 0;
          	empty <= 1;
    	end
    	else begin
        	rd_bin <= rd_bin_next;
        	rd_gray <= rd_gray_next;
          	empty <= rempty;
    	end
	end
  
  assign rempty = (rd_gray_next == wr_gray_sync);
endmodule