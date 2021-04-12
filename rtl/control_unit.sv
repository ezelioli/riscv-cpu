module control_unit import riscv_cpu_pkg::*;
#(
) (
  input  logic clk_i,
  input  logic rst_ni,

  input  logic [31:0] instr_i,

  output logic data_a_mux_o,
  output logic data_b_mux_o,
  output logic imm_mux_o,
  output logic alu_op_o,
  output logic [ADDR_WIDTH-1:0] reg_raddr_a_o,
  output logic [ADDR_WIDTH-1:0] reg_raddr_b_o,
  output logic            [1:0] pc_mux_o,
  output logic            [1:0] branch_mux_o,
  output logic                  jal_op_o
);

  logic [6:0] opcode;
  logic [2:0] funct3;

  assign opcode = instr_i[OP_MSB:OP_LSB];
  assign funct3 = instr_i[FUNCT_MSB:FUNCT_LSB];

  assign reg_raddr_a_o    = instr_i[REG_S1_MSB:REG_S1_LSB];
  assign reg_raddr_b_o    = instr_i[REG_S2_MSB:REG_S2_LSB];

  // instruction decoder //
  always_comb begin
    data_a_mux_o = 1'b0;
    data_b_mux_o = 1'b0;
    imm_mux_o    = 1'b0;
    alu_op_o     = 1'b0;
    pc_mux_o     = CU_PC_NEXT;
    branch_mux_o = NO_BRANCH;
    jal_op_o     = 1'b0;

    unique case(opcode)
      OPCODE_LUI:
        ;
      OPCODE_AUIPC:
        ;
      OPCODE_JAL:       // Jump And Link
        jal_op_o = 1'b1;
      OPCODE_JALR:      // Jump And Link Register
        jal_op_o = 1'b1;
      OPCODE_BRANCH:    // Branch
        unique case(funct3)
          BEQ:     branch_mux_o = BRANCH_IF_EQUAL;
          BNE:     branch_mux_o = BRANCH_IF_EQUAL_N;
          default: branch_mux_o = NO_BRANCH;
        endcase
      OPCODE_LOAD:
        ;
      OPCODE_STORE:
        ;
      OPCODE_OP_IMM:
        ;
      OPCODE_OP:
        ;
      OPCODE_MISC_MEM:
        ;
      OPCODE_SYSTEM:
        ;
      default:
        ;
    endcase // opcode
  end

endmodule : control_unit