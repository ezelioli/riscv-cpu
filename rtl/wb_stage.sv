module wb_stage import riscv_cpu_pkg::*;
#(
) (
  input  logic                   clk_i,
  input  logic                   rst_ni,

  // Pipelined control signals
  input  wb_ctl_t                wb_ctl_i,

  // WB pipeline stage interface
  input  mem2wb_t                wb_pipeline_i,

  // Output signals of WB pipeline stage
  output logic  [DATA_WIDTH-1:0] wdata_o,
  output logic  [ADDR_WIDTH-1:0] dest_reg_o,
  output logic                   we_o

);
  
  // internal signals
  logic                        reg_we;
  logic  [WDATA_MUX_WIDTH-1:0] wdata_mux;
  logic       [ADDR_WIDTH-1:0] dest_reg;
  logic       [DATA_WIDTH-1:0] alu_result;
  logic       [DATA_WIDTH-1:0] mem_data;

  assign reg_we       = wb_ctl_i.reg_we;
  assign wdata_mux    = wb_ctl_i.wdata_mux;
  
  assign dest_reg     = wb_pipeline_i.dest_reg;
  assign alu_result   = wb_pipeline_i.alu_result;
  assign mem_data     = wb_pipeline_i.mem_data;

  // wdata multiplexing
  always_comb begin
    wdata_o = alu_result;
    unique case(wdata_mux)
      WDATA_ALU: wdata_o = alu_result;
      WDATA_MEM: wdata_o = mem_data;
      default: wdata_o = alu_result;
    endcase
  end

  assign dest_reg_o   = dest_reg;
  assign we_o         = reg_we;

endmodule : wb_stage