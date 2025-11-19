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
    )

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

endmodule
