`timescale 1ns/1ps

module tb_button_sync;
    reg clk;
    reg rstb;
    reg bi;
    wire bo;

    // DUT
    button_sync dut (
        .clk (clk),
        .rstb(rstb),
        .bi  (bi),
        .bo  (bo)
    );

    // Reference model: ideal one-shot behavior
    reg pressed;        // 1 while we are inside a press
    reg expected_bo;

    initial begin
        clk = 1'b0;
        forever #0.5 clk = ~clk;  // 1 ns period = 1 GHz
    end

    // Stimulus: multiple button presses of various lengths
    initial begin
        rstb = 1'b0;
        bi   = 1'b0;
        #3;              // hold reset low for a few ns
        rstb = 1'b1;

        // Press 1: long press, 3 cycles
        repeat (3) @(posedge clk);
        bi = 1'b1;
        repeat (3) @(posedge clk);
        bi = 1'b0;

        // Wait a bit
        repeat (4) @(posedge clk);

        // Press 2: longer press, 5 cycles
        bi = 1'b1;
        repeat (5) @(posedge clk);
        bi = 1'b0;

        // Wait again
        repeat (4) @(posedge clk);

        // Press 3: short press, 1 cycle
        bi = 1'b1;
        @(posedge clk);
        bi = 1'b0;

        // Run a few more cycles then finish
        repeat (6) @(posedge clk);
        $display("Simulation finished without mismatches.");
        $finish;
    end

    // Reference one-shot logic and checker
    always @(posedge clk or negedge rstb) begin
        if (!rstb) begin
            pressed     <= 1'b0;
            expected_bo <= 1'b0;
        end else begin
            // expected one-cycle pulse when bi rises while not pressed
            if (!pressed && bi)
                expected_bo <= 1'b1;
            else
                expected_bo <= 1'b0;

            // track if we're inside a press
            if (bi)
                pressed <= 1'b1;
            else
                pressed <= 1'b0;

            // compare DUT vs reference
            if (bo !== expected_bo) begin
                $display("Mismatch at time %0t: bi=%b bo=%b expected=%b",
                         $time, bi, bo, expected_bo);
                $stop;
            end
        end
    end

endmodule
