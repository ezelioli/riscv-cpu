module mem_stage import riscv_cpu_pkg::*;
#(
) (
  input  logic                   clk_i,
  input  logic                   rst_ni,

  // MEM pipeline stage interface
  input  logic            [31:0] instr_rdata_i,
  input  logic            [31:0] pc_mem_i,
  input  logic  [DATA_WIDTH-1:0] data_a_i,
  input  logic  [DATA_WIDTH-1:0] data_b_i,
  input  logic  [DATA_WIDTH-1:0] alu_result_i,
  input  logic   [CSR_WIDTH-1:0] alu_csr_i,
  input  logic             [1:0] branch_mux_i,
  input  logic            [31:0] branch_addr_i,
  
  // Output of MEM pipeline stage
  output logic            [31:0] instr_rdata_o,
  output logic  [DATA_WIDTH-1:0]      alu_result_o,
  output logic  [DATA_WIDTH-1:0]      mem_data_o,
  output logic                        taken_o,

  output logic            [31:0] branch_addr_o,

  // Signals reserved for data memory interface
  output logic                        data_req_o,
  input  logic                        data_gnt_i,
  input  logic                        data_rvalid_i,
  output logic      [DATA_WIDTH-1:0]  data_addr_o,
  output logic                        data_we_o,
  output logic      [DATA_WIDTH-1:0]  data_wdata_o,
  input  logic      [DATA_WIDTH-1:0]  data_rdata_i

);

  logic [31:0] instr_rdata_d;
  logic [31:0] instr_rdata_q;
  logic  [DATA_WIDTH-1:0] alu_result_d;
  logic  [DATA_WIDTH-1:0] alu_result_q;
  logic [DATA_WIDTH-1:0] mem_data_d;
  logic [DATA_WIDTH-1:0] mem_data_q;
  
  // load store unit signals : SHOULD BE DRIVEN FROM INSTR_RDATA_I
  logic lsu_data_we;
  logic [1:0] lsu_data_type;
  logic [DATA_WIDTH-1:0] lsu_data_wdata;
  logic lsu_data_load_event;
  logic [DATA_WIDTH-1:0] lsu_data_rdata;
  logic [DATA_WIDTH-1:0] lsu_operand_a;
  logic [DATA_WIDTH-1:0] lsu_operand_b;

  // branch unit signals
  logic [31:0] b_pc;
  logic [CSR_WIDTH-1:0] b_csr;
  logic b_taken;
  logic [1:0] b_branch_mux;

  load_store_unit_simple #(
  ) load_store_unit_simple_i (
    .clk_i                    (clk_i),
    .rst_ni                   (rst_ni),
    .data_req_o               (data_req_o),
    .data_gnt_i               (data_gnt_i),
    .data_addr_o              (data_addr_o),
    .data_we_o                (data_we_o),
    .data_wdata_o             (data_wdata_o),
    .data_rdata_i             (data_rdata_i),

    .data_we_mem_i            (lsu_data_we),
    .data_type_mem_i          (lsu_data_type),
    .data_wdata_mem_i         (lsu_data_wdata),
    .data_load_event_mem_i    (lsu_data_load_event),
    .data_rdata_mem_o         (lsu_data_rdata),
    .operand_a_mem_i          (lsu_operand_a),
    .operand_b_mem_i          (lsu_operand_b)
  );

  mem_branch_ctl #(
  ) mem_branch_ctl_i (
    .clk_i              (clk_i),
    .rst_ni             (rst_ni),
    .pc_i               (b_pc),
    .csr_i              (b_csr),
    .branch_mux_i       (b_branch_mux),
    .taken_o            (b_taken)
  );

  assign b_pc          = pc_i;
  assign b_csr         = csr_i;
  assign b_branch_mux  = branch_mux_i;

  assign instr_rdata_d  = instr_rdata_i;
  assign alu_result_d   = alu_result_i;
  assign mem_data_d     = data_rdata_i;

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if(~rst_ni) begin
      instr_rdata_q     <= 0';
      alu_result_q      <= 0';
      mem_data_q        <= 0';
    end else begin
      instr_rdata_q     <= instr_rdata_d;
      alu_result_q      <= alu_result_d;
      mem_data_q        <= mem_data_d;
    end
  end

  assign instr_rdata_o  = instr_rdata_q;
  assign alu_result_o   = alu_result_q;
  assign mem_data_o     = mem_data_q;

  assign branch_addr_o  = branch_addr_i;

  assign taken_o        = b_taken;

endmodule