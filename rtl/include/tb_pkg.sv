package tb_pkg;

  // INSTRUCTION MEMORY
  parameter INSTR_ADDR_WIDTH      = 32;
  parameter INSTR_WORD_WIDTH      = 32;
  parameter INSTR_INIT_FILE         = "../rtl/tb/instructions.mem";
  parameter INSTR_CONTENT_LENGTH  = 11; 
  parameter INSTR_MEM_CONTENT     = { 8'h93, 8'h02, 8'h10, 8'h00, // addi x5, x0, 1
                                      8'h00, 8'h00, 8'h00, 8'h00,
                                      8'h00, 8'h00, 8'h00, 8'h00,
                                      8'h00, 8'h00, 8'h00, 8'h00,
                                      8'h00, 8'h00, 8'h00, 8'h00,
                                      8'h23, 8'h20, 8'h50, 8'h00, // sw x0, x5, 0
                                      8'h00, 8'h00, 8'h00, 8'h00,
                                      8'hEF, 8'h00, 8'h00, 8'h00, // jal x1, 0
                                      8'h00, 8'h00, 8'h00, 8'h00,
                                      8'h00, 8'h00, 8'h00, 8'h00,
                                      8'h00, 8'h00, 8'h00, 8'h00,
                                      8'h00, 8'h00, 8'h00, 8'h00
                                    };

  // DATA MEMORY
  parameter DATA_ADDR_WIDTH      = 32;
  parameter DATA_WORD_WIDTH      = 32;

  // CORE PARAMS
  parameter BOOT_ADDRESS         = 31'h00000000;

endpackage : tb_pkg