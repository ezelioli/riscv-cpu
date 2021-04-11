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
  output logic pc_mux_o
);

  logic [6:0] opcode;

  assign opcode = instr_i[OP_MSB:OP_LSB];

  assign alu_op_o         = 0';
  assign reg_raddr_a_o    = instr_i[REG_S1_MSB:REG_S1_LSB];
  assign reg_raddr_b_o    = instr_i[REG_S2_MSB:REG_S2_LSB];

  // instruction decoder //
  always_comb begin
    data_a_mux_o = 1'b0;
    data_b_mux_o = 1'b0;
    imm_mux_o    = 1'b0;
    alu_op_o     = 1'b0;
    pc_mux_o     = 1'b0;

    unique case(opcode)
      OPCODE_JAL:
        pc_mux_o = 1'b1;
      default:
        data_b_mux_o = 1'b0;
    endcase // opcode
  end

endmodule : control_unit