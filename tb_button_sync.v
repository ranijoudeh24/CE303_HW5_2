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

    // Reference model: one-shot behavior
    reg pressed;
    reg expected_bo;

    // Clock: 1 ns period
    initial begin
        clk = 1'b0;
        forever #0.5 clk = ~clk;
    end

    // Stimulus: several presses of different lengths
    initial begin
        rstb = 1'b0;
        bi   = 1'b0;
        #3;
        rstb = 1'b1;

        // Press 1: long press (3 cycles high)
        repeat (3) @(posedge clk);
        bi = 1'b1;
        repeat (3) @(posedge clk);
        bi = 1'b0;

        repeat (4) @(posedge clk);

        // Press 2: longer press (5 cycles high)
        bi = 1'b1;
        repeat (5) @(posedge clk);
        bi = 1'b0;

        repeat (4) @(posedge clk);

        // Press 3: short press (1 cycle high)
        bi = 1'b1;
        @(posedge clk);
        bi = 1'b0;

        repeat (6) @(posedge clk);
        $display("Simulation finished with no mismatches.");
        $finish;
    end

    // Reference logic + checker (uses non-blocking for regs)
    always @(posedge clk or negedge rstb) begin
        if (!rstb) begin
            pressed     <= 1'b0;
            expected_bo <= 1'b0;
        end else begin
            // expected one-cycle pulse on first cycle of a press
            if (!pressed && bi)
                expected_bo <= 1'b1;
            else
                expected_bo <= 1'b0;

            // track “inside a press”
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
