`include "instruction_fetch_unit.sv"
`include "instructionmemory.sv"
`include "controlunit.sv"
`include "imm_gen.sv"
`include "data_path.sv"

module top_riscv(
    input clk,
    input reset
);

    // ================= IF =================
    wire [31:0] pc;
    wire [31:0] instruction_out;
    wire [31:0] pc_plus4;

    // ================= IF/ID =================
    reg [31:0] IF_ID_instr;
    reg [31:0] IF_ID_pc_plus4;

    // ================= ID =================
    wire [5:0]  alu_control;
    wire        mem_to_reg;
    wire        beq_control, bne_control, bgeq_control, blt_control;
    wire        jump, lb, sw, lui_control;
    wire [31:0] imm_val_r;
    wire [31:0] imm_val_lui;

    // Branch feedback
    wire beq, bneq, bge, blt;

    // ================= IF STAGE =================
    instruction_fetch_unit ifu (
        .clk(clk),
        .reset(reset),
        .imm_address(imm_val_r),
        .imm_address_jump(imm_val_r),
        .beq(beq),
        .bneq(bneq),
        .bge(bge),
        .blt(blt),
        .jump(jump),
        .pc(pc),
        .pc_plus4(pc_plus4)
    );

    instruction_memory im (
        .clk(clk),
        .pc(pc),
        .reset(reset),
        .instruction_code(instruction_out)
    );

    // ================= IF/ID REGISTER =================
    always @(posedge clk) begin
        if (reset) begin
            IF_ID_instr    <= 32'b0;
            IF_ID_pc_plus4 <= 32'b0;
        end else begin
            IF_ID_instr    <= instruction_out;
            IF_ID_pc_plus4 <= pc_plus4;
        end
    end

    // ================= ID STAGE =================
    control_unit cu (
        .reset(reset),
        .opcode(IF_ID_instr[6:0]),
        .funct3(IF_ID_instr[14:12]),
        .funct7(IF_ID_instr[31:25]),
        .alu_control(alu_control),
        .lb(lb),
        .mem_to_reg(mem_to_reg),
        .beq_control(beq_control),
        .bneq_control(bne_control),
        .bgeq_control(bgeq_control),
        .blt_control(blt_control),
        .jump(jump),
        .sw(sw),
        .lui_control(lui_control)
    );

    imm_gen ig (
        .instr_memory(IF_ID_instr),
        .imm_val_r(imm_val_r)
    );

    // ================= DATAPATH =================
    data_path dpu (
        .clk(clk),
        .rst(reset),

        // instruction fields
        .read_reg_num1(IF_ID_instr[19:15]),
        .read_reg_num2(IF_ID_instr[24:20]),
        .write_reg_num1(IF_ID_instr[11:7]),

        // control
        .alu_control(alu_control),
        .jump(jump),
        .beq_control(beq_control),
        .bne_control(bne_control),
        .bgeq_control(bgeq_control),
        .blt_control(blt_control),
        .lb(lb),
        .sw(sw),
        .lui_control(lui_control),
        .mem_to_reg(mem_to_reg),

        // immediates
        .imm_val(imm_val_r),
        .imm_val_lui(imm_val_lui),

        // branch feedback
        .beq(beq),
        .bneq(bneq),
        .bge(bge),
        .blt(blt)
    );

endmodule
