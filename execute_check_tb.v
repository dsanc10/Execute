
`timescale 1ns / 1ps

module execute_check_tb;

    reg clk = 0;
    always #5 clk = ~clk;

    reg [1:0] ctlwb_in;
    reg [2:0] ctlm_in;
    reg [31:0] npc, rdata1, rdata2, s_extend;
    reg [4:0] instr_2016, instr_1511;
    reg [1:0] alu_op;
    reg [5:0] funct;
    reg alusrc, regdst;

    wire [1:0] ctlwb_out;
    wire [2:0] ctlm_out;
    wire [31:0] adder_out, alu_result_out, rdata2_out;
    wire [4:0] muxout_out;

    integer errors = 0;

    execute dut (
        .clk(clk),
        .ctlwb_in(ctlwb_in),
        .ctlm_in(ctlm_in),
        .npc(npc),
        .rdata1(rdata1),
        .rdata2(rdata2),
        .s_extend(s_extend),
        .instr_2016(instr_2016),
        .instr_1511(instr_1511),
        .alu_op(alu_op),
        .funct(funct),
        .alusrc(alusrc),
        .regdst(regdst),
        .ctlwb_out(ctlwb_out),
        .ctlm_out(ctlm_out),
        .adder_out(adder_out),
        .alu_result_out(alu_result_out),
        .rdata2_out(rdata2_out),
        .muxout_out(muxout_out)
    );

    task run_case;
        input [8*20-1:0] case_name;
        input [31:0] expected_alu;
        input [4:0] expected_reg;

        begin
            @(posedge clk);
            #1;

            if (alu_result_out !== expected_alu ||
                adder_out !== (npc + s_extend) ||
                rdata2_out !== rdata2 ||
                muxout_out !== expected_reg ||
                ctlwb_out !== ctlwb_in ||
                ctlm_out !== ctlm_in) begin

                $display("FAIL %0s: ALU=%h expected=%h ADD=%h REG=%d WB=%b MEM=%b",
                         case_name, alu_result_out, expected_alu,
                         adder_out, muxout_out, ctlwb_out, ctlm_out);

                errors = errors + 1;
            end
            else begin
                $display("PASS %0s: ALU=%h ADD=%h REG=%d WB=%b MEM=%b",
                         case_name, alu_result_out, adder_out,
                         muxout_out, ctlwb_out, ctlm_out);
            end

            @(negedge clk);
        end
    endtask

    initial begin
        ctlwb_in = 2'b10;
        ctlm_in = 3'b010;

        npc = 100;
        rdata1 = 10;
        rdata2 = 20;
        s_extend = 4;

        instr_2016 = 5;
        instr_1511 = 10;

        alu_op = 2'b00;
        funct = 0;
        alusrc = 1;
        regdst = 0;

        run_case("LW", 14, 5);

        ctlwb_in = 2'b00;
        ctlm_in = 3'b001;
        alu_op = 2'b00;
        alusrc = 1;
        regdst = 0;

        run_case("SW", 14, 5);

        ctlwb_in = 2'b00;
        ctlm_in = 3'b100;
        rdata1 = 20;
        rdata2 = 20;
        alu_op = 2'b01;
        alusrc = 0;
        regdst = 0;

        run_case("BEQ", 0, 5);

        if (dut.pipeline_register.zero !== 1'b1) begin
            $display("FAIL BEQ: Zero should be 1");
            errors = errors + 1;
        end

        ctlwb_in = 2'b10;
        ctlm_in = 3'b000;

        rdata1 = 10;
        rdata2 = 7;

        alu_op = 2'b10;
        alusrc = 0;
        regdst = 1;

        funct = 6'b100000;
        run_case("R-ADD", 17, 10);

        funct = 6'b100010;
        run_case("R-SUB", 3, 10);

        funct = 6'b100100;
        run_case("R-AND", 2, 10);

        funct = 6'b100101;
        run_case("R-OR", 15, 10);

        funct = 6'b101010;
        run_case("R-SLT false", 0, 10);

        rdata1 = 7;
        rdata2 = 10;
        run_case("R-SLT true", 1, 10);

        if (errors == 0)
            $display("EXECUTE STAGE: ALL TESTS PASSED");
        else
            $display("EXECUTE STAGE: %0d FAILURE(S)", errors);

        $finish;
    end

endmodule
