
`timescale 1ns / 1ps

module alu_control_test;

    reg [1:0] alu_op;
    reg [5:0] funct;
    wire [2:0] select;

    alu_control uut (
        .funct(funct),
        .aluop(alu_op),
        .select(select)
    );

    initial begin
        alu_op = 2'b00;
        funct = 6'b000000;

        #10;
        alu_op = 2'b01;

        #10;
        alu_op = 2'b10;
        funct = 6'b100000;

        #10;
        funct = 6'b100010;

        #10;
        funct = 6'b100100;

        #10;
        funct = 6'b100101;

        #10;
        funct = 6'b101010;

        #10;
        $finish;
    end

endmodule
