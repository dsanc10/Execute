
`timescale 1ns / 1ps

module bottom_mux (
    input wire [4:0] a,
    input wire [4:0] b,
    input wire sel,
    output wire [4:0] y
);

    assign y = sel ? a : b;

endmodule
