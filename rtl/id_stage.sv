module id_stage import riscv_cpu_pkg::*;
(
  input  logic                   clk_i,    // Clock
  input  logic                   rst_ni,   // Asynchronous reset active low

  // IF pipeline stage interface
  input  logic            [31:0] instr_rdata_i,
  input  logic            [31:0] pc_id_i,

  // Output of ID pipeline stage
  output logic  [DATA_WIDTH-1:0] data_a_o,
  output logic  [DATA_WIDTH-1:0] data_b_o,
  output logic                   alu_op_o,
  output logic            [31:0] pc_id_o,
  output logic            [31:0] instr_rdata_o
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
  ////     ALU INTERFACE      ////
  ////////////////////////////////
  logic [DATA_WIDTH-1:0] data_a_d;
  logic [DATA_WIDTH-1:0] data_a_q;
  logic [DATA_WIDTH-1:0] data_b_d;
  logic [DATA_WIDTH-1:0] data_b_q;
  logic                  alu_op_d;
  logic                  alu_op_q;

  ////////////////////////////////
  ////     CONTROL UNIT       ////
  ////////////////////////////////
  logic data_a_mux;
  logic data_b_mux;
  logic reg_raddr_a;
  logic reg_raddr_b;
  logic reg_waddr_a;
  logic reg_we_a;
  logic alu_op;
  logic alu_op;
  

  logic [31:0] pc_id_d;
  logic [31:0] pc_id_q;
  logic [31:0] instr_rdata_d;
  logic [31:0] instr_rdata_q;

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
    .alu_op_o       (alu_op),
    .reg_raddr_a_o  (reg_raddr_a),
    .reg_raddr_b_o  (reg_raddr_b),
    .reg_waddr_a_o  (reg_waddr_a),
    .reg_we_a_o     (reg_we_a)
  );

  assign raddr_a = reg_raddr_a;
  assign raddr_b = reg_raddr_b;
  assign waddr_a = reg_waddr_a;
  assign we_a    = reg_we_a;

  assign pc_id_d = pc_id_i;
  assign instr_rdata_d = instr_rdata_i;
  assign alu_op_d = alu_op;
  

  always_comb begin
    unique case(data_a_mux)
      default:    data_a_d = rdata_a;
    endcase
    unique case(data_b_mux)
      default:    data_b_d = rdata_b;
    endcase
  end



  // ID pipeline stage registers
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if(~rst_ni) begin
      data_a_q      <= 0';
      data_a_q      <= 0';
      alu_op_q      <= 0';
      pc_id_q       <= 0';
      instr_rdata_q <= 0';
    end else begin
      data_a_q      <= data_a_d;
      data_b_q      <= data_b_d;
      alu_op_q      <= alu_op_d;
      pc_id_q       <= pc_id_d;
      instr_rdata_q <= instr_rdata_d;
    end
  end

  // OUPUT ASSIGNMENT
  assign data_a_o      = data_a_q;
  assign data_b_o      = data_b_q;
  assign alu_op_o      = alu_op_q;
  assign pc_id_o       = pc_id_q;
  assign instr_rdata_o = instr_rdata_q;


endmodule