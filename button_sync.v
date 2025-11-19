`timescale 1ns/1ps

module button_sync (
    input  wire clk,
    input  wire rstb,   // active-low reset
    input  wire bi,     // raw button input
    output wire bo      // one-cycle pulse
);
    // State encoding
    localparam [1:0]
        S_IDLE  = 2'b00,  // waiting for bi=0→1
        S_PULSE = 2'b01,  // output 1 for exactly one clock
        S_WAIT  = 2'b10;  // waiting for bi to go back to 0

    reg [1:0] state;

    // Moore output: bo = 1 only in PULSE state
    assign bo = (state == S_PULSE);

    // State register + next-state logic
    always @(posedge clk or negedge rstb) begin
        if (!rstb) begin
            state <= S_IDLE;
        end else begin
            case (state)
                S_IDLE: begin
                    if (bi)
                        state <= S_PULSE;  // first detection of press
                    else
                        state <= S_IDLE;
                end

                S_PULSE: begin
                    // we already output 1 this cycle; go next
                    if (bi)
                        state <= S_WAIT;   // button still held
                    else
                        state <= S_IDLE;   // short press, released
                end

                S_WAIT: begin
                    if (bi)
                        state <= S_WAIT;   // still pressed; ignore
                    else
                        state <= S_IDLE;   // released; ready for next press
                end

                default: state <= S_IDLE;
            endcase
        end
    end

endmodule
