module control_unit import riscv_cpu_pkg::*;
#(
) (
  input  logic clk_i,
  input  logic rst_ni,

  input  logic [31:0] instr_i,

  // pipelined control
  output logic                 [1:0] data_a_mux_o,
  output logic                       data_b_mux_o,
  output logic   [IMM_MUX_WIDTH-1:0] imm_mux_o,
  output logic    [ALU_OP_WIDTH-1:0] alu_op_o,
  output logic      [ADDR_WIDTH-1:0] reg_raddr_a_o,
  output logic      [ADDR_WIDTH-1:0] reg_raddr_b_o,
  output logic                       reg_we_o,
  output logic                 [1:0] branch_mux_o,
  output logic [WDATA_MUX_WIDTH-1:0] wdata_mux_o,
  output logic                       mem_we_o,

  // direct control
  output logic            [1:0] pc_mux_o,
  output logic                  jal_op_o,
  output logic            [1:0] jal_mux_o
);
  
  // internal signals
  logic [6:0] opcode;
  logic [2:0] funct3;

  assign opcode = instr_i[OP_MSB:OP_LSB];
  assign funct3 = instr_i[FUNCT3_MSB:FUNCT3_LSB];

  // instruction decoder //
  always_comb begin
    data_a_mux_o = OP_A_REG;
    data_b_mux_o = OP_B_IMM;
    imm_mux_o    = IMM_Z;
    alu_op_o     = ALU_ADD;
    branch_mux_o = NO_BRANCH;
    wdata_mux_o  = WDATA_ALU;
    pc_mux_o     = CU_PC_NEXT;
    reg_we_o     = 1'b0;
    jal_op_o     = 1'b0;
    jal_mux_o    = JAL_JUMP;
    mem_we_o     = 1'b0; 
    reg_raddr_a_o = instr_i[REG_S1_MSB:REG_S1_LSB]; // make static assignment
    reg_raddr_b_o = instr_i[REG_S2_MSB:REG_S2_LSB]; // make static assignment

    unique case(opcode)
      OPCODE_LUI: data_a_mux_o = OP_A_REG;
      OPCODE_AUIPC: data_a_mux_o = OP_A_REG;
      OPCODE_JAL: begin      // Jump And Link
        jal_op_o      = 1'b1;
        data_a_mux_o  = OP_A_PC;
        imm_mux_o     = IMM_J;
        data_b_mux_o  = OP_B_IMM;
        alu_op_o      = ALU_ADD;
        wdata_mux_o   = WDATA_ALU;
        jal_mux_o     = JAL_JUMP;
      end
      OPCODE_JALR: begin     // Jump And Link Register
        jal_op_o      = 1'b1;
        data_a_mux_o  = OP_A_PC;
        imm_mux_o     = IMM_J;
        data_b_mux_o  = OP_B_IMM;
        alu_op_o      = ALU_ADD;
        wdata_mux_o   = WDATA_ALU;
        jal_mux_o     = JAL_JUMPR;
      end
      OPCODE_BRANCH: begin   // Branch
        data_a_mux_o  = OP_A_REG;
        data_b_mux_o  = OP_B_REG;
        alu_op_o      = ALU_SUB;
        unique case(funct3)
          BEQ:     branch_mux_o = BRANCH_IF_EQUAL;
          BNE:     branch_mux_o = BRANCH_IF_EQUAL_N;
          default: branch_mux_o = NO_BRANCH;
        endcase
      end
      OPCODE_LOAD: begin
        reg_we_o      = 1'b1;
        wdata_mux_o   = WDATA_MEM;
        data_a_mux_o  = OP_A_REG;
        imm_mux_o     = IMM_I;
        alu_op_o      = ALU_ADD;
//        unique case(funct3)
//          LB: ;
//          LH: ;
//          LW:  ;
//          LBU: ;
//          LHU: ;
//        endcase
      end
      OPCODE_STORE: begin
        data_a_mux_o  = OP_A_REG;
        data_b_mux_o  = OP_B_REG;
        imm_mux_o     = IMM_S;
        alu_op_o      = ALU_ADD;
        mem_we_o      = 1'b1;
//        unique case(funct3)
//          SB: ;
//          SH: ;
//          SW: ;
//        endcase
      end
      OPCODE_OP_IMM: begin
        imm_mux_o     = IMM_I;
        data_a_mux_o  = OP_A_REG;
        data_b_mux_o  = OP_B_IMM;
        wdata_mux_o   = WDATA_ALU;
        unique case(funct3)
          ADDI : alu_op_o = ALU_ADD;
          SLTI : alu_op_o = ALU_SLT;
          SLTIU: alu_op_o = ALU_SLTU;
          XORI : alu_op_o = ALU_XOR;
          ORI  : alu_op_o = ALU_OR;
          ANDI : alu_op_o = ALU_AND;
          SLLI : alu_op_o = ALU_SLL;
          SRI  : if(instr_i[30] == 1'b0) begin alu_op_o = ALU_SRL; end else begin alu_op_o = ALU_SRA; end
        endcase
      end
      OPCODE_OP: begin
        data_a_mux_o  = OP_A_REG;
        data_b_mux_o  = OP_B_REG;
        wdata_mux_o   = WDATA_ALU;
        unique case(funct3)
          ADD : if(instr_i[30] == 1'b0) begin alu_op_o = ALU_ADD; end else begin alu_op_o = ALU_SUB; end
          SLL : alu_op_o = ALU_SLL;
          SLT : alu_op_o = ALU_SLT;
          SLTU: alu_op_o = ALU_SLTU;
          XOR : alu_op_o = ALU_XOR;
          SR  : if(instr_i[30] == 1'b0) begin alu_op_o = ALU_SRL; end else begin alu_op_o = ALU_SRA; end
          OR  : alu_op_o = ALU_OR;
          AND : alu_op_o = ALU_AND;
        endcase
      end
      OPCODE_MISC_MEM: data_a_mux_o = OP_A_REG;
      OPCODE_SYSTEM:   data_a_mux_o = OP_A_REG;
      default: ;
    endcase // opcode
  end

endmodule : control_unit