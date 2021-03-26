module alu import riscv_cpu_pkg::*;
#(
) (
  input  logic  [DATA_WIDTH-1:0] data_a_i,
  input  logic  [DATA_WIDTH-1:0] data_b_i,
  input  logic                   op_i,

  output logic  [DATA_WIDTH-1:0] data_o,
  output logic  [CSR_WIDTH-1:0]  csr_o
);

assign data_o = 0';
assign csr_o  = 0';

endmodule : alu