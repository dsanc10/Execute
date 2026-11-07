
`timescale 1ns / 1ps

module top_mux (
    input wire [31:0] a, b,
    input wire alusrc,
    output wire [31:0] y
);

    assign y = alusrc ? a : b;

endmodule
