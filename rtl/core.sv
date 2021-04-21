module core import riscv_cpu_pkg::*;
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
  logic [31:0]           if_jal_addr;
  logic                  if_jal_op;

  // ID signals
  logic [31:0]           id_instr_rdata;
  logic [31:0]           id_pc;
  logic [ADDR_WIDTH-1:0] id_waddr_a;
  logic [DATA_WIDTH-1:0] id_wdata_a;
  logic                  id_we_a;

  // EX signals
  id2ex_t ex_pipeline;

  // MEM signals
  ex2mem_t mem_pipeline;

  // WB signals
  mem2wb_t wb_pipeline;

  
  assign if_instr_rdata = instr_rdata_i;


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
    .jal_addr_i        (if_jal_addr),
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
    .jal_op_o         (if_jal_op),
    .jal_addr_o       (if_jal_addr),

    .ex_pipeline_o    (ex_pipeline)
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

    .ex_pipeline_i     (ex_pipeline),

    .mem_pipeline_o    (mem_pipeline)
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

    .mem_pipeline_i    (mem_pipeline),

    .wb_pipeline_o     (wb_pipeline),

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

    .wb_pipeline_i     (wb_pipeline),

    .wdata_o           (id_wdata_a),
    .dest_reg_o        (id_waddr_a),
    .we_o              (id_we_a)
  );