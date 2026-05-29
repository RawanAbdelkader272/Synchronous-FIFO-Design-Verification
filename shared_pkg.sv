package shared_pkg;
    // Synchronization event
    event pass_inputs;
    
    // Scorekeeping variables
    int error_count = 0;
    int correct_count = 0;
    
    // Test control
    bit test_finished = 0;
endpackage