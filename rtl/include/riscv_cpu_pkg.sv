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
  parameter BU_MUX_WIDTH = 2; 
  parameter BU_PC_NEXT   = 2'b00;
  parameter BU_PC_JAL    = 2'b01;
  parameter BU_PC_BRANCH = 2'b10;

  // INSTRUCTION FIELDS //
  parameter OP_MSB     = 6;
  parameter OP_LSB     = 0;
  parameter FUNCT3_MSB = 14;
  parameter FUNCT3_LSB = 12;
  parameter FUNCT7_MSB = 31;
  parameter FUNCT7_LSB = 25;
  parameter REG_S1_MSB = 19;
  parameter REG_S1_LSB = 15;
  parameter REG_S2_MSB = 24;
  parameter REG_S2_LSB = 20;
  parameter REG_RD_MSB = 11;
  parameter REG_RD_LSB = 7;
  parameter IMM_MSB    = 31;
  parameter IMM_LSB    = 20;
  parameter JAL_MSB    = 31;
  parameter JAL_LSB    = 7;

  parameter IMM_NBITS = IMM_MSB - IMM_LSB + 1;

  // OPCODES //
  parameter OPCODE_LUI       = 7'h37;
  parameter OPCODE_AUIPC     = 7'h17;
  parameter OPCODE_JAL       = 7'h6F;
  parameter OPCODE_JALR      = 7'h67;
  parameter OPCODE_BRANCH    = 7'h63;
  parameter OPCODE_LOAD      = 7'h03;
  parameter OPCODE_STORE     = 7'h23;
  parameter OPCODE_OP_IMM    = 7'h13;
  parameter OPCODE_OP        = 7'h33;
  parameter OPCODE_MISC_MEM  = 7'h0F;
  parameter OPCODE_SYSTEM    = 7'h73;

  // FUNCT3 FIELD //
  // branch opcode
  parameter BEQ  = 3'b000;
  parameter BNE  = 3'b001;
  parameter BLT  = 3'b100;
  parameter BGE  = 3'b101;
  parameter BLTU = 3'b110;
  parameter BGEU = 3'b111;
  // load opcode
  parameter LB   = 3'b000;
  parameter LH   = 3'b001;
  parameter LW   = 3'b010;
  parameter LBU  = 3'b100;
  parameter LHU  = 3'b101;
  // store opcode
  parameter SB = 3'b000;
  parameter SH = 3'b001;
  parameter SW = 3'b010;
  // op-imm opcode
  parameter ADDI  = 3'b000;
  parameter SLTI  = 3'b010;
  parameter SLTIU = 3'b011;
  parameter XORI  = 3'b100;
  parameter ORI   = 3'b110;
  parameter ANDI  = 3'b111;
  parameter SLLI  = 3'b001;
  parameter SRI   = 3'b101;
  // op opcode
  parameter ADD  = 3'b000;
  //parameter SUB  = 3'b000;
  parameter SLL  = 3'b001;
  parameter SLT  = 3'b010;
  parameter SLTU = 3'b011;
  parameter XOR  = 3'b100;
  parameter SR   = 3'b101;
  parameter OR   = 3'b110;
  parameter AND  = 3'b111;

  // ALU OPERANDS MUX //
  parameter OP_A_REG   = 1'b00;
  parameter OP_A_IMM   = 1'b01;
  parameter OP_A_PC    = 2'b10;
  parameter OP_B_REG   = 0;
  parameter OP_B_IMM   = 1;

  // ALU operations //
  parameter ALU_OP_WIDTH = 4;
  parameter ALU_ADD  = 4'b0000;
  parameter ALU_SUB  = 4'b0001;
  parameter ALU_XOR  = 4'b0010;
  parameter ALU_AND  = 4'b0011;
  parameter ALU_SLT  = 4'b0100;
  parameter ALU_SLTU = 4'b0101;
  parameter ALU_SLL  = 4'b0110;
  parameter ALU_SRL  = 4'b0111;
  parameter ALU_SRA  = 4'b1000;

  // IMMEDIATE MUX //
  parameter IMM_MUX_WIDTH = 2;
  parameter IMM_Z     = 2'b00;
  parameter IMM_I     = 2'b01;
  parameter IMM_S     = 2'b10;
  parameter IMM_J     = 2'b11;

  // CSR BIT FIELDS //
  parameter CSR_CARRY    = 0;
  parameter CSR_OVERFLOW = 1;
  parameter CSR_SIGN     = 2;
  parameter CSR_ZERO     = 3;

  // JMP MUX IN EX STAGE // branch_mux signal
  parameter NO_BRANCH         = 2'b00;
  parameter BRANCH_IF_EQUAL   = 2'b01;
  parameter BRANCH_IF_EQUAL_N = 2'b10;
  parameter BRANC_IF_SIGN     = 2'b11;

  // REGISTER WDATA MUX IN WB STAGE //
  parameter WDATA_MUX_WIDTH = 1;
  parameter WDATA_ALU = 1'b0;
  parameter WDATA_MEM = 1'b1;


// type definition
typedef struct {
  logic                        reg_we;
  logic  [WDATA_MUX_WIDTH-1:0] wdata_mux;
  logic       [ADDR_WIDTH-1:0] dest_reg;
} id2wb_t;

typedef struct {
  id2wb_t                      id_stage;
  logic       [DATA_WIDTH-1:0] alu_result;
} ex2wb_t;

typedef struct {
  ex2wb_t                      ex_stage;
  logic       [DATA_WIDTH-1:0] mem_data;
} mem2wb_t;

typedef struct {
  logic            [31:0] pc;
  logic             [1:0] branch_mux;
  logic            [31:0] branch_addr;
  logic  [DATA_WIDTH-1:0] mem_wdata;
  logic                   mem_we;
//  logic  [DATA_WIDTH-1:0] data_a;
//  logic  [DATA_WIDTH-1:0] data_b;
} id2mem_t;

typedef struct {
  id2mem_t                id_stage;
  logic  [DATA_WIDTH-1:0] alu_result;
  logic   [CSR_WIDTH-1:0] alu_csr;
  ex2wb_t                 wb_pipeline;
} ex2mem_t;

typedef struct {
  logic  [DATA_WIDTH-1:0]   imm;
  logic  [DATA_WIDTH-1:0]   alu_data_a;
  logic  [DATA_WIDTH-1:0]   alu_data_b;
  logic  [ALU_OP_WIDTH-1:0] alu_op;
  id2mem_t                  mem_pipeline;
  ex2wb_t                   wb_pipeline;
} id2ex_t;

//typedef enum logic [ALU_OP_WIDTH-1:0]
//{
//
// ALU_ADD   = 7'b0011000,
// ALU_SUB   = 7'b0011001,
// ALU_ADDU  = 7'b0011010,
// ALU_SUBU  = 7'b0011011,
// ALU_ADDR  = 7'b0011100,
// ALU_SUBR  = 7'b0011101,
// ALU_ADDUR = 7'b0011110,
// ALU_SUBUR = 7'b0011111,
//
// ALU_XOR   = 7'b0101111,
// ALU_OR    = 7'b0101110,
// ALU_AND   = 7'b0010101,
//
//// Shifts
// ALU_SRA   = 7'b0100100,
// ALU_SRL   = 7'b0100101,
// ALU_ROR   = 7'b0100110,
// ALU_SLL   = 7'b0100111,
//
//// bit manipulation
// ALU_BEXT  = 7'b0101000,
// ALU_BEXTU = 7'b0101001,
// ALU_BINS  = 7'b0101010,
// ALU_BCLR  = 7'b0101011,
// ALU_BSET  = 7'b0101100,
// ALU_BREV  = 7'b1001001,
//
//// Bit counting
// ALU_FF1   = 7'b0110110,
// ALU_FL1   = 7'b0110111,
// ALU_CNT   = 7'b0110100,
// ALU_CLB   = 7'b0110101,
//
//// Sign-/zero-extensions
// ALU_EXTS  = 7'b0111110,
// ALU_EXT   = 7'b0111111,
//
//// Comparisons
// ALU_LTS   = 7'b0000000,
// ALU_LTU   = 7'b0000001,
// ALU_LES   = 7'b0000100,
// ALU_LEU   = 7'b0000101,
// ALU_GTS   = 7'b0001000,
// ALU_GTU   = 7'b0001001,
// ALU_GES   = 7'b0001010,
// ALU_GEU   = 7'b0001011,
// ALU_EQ    = 7'b0001100,
// ALU_NE    = 7'b0001101,
//
//// Set Lower Than operations
// ALU_SLTS  = 7'b0000010,
// ALU_SLTU  = 7'b0000011,
// ALU_SLETS = 7'b0000110,
// ALU_SLETU = 7'b0000111,
//
//// Absolute value
// ALU_ABS   = 7'b0010100,
// ALU_CLIP  = 7'b0010110,
// ALU_CLIPU = 7'b0010111,
//
//// Insert/extract
// ALU_INS   = 7'b0101101,
//
//// min/max
// ALU_MIN   = 7'b0010000,
// ALU_MINU  = 7'b0010001,
// ALU_MAX   = 7'b0010010,
// ALU_MAXU  = 7'b0010011,
//
//// div/rem
// ALU_DIVU  = 7'b0110000, // bit 0 is used for signed mode, bit 1 is used for remdiv
// ALU_DIV   = 7'b0110001, // bit 0 is used for signed mode, bit 1 is used for remdiv
// ALU_REMU  = 7'b0110010, // bit 0 is used for signed mode, bit 1 is used for remdiv
// ALU_REM   = 7'b0110011, // bit 0 is used for signed mode, bit 1 is used for remdiv
//
// ALU_SHUF  = 7'b0111010,
// ALU_SHUF2 = 7'b0111011,
// ALU_PCKLO = 7'b0111000,
// ALU_PCKHI = 7'b0111001
//
//} alu_opcode_e;

endpackage : riscv_cpu_pkg