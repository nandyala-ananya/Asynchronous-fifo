module memory #(parameter DEPTH=8, DATA_LEN=8, ADR_LEN=3) (
  	input wr_clk, wr_en, rd_clk, rd_en,
  	input [ADR_LEN:0] wr_bin, rd_bin,
  	input [DATA_LEN-1:0] data_in,
  	input full, empty,
  	output reg [DATA_LEN-1:0] data_out
);
  
  	reg [DATA_LEN-1:0] mem[0:DEPTH-1];
  
  	always@(posedge wr_clk) begin
    	if(wr_en & !full) begin
          mem[wr_bin[ADR_LEN-1:0]] <= data_in;
    	end
  	end
  
  	always@(posedge rd_clk) begin
      	if(rd_en & !empty) begin
          	data_out <= mem[rd_bin[ADR_LEN-1:0]];
    	end
  	end
  
endmodule