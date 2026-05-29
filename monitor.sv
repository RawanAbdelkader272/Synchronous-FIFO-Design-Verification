module monitor(IF.TB if_mon);

    import shared_pkg::*;
    import FIFO_transaction_pkg::*;
    import FIFO_coverage_pkg::*;
    import FIFO_scoreboard_pkg::*;

    FIFO_coverage coverage_obj;
    FIFO_transaction trans_obj;
    FIFO_scoreboard scoreboard_obj;

    initial begin
        coverage_obj = new();
        trans_obj = new();
        scoreboard_obj = new();

        forever begin
            // Wait for new inputs
            @(pass_inputs);
            
            // Sample inputs
            trans_obj.data_in = if_mon.data_in;
            trans_obj.rst_n = if_mon.rst_n;
            trans_obj.wr_en = if_mon.wr_en;
            trans_obj.rd_en = if_mon.rd_en;

            // Wait for outputs to stabilize
            @(negedge if_mon.clk);
            
            // Sample outputs
            trans_obj.data_out = if_mon.data_out;
            trans_obj.wr_ack = if_mon.wr_ack;
            trans_obj.overflow = if_mon.overflow;
            trans_obj.full = if_mon.full;
            trans_obj.empty = if_mon.empty;
            trans_obj.almostfull = if_mon.almostfull;
            trans_obj.almostempty = if_mon.almostempty;
            trans_obj.underflow = if_mon.underflow;

            // Parallel coverage and checking
            fork 
                coverage_obj.sample_data(trans_obj);
                scoreboard_obj.check_data(trans_obj);
            join

            // Check for test completion
            if(test_finished) begin
                $display("Time:%0t - Test Complete: Correct=%0d, Errors=%0d",
                         $time, correct_count, error_count);
                $finish;
            end
        end
    end

endmodule