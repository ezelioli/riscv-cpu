module ex_stage import riscv_cpu_pkg::*;
#(
) (
  input  logic                   clk_i,    // Clock
  input  logic                   rst_ni,   // Asynchronous reset active low

  // Pipelined control
  input  ex_ctl_t                 ex_ctl_i,
  input  mem_ctl_t                mem_ctl_i,
  input  wb_ctl_t                 wb_ctl_i,

  output mem_ctl_t                mem_ctl_o,
  output wb_ctl_t                 wb_ctl_o,

  // EX pipeline stage interface
  input  id2ex_t                 ex_pipeline_i,
  
  // Output of EX pipeline stage
  output ex2mem_t                mem_pipeline_o
);

  //internal signals
  logic  [DATA_WIDTH-1:0] alu_data_a;
  logic  [DATA_WIDTH-1:0] alu_data_b;
  logic  [ALU_OP_WIDTH-1:0] alu_op;

  logic [DATA_WIDTH-1:0] alu_result;

  mem_ctl_t mem_ctl_d;
  mem_ctl_t mem_ctl_q;

  wb_ctl_t wb_ctl_d;
  wb_ctl_t wb_ctl_q;

  ex2mem_t mem_pipeline_d;
  ex2mem_t mem_pipeline_q;

  assign alu_data_a = ex_pipeline_i.alu_data_a;
  assign alu_data_b = ex_pipeline_i.alu_data_b;

  assign alu_op     = ex_ctl_i.alu_op;

  assign mem_pipeline_d.pc          = ex_pipeline_i.pc;
  assign mem_pipeline_d.branch_addr = ex_pipeline_i.branch_addr;
  assign mem_pipeline_d.mem_wdata   = ex_pipeline_i.mem_wdata;
  assign mem_pipeline_d.dest_reg    = ex_pipeline_i.dest_reg;
  assign mem_pipeline_d.alu_result  = alu_result;

  assign mem_ctl_d = mem_ctl_i;
  assign wb_ctl_d  = wb_ctl_i;

  alu #(
  ) alu_i (
    .data_a_i     (alu_data_a),
    .data_b_i     (alu_data_b),
    .op_i         (alu_op),
    .data_o       (alu_result)
  );

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if(~rst_ni) begin
      mem_ctl_q      <= '{default: '0};
      wb_ctl_q       <= '{default: '0};
      mem_pipeline_q <= '{default: '0};
    end else begin
      mem_ctl_q         <= mem_ctl_d;
      wb_ctl_q          <= wb_ctl_d;
      mem_pipeline_q    <= mem_pipeline_d;
    end
  end

  assign mem_ctl_o      = mem_ctl_q;
  assign wb_ctl_o       = wb_ctl_q;
  assign mem_pipeline_o = mem_pipeline_q;

endmodule : ex_stage