`timescale 1ns/1ps

module button_sync (
    input  wire clk,
    input  wire rstb,   // active-low reset
    input  wire bi,     // button input
    output wire bo      // one-cycle pulse output
);
    // State encoding
    localparam [1:0]
        S_IDLE  = 2'b00,  // waiting for press
        S_PULSE = 2'b01,  // emit pulse (exactly one clock)
        S_WAIT  = 2'b10;  // waiting for release

    reg [1:0] state, next_state;

    // Moore output: 1 only in PULSE state
    assign bo = (state == S_PULSE);

    // State register (SEQUENTIAL PART) — non-blocking
    always @(posedge clk or negedge rstb) begin
        if (!rstb)
            state <= S_IDLE;
        else
            state <= next_state;
    end

    // Next-state logic (COMBINATIONAL PART)
    always @* begin
        case (state)
            S_IDLE: begin
                if (bi)
                    next_state = S_PULSE;   // first cycle of press
                else
                    next_state = S_IDLE;
            end

            S_PULSE: begin
                // we've already output bo=1 this cycle
                if (bi)
                    next_state = S_WAIT;    // still held, wait for release
                else
                    next_state = S_IDLE;    // short press, already released
            end

            S_WAIT: begin
                if (bi)
                    next_state = S_WAIT;    // still pressed, ignore
                else
                    next_state = S_IDLE;    // released, ready for next press
            end

            default: next_state = S_IDLE;
        endcase
    end

endmodule
