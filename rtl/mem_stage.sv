module mem_stage import riscv_cpu_pkg::*;
#(
) (
  input  logic                   clk_i,
  input  logic                   rst_ni,

  // EX pipeline stage interface
  input  logic            [31:0] instr_rdata_i,
  input  logic            [31:0] pc_mem_i,
  input  logic  [DATA_WIDTH-1:0] data_a_i,
  input  logic  [DATA_WIDTH-1:0] data_b_i,
  input  logic  [DATA_WIDTH-1:0] alu_result_i,
  input  logic   [CSR_WIDTH-1:0] alu_csr_i,
  
  // Output of EX pipeline stage
  output logic            [31:0] instr_rdata_o,
  output logic  [DATA_WIDTH-1:0] alu_result_o,
  output logic  [DATA_WIDTH-1:0] mem_data_o,
  output logic                   taken_o,

  // Signals reserved for data memory interface
  output logic                        data_req_o,
  input  logic                        data_gnt_i,
  input  logic                        data_rvalid_i
  output logic      [DATA_WIDTH-1:0]  data_addr_o,
  output logic                        data_we_o,
  output logic      [DATA_WIDTH-1:0]  data_wdata_o,
  input  logic      [DATA_WIDTH-1:0]  data_rdata_i

);
  
  // load store unit signals
  logic lsu_data_we;
  logic [1:0] lsu_data_type;
  logic [DATA_WIDTH-1:0] lsu_data_wdata;
  logic lsu_data_load_event;
  logic [DATA_WIDTH-1:0] lsu_data_rdata;
  logic [DATA_WIDTH-1:0] lsu_operand_a;
  logic [DATA_WIDTH-1:0] lsu_operand_b;

  // branch unit signals
  logic [31:0] bu_pc;
  logic [CSR_WIDTH-1:0] bu_csr;
  logic bu_taken;

  load_store_unit_simple #(
  ) load_store_unit_simple_i (
    .clk_i       (clk_i),
    .rst_ni      (rst_ni),
    .data_req_o  (data_req_o),
    .data_gnt_i  (data_gnt_i),
    .data_addr_o (data_addr_o),
    .data_we_o   (data_we_o),
    .data_wdata_o(data_wdata_o),
    .data_rdata_i(data_rdata_i),

    .data_we_mem_i            (lsu_data_we),
    .data_type_mem_i          (lsu_data_type),
    .data_wdata_mem_i         (lsu_data_wdata),
    .data_load_event_mem_i    (lsu_data_load_event),
    .data_rdata_mem_o         (lsu_data_rdata),
    .operand_a_mem_i          (lsu_operand_a),
    .operand_b_mem_i          (lsu_operand_b)
  );

  branch_unit #(
  ) branch_unit_i (
    .clk_i      (clk_i),
    .rst_ni     (rst_ni),
    .pc_i       (bu_pc),
    .csr_i      (bu_csr),
    .taken_o    (bu_taken)
  );

  assign bu_pc = pc_i;
  assign bu_csr = csr_i;
  assign taken_o = bu_taken;

endmodule