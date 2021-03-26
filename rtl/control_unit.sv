module control_unit import riscv_cpu_pkg::*;
#(
) (
  input  logic clk_i,
  input  logic rst_ni,

  input  logic [31:0] instr_i,

  output logic data_a_mux_o,
  output logic data_b_mux_o,
  output logic alu_op_o,
  output logic [ADDR_WIDTH-1:0] reg_raddr_a_o,
  output logic [ADDR_WIDTH-1:0] reg_raddr_b_o,
  output logic [ADDR_WIDTH-1:0] reg_waddr_a_o,
  output logic [ADDR_WIDTH-1:0] reg_we_a_o
);

  assign data_a_mux_o = 0';
  assign data_b_mux_o = 0';
  assign alu_op_o     = 0';
  assign reg_waddr_a_o = 0';
  assign reg_waddr_b_o = 0';
  assign reg_waddr_a_o = 0';
  assign reg_we_a_o = 0';

endmodule : control_unit