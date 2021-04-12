module core
#(
) (
  // Clock and Reset
  input  logic        clk_i,
  input  logic        rst_ni,

  // Instruction memory interface
  output logic        instr_req_o,
  input  logic        instr_gnt_i,
  input  logic        instr_rvalid_i,
  output logic [31:0] instr_addr_o,
  input  logic [31:0] instr_rdata_i,

  // Data memory interface
  output logic        data_req_o,
  input  logic        data_gnt_i,
  input  logic        data_rvalid_i,
  output logic        data_we_o,
  output logic [3:0]  data_be_o,
  output logic [31:0] data_addr_o,
  output logic [31:0] data_wdata_o,
  input  logic [31:0] data_rdata_i,

  // Interrupt inputs
  input  logic [31:0] irq_i,
  output logic        irq_ack_o,
  output logic [4:0]  irq_id_o,

  // Debug Interface
  input  logic        fetch_enable_i,
  input  logic [31:0] boot_addr_i
  // input  logic        debug_req_i,
  // output logic        debug_havereset_o,
  // output logic        debug_running_o,
  // output logic        debug_halted_o,
);

  // IF signals
  logic [31:0]           if_instr_rdata;
  logic [1:0]            if_cu_pc_mux;
  logic                  if_branch_taken;
  logic [31:0]           if_branch_addr;
  logic                  if_jal_op;

  // ID signals
  logic [31:0]           id_instr_rdata;
  logic [31:0]           id_pc;
  logic [ADDR_WIDTH-1:0] id_waddr_a;
  logic [DATA_WIDTH-1:0] id_wdata_a;
  logic                  id_we_a;

  // EX signals
  logic [31:0]           ex_instr_rdata;
  logic [31:0]           ex_pc;
  logic [DATA_WIDTH-1:0] ex_data_a;
  logic [DATA_WIDTH-1:0] ex_data_b;
  logic                  ex_alu_op;
  logic [31:0]           ex_branch_addr;
  logic [1:0]            ex_branch_mux;

  // MEM signals
  logic [31:0]           mem_instr_rdata;
  logic [31:0]           mem_pc;
  logic [DATA_WIDTH-1:0] mem_data_a;
  logic [DATA_WIDTH-1:0] mem_data_b;
  logic [DATA_WIDTH-1:0] mem_alu_result;
  logic [CSR_WIDTH-1:0]  mem_alu_csr;
  logic [31:0]           mem_branch_addr;
  logic [1:0]            mem_branch_mux;

  // WB signals
  logic [31:0]           wb_instr_rdata;
  logic [DATA_WIDTH-1:0] wb_alu_result;
  logic [DATA_WIDTH-1:0] wb_mem_data;
  logic [ADDR_WIDTH-1:0] wb_waddr_a;
  logic [DATA_WIDTH-1:0] wb_wdata_a;
  logic                  wb_we_a;

  
  assign if_instr_rdata = instr_rdata_i;

  assign id_we_a    = wb_we_a;
  assign id_wdata_a = wb_wdata_a;
  assign id_waddr_a = wb_waddr_a;

  //////////////////////////////////////////////////
  //   ___ _____   ____ _____  _    ____ _____    //
  //  |_ _|  ___| / ___|_   _|/ \  / ___| ____|   //
  //   | || |_    \___ \ | | / _ \| |  _|  _|     //
  //   | ||  _|    ___) || |/ ___ \ |_| | |___    //
  //  |___|_|     |____/ |_/_/   \_\____|_____|   //
  //                                              //
  //////////////////////////////////////////////////
  if_stage #(
  ) if_stage_i (
    .clk_i             (clk_i),
    .rst_ni            (rst_ni),

    .instr_rdata_i     (if_instr_rdata),
    .instr_addr_o      (instr_addr_o),
    .branch_addr_i     (if_branch_addr),

    .jal_op_i          (if_jal_op),

    .cu_pc_mux_i       (if_cu_pc_mux),
    .branch_taken_i    (if_branch_taken),
    .boot_addr_i       (boot_addr_i),

    .instr_rdata_id_o  (id_instr_rdata),
    .pc_if_o           (id_pc)
  );

  /////////////////////////////////////////////////
  //   ___ ____    ____ _____  _    ____ _____   //
  //  |_ _|  _ \  / ___|_   _|/ \  / ___| ____|  //
  //   | || | | | \___ \ | | / _ \| |  _|  _|    //
  //   | || |_| |  ___) || |/ ___ \ |_| | |___   //
  //  |___|____/  |____/ |_/_/   \_\____|_____|  //
  //                                             //
  /////////////////////////////////////////////////
  id_stage #(
  ) id_stage_i (
    .clk_i            (clk_i),
    .rst_ni           (rst_ni),

    .instr_rdata_i    (id_instr_rdata),
    .pc_id_i          (id_pc),

    .waddr_a_i        (id_waddr_a),
    .wdata_a_i        (id_wdata_a),
    .we_a_i           (id_we_a),

    .pc_mux_o         (if_cu_pc_mux),

    .data_a_o         (ex_data_a),
    .data_b_o         (ex_data_b),
    .alu_op_o         (ex_alu_op),
    .pc_id_o          (ex_pc),
    .instr_rdata_o    (ex_instr_rdata),
    .branch_addr_o    (ex_branch_addr),
    .branch_mux_o     (ex_branch_mux),
    .jal_op_o         (if_jal_op)
  );

  /////////////////////////////////////////////////////
  //   _______  __  ____ _____  _    ____ _____      //
  //  | ____\ \/ / / ___|_   _|/ \  / ___| ____|     //
  //  |  _|  \  /  \___ \ | | / _ \| |  _|  _|       //
  //  | |___ /  \   ___) || |/ ___ \ |_| | |___      //
  //  |_____/_/\_\ |____/ |_/_/   \_\____|_____|     //
  //                                                 //
  /////////////////////////////////////////////////////
  ex_stage #(
  ) ex_stage_i (
    .clk_i             (clk_i),
    .rst_ni            (rst_ni),

    .instr_rdata_i     (ex_instr_rdata),
    .pc_ex_i           (ex_pc),
    .data_a_i          (ex_data_a),
    .data_b_i          (ex_data_b),
    .alu_op_i          (ex_alu_op),
    .branch_addr_i     (ex_branch_addr),
    .branch_mux_i      (ex_branch_mux),

    .pc_ex_o           (mem_pc),
    .instr_rdata_o     (mem_instr_rdata),
    .data_a_o          (mem_data_a),
    .data_b_o          (mem_data_b),
    .alu_result_o      (mem_alu_result),
    .csr_o             (mem_alu_csr),
    .branch_addr_o     (mem_branch_addr),
    .branch_mux_o      (mem_branch_mux)
  );

  ////////////////////////////////////////////////////////////////////////////////////////
  //    _     ___    _    ____    ____ _____ ___  ____  _____   _   _ _   _ ___ _____   //
  //   | |   / _ \  / \  |  _ \  / ___|_   _/ _ \|  _ \| ____| | | | | \ | |_ _|_   _|  //
  //   | |  | | | |/ _ \ | | | | \___ \ | || | | | |_) |  _|   | | | |  \| || |  | |    //
  //   | |__| |_| / ___ \| |_| |  ___) || || |_| |  _ <| |___  | |_| | |\  || |  | |    //
  //   |_____\___/_/   \_\____/  |____/ |_| \___/|_| \_\_____|  \___/|_| \_|___| |_|    //
  //                                                                                    //
  ////////////////////////////////////////////////////////////////////////////////////////

  mem_stage #(
  ) mem_stage_i (
    .clk_i             (clk_i),
    .rst_ni            (rst_ni),

    .instr_rdata_i     (mem_instr_rdata),
    .pc_mem_i          (mem_pc),
    .data_a_i          (mem_data_a),
    .data_b_i          (mem_data_b),
    .alu_result_i      (mem_alu_result),
    .alu_csr_i         (mem_alu_csr),
    .branch_addr_i     (mem_branch_addr),
    .jmp_mux_i         (mem_branch_mux),

    .instr_rdata_o     (wb_instr_rdata),
    .alu_result_o      (wb_alu_result),
    .mem_data_o        (wb_mem_data),
    .branch_addr_o     (if_branch_addr),
    .taken_o           (if_branch_taken),

    .data_req_o        (data_req_o),
    .data_gnt_i        (data_gnt_i),
    .data_rvalid_i     (data_rvalid_i),
    .data_addr_o       (data_addr_o),
    .data_we_o         (data_we_o),
    .data_wdata_o      (data_wdata_o),
    .data_rdata_i      (data_rdata_i)
  );
  

  /////////////////////////////////////////////////////
  //   _  _  ____   ____ _____  _    ____ _____      //
  //  | || ||  __| | ___|_   _|/ \  / ___| ____|     //
  //  | || || |__| \___ \ | | / _ \| |  _|  _|       //
  //  | || || |  |  ___) || |/ ___ \ |_| | |___      //
  //  |____||____| |____/ |_/_/   \_\____|_____|     //
  //                                                 //
  /////////////////////////////////////////////////////
  wb_stage #(
  ) wb_stage_i (
    .clk_i             (clk_i),
    .rst_ni            (rst_ni),

    .instr_rdata_i     (wb_instr_rdata),
    .alu_result_i      (wb_alu_result),
    .mem_data_i        (wb_mem_data),

    .wdata_o           (wb_wdata_a),
    .dest_reg_o        (wb_waddr_a),
    .we_o              (wb_we_a)
  );