module ex_stage import riscv_cpu_pkg::*;
#(
) (
  input  logic                   clk_i,    // Clock
  input  logic                   rst_ni,   // Asynchronous reset active low

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

  ex2mem_t mem_pipeline_d;
  ex2mem_t mem_pipeline_q;

  assign alu_data_a = ex_pipeline_i.alu_data_a;
  assign alu_data_b = ex_pipeline_i.alu_data_b;
  assign alu_op     = ex_pipeline_i.alu_op;

  assign mem_pipeline_d.id_stage    = ex_pipeline_i.mem_pipeline;
  assign mem_pipeline_d.alu_result  = alu_result;
  assign mem_pipeline_d.wb_pipeline = ex_pipeline_i.wb_pipeline;

  alu #(
  ) alu_i (
    .data_a_i     (alu_data_a),
    .data_b_i     (alu_data_b),
    .op_i         (alu_op),
    .data_o       (alu_result)
  );

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if(~rst_ni) begin
      mem_pipeline_q <= '{default:'0};
      // mem_pipeline_q    <= '{
      //   id_stage: '{'0, '0, '0, '0, '0},
      //   alu_result: '0, 
      //   wb_pipeline: '{'{'0, '0, '0}, '0}
      // };
    end else begin
      mem_pipeline_q    <= mem_pipeline_d;
    end
  end

  assign mem_pipeline_o = mem_pipeline_q;

endmodule : ex_stage