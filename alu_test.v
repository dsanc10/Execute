
`timescale 1ns / 1ps

module alu_test;

    reg [31:0] a;
    reg [31:0] b;
    reg [2:0] control;

    wire [31:0] result;
    wire zero;

    alu uut (
        .a(a),
        .b(b),
        .control(control),
        .result(result),
        .zero(zero)
    );

    initial begin
        a = 32'd10;
        b = 32'd7;
        control = 3'b010;

        #10;
        control = 3'b110;

        #10;
        control = 3'b000;

        #10;
        control = 3'b001;

        #10;
        control = 3'b111;

        #10;
        a = 32'd7;
        b = 32'd10;

        #10;
        a = 32'd10;
        b = 32'd10;
        control = 3'b110;

        #10;
        $finish;
    end

endmodule
