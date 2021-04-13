module id_stage import riscv_cpu_pkg::*;
(
  input  logic                   clk_i,    // Clock
  input  logic                   rst_ni,   // Asynchronous reset active low

  // IF pipeline stage interface
  input  logic            [31:0] instr_rdata_i,
  input  logic            [31:0] pc_id_i,

  // Signals from WB pipeline stage
  input  logic  [DATA_WIDTH-1:0] waddr_a_i,
  input  logic  [DATA_WIDTH-1:0] wdata_a_i,
  input  logic                   we_a_i,

  // Control signals
  output logic             [1:0] pc_mux_o,
  output logic                   jal_op_o,

  // Output of ID pipeline stage
  output id2ex_t                 ex_pipeline_o
);

  ////////////////////////////////
  ////     REGISTER FILE      ////
  ////////////////////////////////
  logic  [ADDR_WIDTH-1:0] raddr_a;
  logic  [DATA_WIDTH-1:0] rdata_a;
  logic  [ADDR_WIDTH-1:0] raddr_b;
  logic  [DATA_WIDTH-1:0] rdata_b;
  logic  [ADDR_WIDTH-1:0] waddr_a;
  logic  [DATA_WIDTH-1:0] wdata_a;
  logic                   we_a;

  ////////////////////////////////
  ////     CONTROL UNIT       ////
  ////////////////////////////////
  logic data_a_mux;
  logic data_b_mux;
  logic imm_mux;
  logic alu_op;
  logic reg_raddr_a;
  logic reg_raddr_b;
  logic reg_we;
  logic [1:0] branch_mux;
  logic [WDATA_MUX_WIDTH-1:0] wdata_mux;

  logic [DATA_WIDTH-1:0] data_a;
  logic [DATA_WIDTH-1:0] data_b;
  logic [ADDR_WIDTH-1:0] dest_reg;

  id2mem_t mem_pipeline;
  id2wb_t  tb_pipeline;

  id2ex_t ex_pipeline_d;
  id2ex_t ex_pipeline_q;

  register_file #(
  ) register_file_i (
    .clk_i          (clk_i),
    .rst_ni         (rst_ni),
    .raddr_a_i      (raddr_a),
    .rdata_a_o      (rdata_a),
    .raddr_b_i      (raddr_b),
    .rdata_b_o      (rdata_b),
    .waddr_a_i      (waddr_a),
    .wdata_a_i      (wdata_a),
    .we_a_i         (we_a)
  );

  control_unit #(
  ) control_unit_i (
    .clk_i          (clk_i),
    .rst_ni         (rst_ni),
    .instr_i        (instr_rdata_i),
    .data_a_mux_o   (data_a_mux),
    .data_b_mux_o   (data_b_mux),
    .imm_mux_o      (imm_mux),
    .alu_op_o       (alu_op),
    .reg_raddr_a_o  (reg_raddr_a),
    .reg_raddr_b_o  (reg_raddr_b),
    .reg_we_o       (reg_we),
    .branch_mux_o   (branch_mux),
    .wdata_mux_o    (wdata_mux),
    .pc_mux_o       (pc_mux_o),
    .jal_op_o       (jal_op_o)
  );

  assign raddr_a          = reg_raddr_a;
  assign raddr_b          = reg_raddr_b;

  assign waddr_a          = waddr_a_i;
  assign wdata_a          = wdata_a_i;
  assign we_a             = we_a_i;

  assign dest_reg         = instr_rdata_i[REG_RD_MSB:REG_RD_LSB]; // always the same

  always_comb begin
    unique case(imm_mux)
      IMM_Z:  imm = '0;
      IMM_I:  imm = instr_i[IMM_MSB:IMM_LSB];
  end

  always_comb begin
    unique case(data_a_mux)
      OP_A_REG:   data_a = rdata_a;
      OP_A_IMM:   data_a = imm;
    endcase
    unique case(data_b_mux)
      OP_B_REG:    data_b = rdata_b;
      OP_B_IMM:    data_b = imm;
    endcase
  end

  assign mem_pipeline.pc            = pc_id_i;
  assign mem_pipeline.branch_mux    = branch_mux;
  assign mem_pipeline.branch_addr   = instr_i[JAL_MSB:JAL_LSB];  // to be changed to general address for all possible branches
  assign mem_pipeline.data_a        = data_a;
  assign mem_pipeline.data_b        = data_b;

  assign wb_pipeline.reg_we         = reg_we;
  assign wb_pipeline.wdata_mux      = wdata_mux;
  assign wb_pipeline.dest_reg       = dest_reg;

  assign ex_pipeline_d.alu_data_a   = data_a;
  assign ex_pipeline_d.alu_data_b   = data_b;
  assign ex_pipeline_d.alu_op       = alu_op;
  assign ex_pipeline_d.mem_pipeline = mem_pipeline;
  assign ex_pipeline_d.wb_pipeline  = wb_pipeline;

  // ID pipeline stage registers
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if(~rst_ni) begin
      ex_pipeline_q <= 0';
    end else begin
      ex_pipeline_o <= ex_pipeline_d;
    end
  end

  // OUPUT ASSIGNMENT
  assign ex_pipeline_o = ex_pipeline_q;


endmodule