module tb(IF.TB if_tb);
    import FIFO_transaction_pkg::*;
    import shared_pkg::*;

    parameter NUM_TESTS = 1000000;
    FIFO_transaction trans_obj;

    initial begin
        trans_obj = new();

        apply_reset();
        
        for(int i = 0; i < NUM_TESTS; i++) begin
            @(negedge if_tb.clk);
            void'(trans_obj.randomize());
            drive_signals();
            -> pass_inputs;
        end
        
        test_finished = 1;
    end

    // Reset task
    task apply_reset();
        if_tb.rst_n = 0;
        @(negedge if_tb.clk);
        if_tb.rst_n = 1;
    endtask

    // Drive signals to interface
    task drive_signals();
        if_tb.rst_n = trans_obj.rst_n;
        if_tb.wr_en = trans_obj.wr_en;
        if_tb.rd_en = trans_obj.rd_en;
        if_tb.data_in = trans_obj.data_in;
    endtask

endmodule