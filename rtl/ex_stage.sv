module ex_stage import riscv_cpu_pkg::*;
#(
) (
  input  logic                   clk_i,    // Clock
  input  logic                   rst_ni,   // Asynchronous reset active low

  // EX pipeline stage interface
  input  logic            [31:0] instr_rdata_i,
  input  logic            [31:0] pc_ex_i,
  input  logic  [DATA_WIDTH-1:0] data_a_i,
  input  logic  [DATA_WIDTH-1:0] data_b_i,
  input  logic                   alu_op_i,
  
  // Output of EX pipeline stage
  output logic            [31:0] pc_ex_o,
  output logic            [31:0] instr_rdata_o,
  output logic  [DATA_WIDTH-1:0] data_a_o,
  output logic  [DATA_WIDTH-1:0] data_b_o,
  output logic  [DATA_WIDTH-1:0] alu_result_o,
  output logic   [CSR_WIDTH-1:0] csr_o
);
  
  logic [31:0] pc_ex_d;
  logic [31:0] pc_ex_q;
  logic [31:0] instr_rdata_d;
  logic [31:0] instr_rdata_q;
  logic [DATA_WIDTH-1:0] data_a_d;
  logic [DATA_WIDTH-1:0] data_a_q;
  logic [DATA_WIDTH-1:0] data_b_d;
  logic [DATA_WIDTH-1:0] data_b_q;  
  logic [DATA_WIDTH-1:0] alu_result_d;
  logic [DATA_WIDTH-1:0] alu_result_q;
  logic [CSR_WIDTH-1:0] csr_d;
  logic [CSR_WIDTH-1:0] csr_q;

  ////////////////////////////////
  ////          ALU           ////
  ////////////////////////////////
  logic [DATA_WIDTH-1:0] data_a;
  logic [DATA_WIDTH-1:0] data_b;
  logic                  alu_op;
  logic [DATA_WIDTH-1:0] alu_result;
  logic [CSR_WIDTH-1:0]  alu_csr;

  alu #(
  ) alu_i (
    .data_a_i     (data_a),
    .data_b_i     (data_b),
    .op_i         (alu_op),
    .data_o       (alu_result),
    .csr_o        (alu_csr)
  );

  assign pc_ex_d        = pc_ex_i;
  assign instr_rdata_d  = instr_rdata_i;
  assign data_a_d       = data_a_i;
  assign data_b_d       = data_b_i;
  assign alu_result_d   = alu_result;
  assign csr_d          = alu_csr;

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if(~rst_ni) begin
      pc_ex_q           <= 0';
      instr_rdata_q     <= 0';
      data_a_q          <= 0';
      data_b_q          <= 0';
      alu_result_q      <= 0';
      csr_q             <= 0';
    end else begin
      pc_ex_q           <= pc_ex_d;
      instr_rdata_q     <= instr_rdata_d;
      data_a_q          <= data_a_d;
      data_b_q          <= data_b_d;
      alu_result_q      <= alu_result_d;
      csr_q             <= csr_d;
    end
  end

  assign pc_ex_o        = pc_ex_q;
  assign instr_rdata_o  = instr_rdata_q;
  assign data_a_o       = data_a_q;
  assign data_b_o       = data_b_q;
  assign alu_result_o   = alu_result_q;
  assign csr_o          = csr_q;

endmodule : ex_stage