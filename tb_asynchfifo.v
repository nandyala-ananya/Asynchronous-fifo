`timescale 1ns/1ps

module tb_asynchfifo;

	parameter DATA_LEN = 8, DEPTH = 8;
	reg wr_clk, rd_clk, wrst_n, rdrst_n, wr_en, rd_en;
	reg [DATA_LEN-1:0] data_in;
	wire [DATA_LEN-1:0] data_out;
	wire full, empty;
	
  	// Dut instantiation
  	asynchfifo_top #(.DEPTH(DEPTH), .DATA_WIDTH(DATA_LEN)) dut
	(  	.wr_clk(wr_clk),
    	.wrst_n(wrst_n),
    	.rd_clk(rd_clk),
    	.rdrst_n(rdrst_n),
    	.wr_en(wr_en),
    	.rd_en(rd_en),
    	.data_in(data_in),
    	.data_out(data_out),
    	.full(full),
    	.empty(empty)
	);

	// Clock generation
	always #5 wr_clk = ~wr_clk;
	always #7 rd_clk = ~rd_clk;


	// Reset Task
	task reset_fifo;
	begin
    	wrst_n = 0;
    	rdrst_n = 0;
    	wr_en = 0;
    	rd_en = 0;
    	data_in = 0;
    	#30;
    	wrst_n = 1;
    	rdrst_n = 1;
      	repeat(2) @(posedge wr_clk);
    	repeat(2) @(posedge rd_clk);
        
      $display("Reset done");
	end
	endtask


	// Write Task
	task write_fifo;
	input [DATA_LEN-1:0] data;
	begin
    	@(posedge wr_clk);
    	if(!full) begin
          	wr_en <= 1;
        	data_in <= data;              
          $display("[%0t] Write: %0d",$time,data);
    	end
    	else begin
          $display("[%0t] Write is skipped as FIFO is full",$time);
        end
    	@(posedge wr_clk);
    	wr_en <= 0;
	end
	endtask


	// Read Task
	task read_fifo;
    begin
        @(posedge rd_clk);
        if(!empty)
            rd_en = 1;
        else
          $display("[%0t] Read is skipped as FIFO is empty",$time);
        @(posedge rd_clk);
            rd_en = 0;
        if(!empty)
          $display("[%0t] Read: %0d",$time,data_out);
    end
	endtask


	// Monitor
	initial
	begin
      $monitor("T=%0t: Full=%b Empty=%b wr_en=%b rd_en=%b data_in=%0d data_out=%0d",$time,full,empty,wr_en,rd_en,data_in,data_out);
	end


	// Input triggering cases 
  
	initial
	begin
    	wr_clk = 0;
    	rd_clk = 0;
    	reset_fifo();

    // CASE 1: WRITE AND READ    

      	$display("\n----CASE 1: WRITE AND READ ----");

    	write_fifo(8'd10);
    	write_fifo(8'd20);
    	write_fifo(8'd30);
    	read_fifo();
    	read_fifo();
    	read_fifo();
    	#50;

      // CASE 2: FILLING FIFO  

      	$display("\n---- CASE 2: FILLING FIFO ----");
      
    	repeat(DEPTH)
        	write_fifo($random);
      
      	// Waiting for rd_ptr to reach write domain to make full flag high  
      	repeat(3) @(posedge wr_clk);
    		if(full)
              $display("Full Flag is High");
    	#50;

   		// CASE 3: EMPTYING FIFO  

      	$display("\n---- CASE 3: EMPTYING FIFO ----");
      
    	repeat(DEPTH)
        	read_fifo();
      	// Waiting for wr_ptr to reach read domain to make empty flag high
      	repeat(3) @(posedge rd_clk);
    		if(empty)
              $display("Empty Flag is High");
    		        		
    	#100;
      $display("\nSIMULATION FINISHED");
      	$finish;
	end
endmodule