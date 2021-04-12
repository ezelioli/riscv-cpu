package riscv_cpu_pkg;

  /////////////////////////
  //    REGISTER FILE    //
  /////////////////////////
  parameter ADDR_WIDTH = 5;
  parameter DATA_WIDTH = 32;

  parameter CSR_WIDTH  = 16;

  // CONTROL UNIT PC MUX //
  parameter CU_PC_BOOT    = 2'b00;
  parameter CU_PC_STALL   = 2'b01;
  parameter CU_PC_NEXT    = 2'b10;

  // BRANCH UNIT PC MUX //
  parameter BU_PC_NEXT = 1'b0;
  parameter BU_PC_JMP  = 1'b1;

  // INSTRUCTION FIELDS //
  parameter OP_MSB     = 6;
  parameter OP_LSB     = 0;
  parameter REG_S1_MSB = 19;
  parameter REG_S1_LSB = 15;
  parameter REG_S2_MSB = 24;
  parameter REG_S2_LSB = 20;
  parameter IMM_MSB    = 31;
  parameter IMM_LSB    = 20;
  parameter JAL_MSB    = 31;
  parameter JAL_LSB    = 7;

  // OPCODES //
  parameter OPCODE_SYSTEM    = 7'h73;
  parameter OPCODE_FENCE     = 7'h0f;
  parameter OPCODE_OP        = 7'h33;
  parameter OPCODE_OPIMM     = 7'h13;
  parameter OPCODE_STORE     = 7'h23;
  parameter OPCODE_LOAD      = 7'h03;
  parameter OPCODE_BRANCH    = 7'h63;
  parameter OPCODE_JALR      = 7'h67;
  parameter OPCODE_JAL       = 7'h6f;
  parameter OPCODE_AUIPC     = 7'h17;
  parameter OPCODE_LUI       = 7'h37;
  parameter OPCODE_OP_FP     = 7'h53;
  parameter OPCODE_OP_FMADD  = 7'h43;
  parameter OPCODE_OP_FNMADD = 7'h4f;
  parameter OPCODE_OP_FMSUB  = 7'h47;
  parameter OPCODE_OP_FNMSUB = 7'h4b;
  parameter OPCODE_STORE_FP  = 7'h27;
  parameter OPCODE_LOAD_FP   = 7'h07;
  parameter OPCODE_AMO       = 7'h2F;

  // ALU OPERANDS MUX //
  parameter OP_A_REG   = 0;
  parameter OP_A_IMM   = 1;
  parameter OP_B_REG   = 0;
  parameter OP_B_IMM   = 1;

  // ALU operations //
  parameter ALU_OP_WIDTH = 7;

  // IMMEDIATE MUX //
  parameter IMM_Z = 1'b0;
  parameter IMM_I = 1'b1;

typedef enum logic [ALU_OP_WIDTH-1:0]
{

 ALU_ADD   = 7'b0011000,
 ALU_SUB   = 7'b0011001,
 ALU_ADDU  = 7'b0011010,
 ALU_SUBU  = 7'b0011011,
 ALU_ADDR  = 7'b0011100,
 ALU_SUBR  = 7'b0011101,
 ALU_ADDUR = 7'b0011110,
 ALU_SUBUR = 7'b0011111,

 ALU_XOR   = 7'b0101111,
 ALU_OR    = 7'b0101110,
 ALU_AND   = 7'b0010101,

// Shifts
 ALU_SRA   = 7'b0100100,
 ALU_SRL   = 7'b0100101,
 ALU_ROR   = 7'b0100110,
 ALU_SLL   = 7'b0100111,

// bit manipulation
 ALU_BEXT  = 7'b0101000,
 ALU_BEXTU = 7'b0101001,
 ALU_BINS  = 7'b0101010,
 ALU_BCLR  = 7'b0101011,
 ALU_BSET  = 7'b0101100,
 ALU_BREV  = 7'b1001001,

// Bit counting
 ALU_FF1   = 7'b0110110,
 ALU_FL1   = 7'b0110111,
 ALU_CNT   = 7'b0110100,
 ALU_CLB   = 7'b0110101,

// Sign-/zero-extensions
 ALU_EXTS  = 7'b0111110,
 ALU_EXT   = 7'b0111111,

// Comparisons
 ALU_LTS   = 7'b0000000,
 ALU_LTU   = 7'b0000001,
 ALU_LES   = 7'b0000100,
 ALU_LEU   = 7'b0000101,
 ALU_GTS   = 7'b0001000,
 ALU_GTU   = 7'b0001001,
 ALU_GES   = 7'b0001010,
 ALU_GEU   = 7'b0001011,
 ALU_EQ    = 7'b0001100,
 ALU_NE    = 7'b0001101,

// Set Lower Than operations
 ALU_SLTS  = 7'b0000010,
 ALU_SLTU  = 7'b0000011,
 ALU_SLETS = 7'b0000110,
 ALU_SLETU = 7'b0000111,

// Absolute value
 ALU_ABS   = 7'b0010100,
 ALU_CLIP  = 7'b0010110,
 ALU_CLIPU = 7'b0010111,

// Insert/extract
 ALU_INS   = 7'b0101101,

// min/max
 ALU_MIN   = 7'b0010000,
 ALU_MINU  = 7'b0010001,
 ALU_MAX   = 7'b0010010,
 ALU_MAXU  = 7'b0010011,

// div/rem
 ALU_DIVU  = 7'b0110000, // bit 0 is used for signed mode, bit 1 is used for remdiv
 ALU_DIV   = 7'b0110001, // bit 0 is used for signed mode, bit 1 is used for remdiv
 ALU_REMU  = 7'b0110010, // bit 0 is used for signed mode, bit 1 is used for remdiv
 ALU_REM   = 7'b0110011, // bit 0 is used for signed mode, bit 1 is used for remdiv

 ALU_SHUF  = 7'b0111010,
 ALU_SHUF2 = 7'b0111011,
 ALU_PCKLO = 7'b0111000,
 ALU_PCKHI = 7'b0111001

} alu_opcode_e;

endpackage : riscv_cpu_pkg