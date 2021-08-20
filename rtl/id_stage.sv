module id_stage import riscv_cpu_pkg::*;
(
  input  logic                      clk_i,    // Clock
  input  logic                      rst_ni,   // Asynchronous reset active low

  // IF pipeline stage interface
  input  logic               [31:0] instr_rdata_i,
  input  logic               [31:0] pc_id_i,

  // Signals from WB pipeline stage
  input  logic     [ADDR_WIDTH-1:0] waddr_a_i,
  input  logic     [DATA_WIDTH-1:0] wdata_a_i,
  input  logic                      we_a_i,

  // Control signals
  output logic                [1:0] pc_mux_o,
  output logic                      jal_op_o,
  output logic               [31:0] jal_addr_o,

  // Pipelined control
  output ex_ctl_t                   ex_ctl_o,
  output mem_ctl_t                  mem_ctl_o,
  output wb_ctl_t                   wb_ctl_o,

  // Output of ID pipeline stage
  output id2ex_t                    ex_pipeline_o
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
  logic [1:0] data_a_mux;
  logic data_b_mux;
  logic [IMM_MUX_WIDTH-1:0] imm_mux;
  logic [ALU_OP_WIDTH-1:0]  alu_op;
  logic [ADDR_WIDTH-1:0]    reg_raddr_a;
  logic [ADDR_WIDTH-1:0]    reg_raddr_b;
  logic reg_we;
  logic [1:0] branch_mux;
  logic [WDATA_MUX_WIDTH-1:0] wdata_mux;
  logic [1:0] jal_mux;

  logic [DATA_WIDTH-1:0] data_a;
  logic [DATA_WIDTH-1:0] data_b;
  logic [ADDR_WIDTH-1:0] dest_reg;
  logic [DATA_WIDTH-1:0] imm;

  logic [DATA_WIDTH-1:0] mem_wdata;
  logic                  mem_we;

  logic [31:0] jal_offset;
  logic [31:0] jalr_offset;

  logic [31:0] branch_offset;

  //id2mem_t mem_pipeline;
  //id2wb_t  wb_pipeline;

  ex_ctl_t ex_ctl_d;
  ex_ctl_t ex_ctl_q;

  mem_ctl_t mem_ctl_d;
  mem_ctl_t mem_ctl_q;

  wb_ctl_t wb_ctl_d;
  wb_ctl_t wb_ctl_q;

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
    .mem_we_o       (mem_we),

    .pc_mux_o       (pc_mux_o),
    .jal_op_o       (jal_op_o),
    .jal_mux_o      (jal_mux)
  );

  assign raddr_a          = reg_raddr_a;
  assign raddr_b          = reg_raddr_b;

  assign waddr_a          = waddr_a_i;
  assign wdata_a          = wdata_a_i;
  assign we_a             = we_a_i;

  assign dest_reg         = instr_rdata_i[REG_RD_MSB:REG_RD_LSB]; // always the same
  assign mem_wdata        = rdata_b;

  always_comb begin : jmp_offset_sign_extension
    jal_offset[31] = instr_rdata_i[31];
    jal_offset[30:19] = '{12{instr_rdata_i[31]}};
    jal_offset[18:11] = instr_rdata_i[19:12];
    jal_offset[10] = instr_rdata_i[20];
    jal_offset[9:0] = instr_rdata_i[30:21];

    jalr_offset[31] = instr_rdata_i[31];
    jalr_offset[30:11] = '{20{instr_rdata_i[31]}};
    jalr_offset[10:0] = instr_rdata_i[30:20];

    branch_offset[31] = instr_rdata_i[31];
    branch_offset[30:11] = '{20{instr_rdata_i[31]}};
    branch_offset[10] = instr_rdata_i[7];
    branch_offset[9:4] = instr_rdata_i[30:25];
    branch_offset[3:0] = instr_rdata_i[11:8];
  end : jmp_offset_sign_extension

  always_comb begin : imm_sign_extension
    imm = '0;
    unique case(imm_mux)
      IMM_Z:  imm = '0;
      IMM_I:  begin
        imm[DATA_WIDTH-1:IMM_NBITS-1]  = '{(DATA_WIDTH-IMM_NBITS+1){instr_rdata_i[IMM_MSB]}};
        imm[IMM_NBITS-2:0] = instr_rdata_i[IMM_MSB-1:IMM_LSB];
      end
      IMM_S:  begin // parametrize this
        imm[DATA_WIDTH-1]  = '{21{instr_rdata_i[31]}};
        imm[IMM_NBITS-2:0] = {instr_rdata_i[30:25], instr_rdata_i[11:7]};
      end
      IMM_J:  imm = 4;
    endcase
  end : imm_sign_extension

  always_comb begin
    data_a = rdata_a;
    data_b = rdata_b;
    unique case(data_a_mux)
      OP_A_REG:   data_a = rdata_a;
      OP_A_IMM:   data_a = imm;
      OP_A_PC:    data_a = pc_id_i;
    endcase
    unique case(data_b_mux)
      OP_B_REG:    data_b = rdata_b;
      OP_B_IMM:    data_b = imm;
    endcase
  end

  always_comb begin
    unique case(jal_mux)
      JAL_JUMP:  jal_addr_o = pc_id_i + jal_offset;
      JAL_JUMPR: jal_addr_o = rdata_a + jalr_offset;
    endcase
  end

  assign ex_ctl_d.alu_op                      = alu_op;

  assign mem_ctl_d.branch_mux                 = branch_mux;
  assign mem_ctl_d.mem_we                     = mem_we;

  assign wb_ctl_d.reg_we                      = reg_we;
  assign wb_ctl_d.wdata_mux                   = wdata_mux;

  assign ex_pipeline_d.imm                    = imm;
  assign ex_pipeline_d.alu_data_a             = data_a;
  assign ex_pipeline_d.alu_data_b             = data_b;
  assign ex_pipeline_d.pc                     = pc_id_i;
  assign ex_pipeline_d.branch_addr            = pc_id_i + branch_offset;
  assign ex_pipeline_d.mem_wdata              = mem_wdata;
  assign ex_pipeline_d.dest_reg               = dest_reg;

  // ID pipeline stage registers
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if(~rst_ni) begin
      ex_ctl_q      <= '{default: '0};
      mem_ctl_q     <= '{default: '0};
      wb_ctl_q      <= '{default: '0};
      ex_pipeline_q <= '{default: '0};
    end else begin
      ex_ctl_q      <= ex_ctl_d;
      mem_ctl_q     <= mem_ctl_d;
      wb_ctl_q      <= wb_ctl_d;
      ex_pipeline_q <= ex_pipeline_d;
    end
  end

  // OUPUT ASSIGNMENT
  assign ex_ctl_o      = ex_ctl_q;
  assign mem_ctl_o      = mem_ctl_q;
  assign wb_ctl_o      = wb_ctl_q;
  assign ex_pipeline_o = ex_pipeline_q;


endmodule