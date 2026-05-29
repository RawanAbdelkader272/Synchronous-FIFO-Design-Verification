package FIFO_coverage_pkg;
    import FIFO_transaction_pkg::*;

    class FIFO_coverage;
        FIFO_transaction cov_txn;

        // Covergroup for functional coverage
        covergroup fifo_cg;
            // Input coverpoints
            wr_en_cp: coverpoint cov_txn.wr_en;
            rd_en_cp: coverpoint cov_txn.rd_en;
            
            // Output coverpoints
            wr_ack_cp: coverpoint cov_txn.wr_ack;
            overflow_cp: coverpoint cov_txn.overflow;
            full_cp: coverpoint cov_txn.full;
            empty_cp: coverpoint cov_txn.empty;
            almostfull_cp: coverpoint cov_txn.almostfull;
            almostempty_cp: coverpoint cov_txn.almostempty;
            underflow_cp: coverpoint cov_txn.underflow;

            // Cross coverage between control signals and status flags
            cross_wr_ack: cross wr_en_cp, rd_en_cp, wr_ack_cp;
            cross_overflow: cross wr_en_cp, rd_en_cp, overflow_cp;
            cross_full: cross wr_en_cp, rd_en_cp, full_cp;
            cross_empty: cross wr_en_cp, rd_en_cp, empty_cp;
            cross_almostfull: cross wr_en_cp, rd_en_cp, almostfull_cp;
            cross_almostempty: cross wr_en_cp, rd_en_cp, almostempty_cp;
            cross_underflow: cross wr_en_cp, rd_en_cp, underflow_cp;
            
        endgroup

        // Constructor
        function new();
            cov_txn = new();
            fifo_cg = new();
        endfunction

        // Sample transaction data
        function void sample_data(FIFO_transaction txn);
            cov_txn = txn;
            fifo_cg.sample();
        endfunction

    endclass

endpackage