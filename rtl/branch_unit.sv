module branch_unit import riscv_cpu_pkg::*;
#(
) (
  input  logic clk_i,
  input  logic rst_ni,

  input  logic [31:0] pc_i,
  input  logic [CSR_WIDTH-1:0] csr_i,
  output logic taken_o
);
  
  assign taken _o= 0';

endmodule