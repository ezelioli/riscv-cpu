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

  input  logic                    branch_taken_i,
  input  logic                    clear_ex_i,

  // EX pipeline stage interface
  input  id2ex_t                 ex_pipeline_i,
  
  // Output of EX pipeline stage
  output ex2mem_t                mem_pipeline_o,

  // Data from next stages of pipeline
  input  logic [DATA_WIDTH-1:0] alu_result_i,
  input  logic [DATA_WIDTH-1:0] mem_data_i,

  // From forwarding unit
  input logic  [ALU_DATA_A_MUX_WIDTH-1:0] alu_data_a_mux_i,
  input logic  [ALU_DATA_B_MUX_WIDTH-1:0] alu_data_b_mux_i,

  // To forwarding unit
  output logic  [ADDR_WIDTH-1:0] reg_raddr_a_o,
  output logic  [ADDR_WIDTH-1:0] reg_raddr_b_o,
  output logic                   data_a_reg_o,
  output logic                   data_b_reg_o,
  output logic  [ADDR_WIDTH-1:0] dest_reg_o,
  output logic                   reg_we_o
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

  assign reg_raddr_a_o = ex_pipeline_i.reg_raddr_a;
  assign reg_raddr_b_o = ex_pipeline_i.reg_raddr_b;
  assign data_a_reg_o  = ex_pipeline_i.data_a_reg;
  assign data_b_reg_o  = ex_pipeline_i.data_b_reg;

  assign alu_op     = ex_ctl_i.alu_op;

  assign mem_pipeline_d.pc          = (branch_taken_i == 1'b0 && clear_ex_i == 1'b0) ? ex_pipeline_i.pc : '0;
  assign mem_pipeline_d.branch_addr = (branch_taken_i == 1'b0 && clear_ex_i == 1'b0) ? ex_pipeline_i.branch_addr : '0;
  assign mem_pipeline_d.mem_wdata   = (branch_taken_i == 1'b0 && clear_ex_i == 1'b0) ? ex_pipeline_i.mem_wdata : 32'b0;
  assign mem_pipeline_d.dest_reg    = (branch_taken_i == 1'b0 && clear_ex_i == 1'b0) ? ex_pipeline_i.dest_reg : '{ADDR_WIDTH{1'b0}};
  assign mem_pipeline_d.alu_result  = (branch_taken_i == 1'b0 && clear_ex_i == 1'b0) ? alu_result : 32'b0;

  assign mem_ctl_d = (branch_taken_i == 1'b0 && clear_ex_i == 1'b0) ? mem_ctl_i : '{NO_BRANCH, 1'b0};
  assign wb_ctl_d  = (branch_taken_i == 1'b0 && clear_ex_i == 1'b0) ? wb_ctl_i  : '{1'b0, WDATA_ALU};

  always_comb begin
    unique case(alu_data_a_mux_i)
      ALU_DATA_A_REG: alu_data_a = ex_pipeline_i.alu_data_a;
      ALU_DATA_A_MEM: alu_data_a = alu_result_i;
      ALU_DATA_A_WB : alu_data_a = mem_data_i;
    endcase
    unique case(alu_data_b_mux_i)
      ALU_DATA_B_REG: alu_data_b = ex_pipeline_i.alu_data_b;
      ALU_DATA_B_MEM: alu_data_b = alu_result_i;
      ALU_DATA_B_WB : alu_data_b = mem_data_i;
    endcase
  end

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
  assign dest_reg_o     = ex_pipeline_i.dest_reg;
  assign reg_we_o       = wb_ctl_i.reg_we;

endmodule : ex_stage