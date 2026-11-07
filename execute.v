
`timescale 1ns / 1ps

module execute (
    input wire clk,
    input wire [1:0] ctlwb_in,
    input wire [2:0] ctlm_in,
    input wire [31:0] npc, rdata1, rdata2, s_extend,
    input wire [4:0] instr_2016, instr_1511,
    input wire [1:0] alu_op,
    input wire [5:0] funct,
    input wire alusrc, regdst,

    output wire [1:0] ctlwb_out,
    output wire [2:0] ctlm_out,
    output wire [31:0] adder_out, alu_result_out, rdata2_out,
    output wire [4:0] muxout_out
);

    wire [31:0] branch_address;
    wire [31:0] alu_b;
    wire [31:0] alu_result;
    wire alu_zero;
    wire [2:0] alu_select;
    wire [4:0] selected_register;
    wire branch_latched, memread_latched, memwrite_latched;

    assign ctlm_out = {branch_latched, memread_latched, memwrite_latched};

    adder branch_adder (
        .add_in1(npc),
        .add_in2(s_extend),
        .add_out(branch_address)
    );

    top_mux alu_source_mux (
        .a(s_extend),
        .b(rdata2),
        .alusrc(alusrc),
        .y(alu_b)
    );

    alu_control control_decoder (
        .funct(funct),
        .aluop(alu_op),
        .select(alu_select)
    );

    alu arithmetic_unit (
        .a(rdata1),
        .b(alu_b),
        .control(alu_select),
        .result(alu_result),
        .zero(alu_zero)
    );

    bottom_mux register_destination_mux (
        .a(instr_1511),
        .b(instr_2016),
        .sel(regdst),
        .y(selected_register)
    );

    ex_mem pipeline_register (
        .clk(clk),
        .ctlwb_out(ctlwb_in),
        .ctlm_out(ctlm_in),
        .adder_out(branch_address),
        .aluzero(alu_zero),
        .aluout(alu_result),
        .readat2(rdata2),
        .muxout(selected_register),
        .wb_ctlout(ctlwb_out),
        .branch(branch_latched),
        .memread(memread_latched),
        .memwrite(memwrite_latched),
        .add_result(adder_out),
        .zero(),
        .alu_result(alu_result_out),
        .rdata2out(rdata2_out),
        .five_bit_muxout(muxout_out)
    );

endmodule
