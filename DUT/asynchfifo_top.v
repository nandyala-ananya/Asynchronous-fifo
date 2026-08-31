module asynchfifo_top
#(  parameter DEPTH      = 8,
    parameter DATA_WIDTH = 8
)(  input wr_clk, wrst_n, rd_clk, rdrst_n, wr_en, rd_en,
    input [DATA_WIDTH-1:0] data_in,
    output [DATA_WIDTH-1:0] data_out,
    output full, empty
);

    parameter ADR_LEN = $clog2(DEPTH);

    wire [ADR_LEN:0] wr_gray_sync, rd_gray_sync, wr_bin, rd_bin, wr_gray, rd_gray;

    synchronizer #(.LEN(ADR_LEN+1)) synch_wr_to_rd
    (   .clk(rd_clk),
        .rst_n(rdrst_n),
        .d(wr_gray),
        .q(wr_gray_sync)
    );

    synchronizer #(.LEN(ADR_LEN+1)) synch_rd_to_wr
    (   .clk(wr_clk),
        .rst_n(wrst_n),
        .d(rd_gray),
        .q(rd_gray_sync)
    );

    wrptr_full #(.ADR_LEN(ADR_LEN)) wdomain
    (   .wr_clk(wr_clk),
        .wrst_n(wrst_n),
        .wr_en(wr_en),
        .rd_gray_sync(rd_gray_sync),
        .wr_bin(wr_bin),
        .wr_gray(wr_gray),
        .full(full)
    );

    rdptr_empty #(.ADR_LEN(ADR_LEN))rdomain
    (   .rd_clk(rd_clk),
        .rdrst_n(rdrst_n),
        .rd_en(rd_en),
        .wr_gray_sync(wr_gray_sync),
        .rd_bin(rd_bin),
        .rd_gray(rd_gray),
        .empty(empty)
    );

    memory #(.DEPTH(DEPTH), .DATA_LEN(DATA_WIDTH), .ADR_LEN (ADR_LEN))memory
    (   .wr_clk(wr_clk),
        .wr_en(wr_en),
        .rd_clk(rd_clk),
        .rd_en(rd_en),
        .wr_bin(wr_bin),
        .rd_bin(rd_bin),
        .data_in(data_in),
        .full(full),
        .empty(empty),
        .data_out(data_out)
    );

endmodule