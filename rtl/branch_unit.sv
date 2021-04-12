module branch_unit import riscv_cpu_pkg::*;
(
  input  logic clk_i,
  input  logic rst_ni,

  input  logic branch_taken_i,

  output logic pc_mux_o
);
  
  always_comb begin
    pc_mux_o = branch_taken_i;
  end

endmodule : branch_unit