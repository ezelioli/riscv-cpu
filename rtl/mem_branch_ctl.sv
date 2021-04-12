module mem_branch_ctl import riscv_cpu_pkg::*;
#(
) (
  input  logic                 clk_i,
  input  logic                 rst_ni,

  input  logic          [31:0] pc_i,
  input  logic [CSR_WIDTH-1:0] csr_i,
  input  logic           [1:0] branch_mux_i,

  output logic                 taken_o
);

  logic csr_zero = csr_i[CSR_ZERO];
  logic csr_sign = csr_i[CSR_SIGN];
  
  always_comb begin
    taken_o = 1'b0;
    unique case(branch_mux_i)
      NO_BRANCH:          taken_o = 1'b0;
      BRANCH_IF_EQUAL:    taken_o = csr_zero;
      BRANCH_IF_EQUAL_N:  taken_o = ~csr_zero;
      BRANC_IF_SIGN:      taken_o = csr_sign;
      default:            taken_o = 1'b0;
    endcase // branch_mux_i
  end

endmodule