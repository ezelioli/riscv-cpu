package tb_pkg;

  // INSTRUCTION MEMORY
  parameter INSTR_ADDR_WIDTH      = 32;
  parameter INSTR_WORD_WIDTH      = 32;
  parameter INSTR_MEM_CONTENT     = [ 8'h00, 8'h00, 8'h00, 8'h00, 
                                      8'h00, 8'h00, 8'h00, 8'h00,
                                      8'h00, 8'h00, 8'h00, 8'h00,
                                      8'h00, 8'h00, 8'h00, 8'h00,
                                      8'h00, 8'h00, 8'h00, 8'h00,
                                      8'h00, 8'h00, 8'h00, 8'h00,
                                      8'h00, 8'h00, 8'h00, 8'h00,
                                      8'h00, 8'h00, 8'h00, 8'h00,
                                      8'h00, 8'h00, 8'h00, 8'h00,
                                      8'h00, 8'h00, 8'h00, 8'h00,
                                      8'h00, 8'h00, 8'h00, 8'h00,
                                      8'h00, 8'h00, 8'h00, 8'h00,
                                    ];

  // DATA MEMORY
  parameter DATA_ADDR_WIDTH      = 32;
  parameter DATA_WORD_WIDTH      = 32;

  // CORE PARAMS
  parameter BOOT_ADDRESS         = 31'h00000000;

endpackage : tb_pkg