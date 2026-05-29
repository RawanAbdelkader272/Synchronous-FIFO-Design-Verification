package FIFO_transaction_pkg;
    
    class FIFO_transaction;
        parameter FIFO_WIDTH = 16;

        // Distribution weights
        int RD_EN_ON_DIST = 30;
        int WR_EN_ON_DIST = 70;

        // Random inputs
        rand logic [FIFO_WIDTH-1:0] data_in;
        rand logic rst_n;
        rand logic wr_en;
        rand logic rd_en;

        // Observed outputs
        logic [FIFO_WIDTH-1:0] data_out;
        logic wr_ack;
        logic overflow;
        logic full;
        logic empty;
        logic almostfull;
        logic almostempty;
        logic underflow;

        // Constructor with default weights
        function new(int wr_weight = 70, int rd_weight = 30);
            WR_EN_ON_DIST = wr_weight;
            RD_EN_ON_DIST = rd_weight;
        endfunction

        // Constraints for signal distribution
        constraint control_signals {
            rst_n dist {0 := 1, 1 := 99};
            wr_en dist {1 := WR_EN_ON_DIST, 0 := (100 - WR_EN_ON_DIST)};
            rd_en dist {1 := RD_EN_ON_DIST, 0 := (100 - RD_EN_ON_DIST)};
        }

    endclass

endpackage