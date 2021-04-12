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

  // Output of ID pipeline stage
  output logic  [DATA_WIDTH-1:0] data_a_o,
  output logic  [DATA_WIDTH-1:0] data_b_o,
  output logic                   alu_op_o,
  output logic            [31:0] pc_id_o,
  output logic            [31:0] instr_rdata_o,
  output logic            [31:0] branch_addr_o,
  output logic                   jmp_mux_o
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
  logic imm_mux;
  logic reg_raddr_a;
  logic reg_raddr_b;
  logic reg_waddr_a;
  logic reg_we_a;
  logic alu_op;
  logic alu_op;
  logic [DATA_WIDTH-1:0] imm;
  

  logic [31:0] pc_id_d;
  logic [31:0] pc_id_q;
  logic [31:0] instr_rdata_d;
  logic [31:0] instr_rdata_q;
  logic [31:0] branch_addr_d;
  logic [31:0] branch_addr_q;
  logic        jmp_mux_d;
  logic        jmp_mux_q;

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
    .pc_mux_o       (pc_mux_o),
    .jmp_mux_o      (jmp_mux)
  );

  assign raddr_a          = reg_raddr_a;
  assign raddr_b          = reg_raddr_b;

  assign waddr_a          = waddr_a_i;
  assign wdata_a          = wdata_a_i;
  assign we_a             = we_a_i;

  assign pc_id_d          = pc_id_i;
  assign instr_rdata_d    = instr_rdata_i;
  assign alu_op_d         = alu_op;
  assign jmp_mux_d        = jmp_mux;

  assign branch_addr_d    = instr_i[JAL_MSB:JAL_LSB];

  always_comb begin
    unique case(imm_mux)
      IMM_Z:  imm = '0;
      IMM_I:  imm = instr_i[IMM_MSB:IMM_LSB];
  end

  always_comb begin
    unique case(data_a_mux)
      OP_A_REG:   data_a_d = rdata_a;
      OP_A_IMM:   data_a_d = imm;
    endcase
    unique case(data_b_mux)
      OP_B_REG:    data_b_d = rdata_b;
      OP_B_IMM:    data_b_d = imm;
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
      jmp_mux_q     <= 0';
      branch_addr_q <= 0';
    end else begin
      data_a_q      <= data_a_d;
      data_b_q      <= data_b_d;
      alu_op_q      <= alu_op_d;
      pc_id_q       <= pc_id_d;
      instr_rdata_q <= instr_rdata_d;
      jmp_mux_q     <= jmp_mux_d;
      branch_addr_q <= branch_addr_d;
    end
  end

  // OUPUT ASSIGNMENT
  assign data_a_o      = data_a_q;
  assign data_b_o      = data_b_q;
  assign alu_op_o      = alu_op_q;
  assign pc_id_o       = pc_id_q;
  assign instr_rdata_o = instr_rdata_q;
  assign branch_addr_o = branch_addr_q;
  assign jmp_mux_o     = jmp_mux_q;


endmodule