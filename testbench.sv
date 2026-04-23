module top_tb();

    reg clk;
    reg reset;
    
    // Instantiate the processor
    top_riscv dut (
        .clk(clk),
        .reset(reset)
    );

    // Clock generation (20ns period)
    initial begin
        clk = 0;
        forever #10 clk = ~clk; 
    end

    // Simulation Control and Waveform Enable
    initial begin
        // --- Waveform Enable Block ---
        $dumpfile("dump.vcd"); // Create waveform file
        $dumpvars(0, top_tb);  // Dump all signals

        // --- Reset Logic ---
        reset = 1'b1;
        #100;          // Hold reset high to initialize memory
        reset = 1'b0;

        // --- Run Simulation ---
        #1000;         // Run for 2000ns
        $display("Simulation Finished Successfully.");
        $finish;       // Stops the simulation
    end

    // Monitor key signals in the console
    initial begin
        $monitor("Time=%0t | PC=%h | Instruction=%h | ALU_Result=%h", 
                 $time, dut.pc, dut.instruction_out, dut.dpu.write_data_alu);
    end

endmodule
