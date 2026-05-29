module top;
    bit clk;

    // Interface instance
    IF top_if(clk);

    // Module instances
    FIFO dut(top_if.DUT);
    monitor mon(top_if.TB);
    tb testbench(top_if.TB);

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Simulation timeout
    initial begin
        #1000000;
        $display("Simulation timeout");
        $finish;
    end

endmodule