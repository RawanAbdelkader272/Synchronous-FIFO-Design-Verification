package FIFO_scoreboard_pkg;
    import shared_pkg::*;
    import FIFO_transaction_pkg::*;

    class FIFO_scoreboard;
        parameter FIFO_WIDTH = 16;
        parameter FIFO_DEPTH = 8;

        // Reference model queue
        logic [FIFO_WIDTH-1:0] fifo_queue [$];
        logic [FIFO_WIDTH-1:0] data_out_ref;

        // Check data against reference model
        function void check_data(FIFO_transaction txn);
            reference_model(txn);

            if(txn.rst_n && txn.rd_en) begin
                if(data_out_ref === txn.data_out) begin
                    correct_count++;
                end else begin
                    error_count++;
                    $display("Time:%0t ERROR: Expected: %h, Got: %h (wr_en=%0b, rd_en=%0b)",
                             $time, data_out_ref, txn.data_out, txn.wr_en, txn.rd_en);
                end
            end
        endfunction

        // Reference model implementation
        function void reference_model(FIFO_transaction txn);
            if(!txn.rst_n) begin
                fifo_queue.delete();
                data_out_ref = 0;
            end
            else begin
                // Write operation
                if(txn.wr_en && (fifo_queue.size() < FIFO_DEPTH)) begin
                    fifo_queue.push_back(txn.data_in);
                end

                // Read operation
                if(txn.rd_en && (fifo_queue.size() > 0)) begin
                    data_out_ref = fifo_queue.pop_front();
                end
            end
        endfunction

        // Constructor
        function new();
            data_out_ref = 0;
        endfunction

    endclass

endpackage