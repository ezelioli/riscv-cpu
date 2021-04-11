module wb_stage import riscv_cpu_pkg::*;
#(
) (
  input  logic                   clk_i,
  input  logic                   rst_ni,

  // WB pipeline stage interface
  input  logic            [31:0] instr_rdata_i,
  input  logic  [DATA_WIDTH-1:0] alu_result_i,
  input  logic  [DATA_WIDTH-1:0] mem_data_i,

  // Output signals of WB pipeline stage
  output logic  [DATA_WIDTH-1:0] wdata_o,
  output logic  [ADDR_WIDTH-1:0] dest_reg_o,
  output logic                   we_o

);

  assign wdata_o      = 0';
  assign dest_reg_o   = 0';
  assign we_o         = 0';

endmodule : wb_stage