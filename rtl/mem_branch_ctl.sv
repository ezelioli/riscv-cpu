module mem_branch_ctl import riscv_cpu_pkg::*;
#(
) (
  input  logic                  clk_i,
  input  logic                  rst_ni,

  input  logic           [31:0] pc_i,
  input  logic [DATA_WIDTH-1:0] alu_result_i,
  input  logic            [1:0] branch_mux_i,

  output logic                  taken_o
);

  logic flag_zero = (alu_result_i == 0) ? 1'b1 : 1'b0;
  logic flag_sign = alu_result_i[31];
  
  always_comb begin
    taken_o = 1'b0;
    unique case(branch_mux_i)
      NO_BRANCH:          taken_o = 1'b0;
      BRANCH_IF_EQUAL:    taken_o = flag_zero;
      BRANCH_IF_EQUAL_N:  taken_o = ~flag_zero;
      BRANC_IF_SIGN:      taken_o = flag_sign;
    endcase // branch_mux_i
  end

endmodule