module control_unit import riscv_cpu_pkg::*;
#(
) (
  input  logic clk_i,
  input  logic rst_ni,

  input  logic [31:0] instr_i,

  // pipelined control
  output logic                       data_a_mux_o,
  output logic                       data_b_mux_o,
  output logic   [IMM_MUX_WIDTH-1:0] imm_mux_o,
  output logic                       alu_op_o,
  output logic      [ADDR_WIDTH-1:0] reg_raddr_a_o,
  output logic      [ADDR_WIDTH-1:0] reg_raddr_b_o,
  output logic                       reg_we_o,
  output logic                 [1:0] branch_mux_o,
  output logic [WDATA_MUX_WIDTH-1:0] wdata_mux_o,

  // direct control
  output logic            [1:0] pc_mux_o,
  output logic                  jal_op_o
);
  
  // internal signals
  logic [6:0] opcode;
  logic [2:0] funct3;

  assign opcode = instr_i[OP_MSB:OP_LSB];
  assign funct3 = instr_i[FUNCT_MSB:FUNCT_LSB];

  // instruction decoder //
  always_comb begin
    data_a_mux_o = 1'b0;
    data_b_mux_o = 1'b0;
    imm_mux_o    = 1'b0;
    alu_op_o     = 1'b0;
    reg_we_o     = 1'b0;
    branch_mux_o = NO_BRANCH;
    wdata_mux_o  = WDATA_ALU;
    pc_mux_o     = CU_PC_NEXT;
    jal_op_o     = 1'b0;

    unique case(opcode)
      OPCODE_LUI:
        ;
      OPCODE_AUIPC:
        ;
      OPCODE_JAL:       // Jump And Link
        jal_op_o = 1'b1;
      OPCODE_JALR:      // Jump And Link Register
        jal_op_o = 1'b1;
      OPCODE_BRANCH:    // Branch
        unique case(funct3)
          BEQ:     branch_mux_o = BRANCH_IF_EQUAL;
          BNE:     branch_mux_o = BRANCH_IF_EQUAL_N;
          default: branch_mux_o = NO_BRANCH;
        endcase
      OPCODE_LOAD:
        reg_we_o = 1'b1;
        wdata_mux_o = WDATA_MEM;
        reg_raddr_a_o = instr_i[19:15]; // add parameters for these numbers
        data_a_mux_o = OP_A_REG;
        imm_mux_o = IMM_I;
        alu_op_o = 0'; /// add operation between data_a and imm
//        unique case(funct3)
//          LB: ;
//          LH: ;
//          LW:  ;
//          LBU: ;
//          LHU: ;
//        endcase
      OPCODE_STORE:
        reg_raddr_a_o = instr_i[19:15];
        data_a_mux_o = OP_A_REG;
        reg_raddr_b_o = instr_i[24:20]; // make parametric
        data_b_mux_o  = OP_B_REG;
        imm_mux_o = IMM_STORE;
        alu_op_o = 0'; // addition between data_a and imm
//        unique case(funct3)
//          SB: ;
//          SH: ;
//          SW: ;
//        endcase
      OPCODE_OP_IMM:
        ;
      OPCODE_OP:
        ;
      OPCODE_MISC_MEM:
        ;
      OPCODE_SYSTEM:
        ;
      default:
        ;
    endcase // opcode
  end

  assign reg_raddr_a_o    = instr_i[REG_S1_MSB:REG_S1_LSB];
  assign reg_raddr_b_o    = instr_i[REG_S2_MSB:REG_S2_LSB];

endmodule : control_unit