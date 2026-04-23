module imm_gen(
    input  [31:0] instr_memory,
    output reg [31:0] imm_val_r
);

    wire [6:0] opcode = instr_memory[6:0];

    always @(*) begin
        imm_val_r = 32'b0;  // default

        case (opcode)
            7'b0010011: // I-type ALU
                imm_val_r = {{20{instr_memory[31]}}, instr_memory[31:20]};

            7'b0000011: // LOAD
                imm_val_r = {{20{instr_memory[31]}}, instr_memory[31:20]};

            default:
                imm_val_r = 32'b0;
        endcase
    end

endmodule
