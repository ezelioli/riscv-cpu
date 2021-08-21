module if_stage import riscv_cpu_pkg::*;
#(
) (
  input  logic                      clk_i,
  input  logic                      rst_ni,

  // instruction cache interface
  output logic                      instr_req_o,
  output logic               [31:0] instr_addr_o,
  //input  logic                   instr_gnt_i,
  //input  logic                   instr_rvalid_i,
  input  logic               [31:0] instr_rdata_i,
  input  logic               [31:0] branch_addr_i,
  input  logic               [31:0] jal_addr_i,
  input  logic                      jal_op_i,

  input  logic                      stall_id_i,

  // Forwarding ports - control signals
  //input  logic                   clear_instr_valid_i,   // clear instruction valid bit in IF/ID pipe
  input  logic                [1:0] cu_pc_mux_i,             // sel for control unit pc multiplexer
  input  logic                      branch_taken_i,
  input  logic               [31:0] boot_addr_i,

  // Output of IF Pipeline stage
  //output logic                   instr_valid_id_o,      // instruction in IF/ID pipeline is valid
  output logic               [31:0] instr_rdata_id_o,        // read instruction is sampled and sent to ID stage for decoding
  output logic               [31:0] pc_if_o
);
  
  logic      [31:0] next_addr;
  logic      [31:0] pc_q;
  logic      [31:0] pc_d;
  logic      [31:0] pc_old_q;
  logic      [31:0] pc_old_d;
  logic      [31:0] instr_reg_q;
  logic      [31:0] instr_reg_d;

  logic  [BU_MUX_WIDTH-1:0] bu_pc_mux;
  logic                     bu_jal_op;

  branch_unit branch_unit_i (
    .clk_i            (clk_i),
    .rst_ni           (rst_ni),
    .branch_taken_i   (branch_taken_i),
    .jal_op_i         (bu_jal_op),
    .pc_mux_o         (bu_pc_mux)
  );

  // TO BE IMPLEMENTED
  assign instr_req_o = 1'b1;

  assign bu_jal_op = jal_op_i;

  /*always_comb begin // check if fetched instruction is JAL or JALR
    bu_jal_op = 1'b0;
    if(instr_reg_q[OP_MSB:OP_LSB] == OPCODE_JAL || instr_reg_q[OP_MSB:OP_LSB] == OPCODE_JALR) begin
      bu_jal_op = 1'b1;
    end
  end*/

  // PC CONTROL UNIT MUX
  always_comb begin
    unique case(cu_pc_mux_i)
      CU_PC_BOOT:     next_addr = boot_addr_i;
      CU_PC_STALL:    next_addr = pc_q;
      CU_PC_NEXT:     next_addr = pc_q + 4;
      default:        next_addr = pc_q + 4;
    endcase
  end

  // PC BRANCH UNIT MUX
  always_comb begin
    pc_d = pc_q;
    unique case(bu_pc_mux)
      BU_PC_NEXT:    pc_d = next_addr;
      BU_PC_BRANCH:  pc_d = branch_addr_i;
      BU_PC_JAL:     pc_d = jal_addr_i;
    endcase
  end

  assign pc_old_d     = pc_q;
  assign instr_reg_d  = instr_rdata_i;

  // registers of IF pipeline stage
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if(~rst_ni) begin
      pc_q        <= '0;
      pc_old_q    <= '0;
      instr_reg_q <= '0;
    end else begin
      if(stall_id_i == 1'b0) begin
        pc_q        <= pc_d;
        pc_old_q    <= pc_old_d;
        instr_reg_q <= instr_reg_d;
      end
    end
  end

  assign pc_if_o          = pc_old_q;
  assign instr_rdata_id_o = instr_reg_q;

  assign instr_addr_o = pc_q;

endmodule