module if_stage import riscv_cpu_pkg::*;
#(
) (
  input  logic                   clk_i,
  input  logic                   rstn_i,

  // instruction cache interface
  //output logic                   instr_req_o,
  output logic            [31:0] instr_addr_o,
  //input  logic                   instr_gnt_i,
  //input  logic                   instr_rvalid_i,
  input  logic            [31:0] instr_rdata_i,
  input  logic            [31:0] branch_addr_i,

  // Forwarding ports - control signals
  //input  logic                   clear_instr_valid_i,   // clear instruction valid bit in IF/ID pipe
  input  logic             [1:0] pc_mux_i,              // sel for pc multiplexer
  input  logic            [31:0] boot_addr_i,

  // Output of IF Pipeline stage
  //output logic                   instr_valid_id_o,      // instruction in IF/ID pipeline is valid
  output logic            [31:0] instr_rdata_id_o,      // read instruction is sampled and sent to ID stage for decoding
  output logic            [31:0] pc_if_o
);

  logic      [31:0] pc_q;
  logic      [31:0] pc_d;
  logic      [31:0] pc_old_q;
  logic      [31:0] pc_old_d;
  logic      [31:0] instr_reg_q;
  logic      [31:0] instr_reg_d;

  // PC selection mux
  always_comb begin
    unique case(pc_mux_i)
      PC_BOOT:    pc_d = boot_addr_i;
      PC_NEXT:    pc_d = pc_q + 4;
      PC_JMP:     pc_d = pc_q;
      PC_BRANCH:  pc_d = branch_addr_i;
    endcase
  end

  assign pc_old_d     = pc_q;
  assign instr_reg_d  = instr_rdata_i;

  // registers of IF pipeline stage
  always_ff @(posedge clk_i or negedge rstn_i) begin
    if(~rstn_i) begin
      pc_q        <= 0';
      pc_old_q    <= 0';
      instr_reg_q <= 0';
    end else begin
      pc_q        <= pc_d;
      pc_old_q    <= pc_old_d;
      instr_reg_q <= instr_reg_d;
    end
  end

  assign pc_if_o          = pc_old_q;
  assign instr_rdata_id_o = instr_req_q;

endmodule