module branch_unit import riscv_cpu_pkg::*;
(
  input  logic clk_i,
  input  logic rst_ni,

  input  logic branch_taken_i,
  input  logic jal_op_i,

  output logic [BU_MUX_WIDTH-1:0] pc_mux_o
);
  
  always_comb begin
    pc_mux_o = BU_PC_NEXT;
    if(branch_taken_i) begin
      pc_mux_o = BU_PC_BRANCH;
    end else if(jal_op_i) begin
      pc_mux_o = BU_PC_JAL;
    end
  end

endmodule : branch_unit