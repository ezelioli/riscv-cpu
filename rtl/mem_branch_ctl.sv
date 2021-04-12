module mem_branch_ctl import riscv_cpu_pkg::*;
#(
) (
  input  logic                 clk_i,
  input  logic                 rst_ni,

  input  logic          [31:0] pc_i,
  input  logic [CSR_WIDTH-1:0] csr_i,
  input  logic                 jmp_mux_i,

  output logic                 taken_o
);
  
  always_comb begin
    taken_o = 1'b0;
    unique case(jmp_mux_i)
      1'b0: taken_o = 1'b0;
      1'b1: taken_o = 1'b1;
    endcase // jmp_mux_i
  end

endmodule