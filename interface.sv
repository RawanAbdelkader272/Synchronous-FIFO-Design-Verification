interface IF(input bit clk);
    parameter FIFO_WIDTH = 16;
    parameter FIFO_DEPTH = 8;

    logic [FIFO_WIDTH-1:0] data_in;
    logic [FIFO_WIDTH-1:0] data_out;
    logic rst_n;
    logic wr_en;
    logic rd_en;
    logic wr_ack;
    logic overflow;
    logic underflow;
    logic full;
    logic empty;
    logic almostfull;
    logic almostempty;

    // Design modport
    modport DUT(
        input clk, rst_n, wr_en, rd_en, data_in,
        output data_out, wr_ack, overflow, underflow, full, empty, almostfull, almostempty
    );

    // Testbench modport
    modport TB(
        output clk, rst_n, wr_en, rd_en, data_in,
        input data_out, wr_ack, overflow, underflow, full, empty, almostfull, almostempty
    );

endinterface