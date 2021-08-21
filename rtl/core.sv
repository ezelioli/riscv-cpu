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
  logic [31:0]           if_branch_addr;
  logic [31:0]           if_jal_addr;
  logic                  if_jal_op;

  // ID signals
  logic [31:0]           id_instr_rdata;
  logic [31:0]           id_pc;
  // logic [ADDR_WIDTH-1:0] id_waddr_a;
  logic [DATA_WIDTH-1:0] id_wdata_a;
  // logic                  id_we_a;
  logic [ADDR_WIDTH-1:0] id_raddr_a;
  logic                  id_jalr_op;

  // EX signals
  logic [ADDR_WIDTH-1:0] ex_reg_raddr_a;
  logic [ADDR_WIDTH-1:0] ex_reg_raddr_b;
  logic                  ex_data_a_reg;
  logic                  ex_data_b_reg;
  logic [ADDR_WIDTH-1:0] ex_dest_reg;
  logic                  ex_reg_we;
  ex_ctl_t ex_ex_ctl;
  mem_ctl_t ex_mem_ctl;
  wb_ctl_t ex_wb_ctl;
  id2ex_t ex_pipeline;

  // MEM signals
  logic                  mem_branch_taken;
  logic [ADDR_WIDTH-1:0] mem_dest_reg;
  logic                  mem_reg_we;
  logic [WDATA_MUX_WIDTH-1:0] mem_wb_mux;
  logic [DATA_WIDTH-1:0] mem_alu_result;
  mem_ctl_t mem_mem_ctl;
  wb_ctl_t mem_wb_ctl;
  ex2mem_t mem_pipeline;

  // WB signals
  logic [ADDR_WIDTH-1:0] wb_dest_reg;
  logic                  wb_reg_we;
  logic [DATA_WIDTH-1:0] wb_mem_data;
  wb_ctl_t wb_wb_ctl;
  mem2wb_t wb_pipeline;

  // Forwarding Unit signals
  logic [ALU_DATA_A_MUX_WIDTH-1:0] fu_alu_data_a_mux;
  logic [ALU_DATA_A_MUX_WIDTH-1:0] fu_alu_data_b_mux;
  logic [JALR_RDATA_MUX_WIDTH-1:0] fu_jalr_rdata_mux;
  logic                            fu_stall_id;
  logic                            fu_stall_ex;

  
  // TO BE IMPLEMENTED
  assign irq_ack_o = 1'b0;
  assign irq_id_o = 1'b0;

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
    .instr_req_o       (instr_req_o),
    .instr_addr_o      (instr_addr_o),
    .branch_addr_i     (if_branch_addr),
    .jal_addr_i        (if_jal_addr),
    .jal_op_i          (if_jal_op),

    .stall_id_i        (fu_stall_id),

    .cu_pc_mux_i       (if_cu_pc_mux),
    .branch_taken_i    (mem_branch_taken),
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

    .waddr_a_i        (wb_dest_reg),
    .wdata_a_i        (id_wdata_a),
    .we_a_i           (wb_reg_we),

    .pc_mux_o         (if_cu_pc_mux),
    .jal_op_o         (if_jal_op),
    .jal_addr_o       (if_jal_addr),

    .branch_taken_i   (mem_branch_taken),
    .stall_ex_i       (fu_stall_ex),

    .jalr_rdata_mux_i (fu_jalr_rdata_mux),
    .alu_result_i     (mem_alu_result),
    .raddr_a_o        (id_raddr_a),
    .jalr_op_o        (id_jalr_op),

    .ex_ctl_o         (ex_ex_ctl),
    .mem_ctl_o        (ex_mem_ctl),
    .wb_ctl_o         (ex_wb_ctl),

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

    .ex_ctl_i          (ex_ex_ctl),
    .mem_ctl_i         (ex_mem_ctl),
    .wb_ctl_i          (ex_wb_ctl),

    .mem_ctl_o         (mem_mem_ctl),
    .wb_ctl_o          (mem_wb_ctl),

    .branch_taken_i    (mem_branch_taken),
    .clear_ex_i        (fu_stall_ex),

    .ex_pipeline_i     (ex_pipeline),

    .mem_pipeline_o    (mem_pipeline),

    .alu_result_i      (mem_alu_result),
    .mem_data_i        (wb_mem_data),

    .alu_data_a_mux_i  (fu_alu_data_a_mux),
    .alu_data_b_mux_i  (fu_alu_data_b_mux),

    .reg_raddr_a_o     (ex_reg_raddr_a),
    .reg_raddr_b_o     (ex_reg_raddr_b),
    .data_a_reg_o      (ex_data_a_reg),
    .data_b_reg_o      (ex_data_b_reg),
    .dest_reg_o        (ex_dest_reg),
    .reg_we_o          (ex_reg_we)
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

    .mem_ctl_i         (mem_mem_ctl),
    .wb_ctl_i          (mem_wb_ctl),

    .wb_ctl_o          (wb_wb_ctl),

    .mem_pipeline_i    (mem_pipeline),

    .wb_pipeline_o     (wb_pipeline),

    .branch_addr_o     (if_branch_addr),
    .taken_o           (mem_branch_taken),
    .alu_result_o      (mem_alu_result),

    .dest_reg_o        (mem_dest_reg),
    .reg_we_o          (mem_reg_we),
    .wb_mux_o          (mem_wb_mux),

    .data_req_o        (data_req_o),
    .data_gnt_i        (data_gnt_i),
    .data_rvalid_i     (data_rvalid_i),
    .data_addr_o       (data_addr_o),
    .data_we_o         (data_we_o),
    .data_be_o         (data_be_o),
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

    .wb_ctl_i          (wb_wb_ctl),

    .wb_pipeline_i     (wb_pipeline),

    .wdata_o           (id_wdata_a),
    .dest_reg_o        (wb_dest_reg),
    .we_o              (wb_reg_we),
    .mem_data_o        (wb_mem_data)
  );

  /////////////////////////////////////////////////////
  //                Forwarding Unit                  //
  /////////////////////////////////////////////////////
  forwarding_unit #(
  ) forwarding_unit_i (
    .clk_i           (clk_i),
    .rst_ni          (rst_ni),

    .id_raddr_a_i    (id_raddr_a),
    .ex_raddr_a_i    (ex_reg_raddr_a),
    .ex_raddr_b_i    (ex_reg_raddr_b),
    .ex_data_a_reg_i (ex_data_a_reg),
    .ex_data_b_reg_i (ex_data_b_reg),

    .ex_dest_reg_i   (ex_dest_reg),
    .mem_dest_reg_i  (mem_dest_reg),
    .wb_dest_reg_i   (wb_dest_reg),

    .ex_reg_we_i     (ex_reg_we),
    .mem_reg_we_i    (mem_reg_we),
    .wb_reg_we_i     (wb_reg_we),

    .jalr_op_i       (id_jalr_op),
    .mem_wb_mux_i    (mem_wb_mux),

    .alu_data_a_mux_o(fu_alu_data_a_mux),
    .alu_data_b_mux_o(fu_alu_data_b_mux),
    .jalr_rdata_mux_o(fu_jalr_rdata_mux),

    .stall_id_o      (fu_stall_id),
    .stall_ex_o      (fu_stall_ex)
  );

endmodule : core