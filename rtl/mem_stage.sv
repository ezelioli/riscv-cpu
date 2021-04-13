module mem_stage import riscv_cpu_pkg::*;
#(
) (
  input  logic                   clk_i,
  input  logic                   rst_ni,

  // MEM pipeline stage interface
  input  ex2mem_t                mem_pipeline_i,
  
  // Output of MEM pipeline stage
  output mem2wb_t                wb_pipeline_o,

  // Output signals
  output logic            [31:0] branch_addr_o,

  // Signals reserved for data memory interface
  output logic                   data_req_o,
  input  logic                   data_gnt_i,
  input  logic                   data_rvalid_i,
  output logic  [DATA_WIDTH-1:0] data_addr_o,
  output logic                   data_we_o,
  output logic  [DATA_WIDTH-1:0] data_wdata_o,
  input  logic  [DATA_WIDTH-1:0] data_rdata_i

);
  
  // internal signals
  logic            [31:0] pc          ;
  logic             [1:0] branch_mux  ;
  logic            [31:0] branch_addr ;
  logic  [DATA_WIDTH-1:0] data_a      ;
  logic  [DATA_WIDTH-1:0] data_b      ;
  logic  [DATA_WIDTH-1:0] alu_result  ;
  logic   [CSR_WIDTH-1:0] alu_csr     ;

  // branch unit signals
  logic [31:0] b_pc;
  logic [CSR_WIDTH-1:0] b_csr;
  logic b_taken;
  logic [1:0] b_branch_mux;

  // load store unit signals
  logic                   lsu_req;
  logic                   lsu_we;
  logic             [1:0] lsu_data_type;
  logic  [DATA_WIDTH-1:0] lsu_wdata;
  logic                   lsu_load_event;
  logic            [31:0] lsu_addr;
  logic  [DATA_WIDTH-1:0] lsu_rdata;

  mem2wb_t wb_pipeline_d;
  mem2wb_t wb_pipeline_q;
  

  load_store_unit_simple #(
  ) load_store_unit_simple_i (
    .clk_i                    ( clk_i          ),
    .rst_ni                   ( rst_ni         ),
    .data_req_o               ( data_req_o     ),
    .data_gnt_i               ( data_gnt_i     ),
    .data_rvalid_i            ( data_rvalid_i  ),
    .data_addr_o              ( data_addr_o    ),
    .data_we_o                ( data_we_o      ),
    .data_wdata_o             ( data_wdata_o   ),
    .data_rdata_i             ( data_rdata_i   ),

    .mem_req_i                ( lsu_req        ),
    .mem_we_i                 ( lsu_we         ),
    .mem_data_type_i          ( lsu_data_type  ),
    .mem_wdata_i              ( lsu_wdata      ),
    .mem_load_event_i         ( lsu_load_event ),
    .mem_addr_i               ( lsu_addr       ),
    .mem_rdata_o              ( lsu_rdata      )
  );

  mem_branch_ctl #(
  ) mem_branch_ctl_i (
    .clk_i              (clk_i),
    .rst_ni             (rst_ni),
    .pc_i               (b_pc),
    .csr_i              (b_csr),
    .branch_mux_i       (b_branch_mux),
    .taken_o            (b_taken)
  );

  assign pc            = mem_pipeline_i.id_stage.pc;
  assign branch_mux    = mem_pipeline_i.id_stage.branch_mux;
  assign branch_addr   = mem_pipeline_i.id_stage.branch_addr;
  assign data_a        = mem_pipeline_i.id_stage.data_a;
  assign data_b        = mem_pipeline_i.id_stage.data_b;
  assign alu_result    = mem_pipeline_i.alu_result;
  assign alu_csr       = mem_pipeline_i.alu_csr;

  assign b_pc          = pc;
  assign b_csr         = alu_csr;
  assign b_branch_mux  = branch_mux;

  assign wb_pipeline_d.ex_stage = mem_pipeline_i.wb_pipeline;
  assign wb_pipeline_d.mem_data = lsu_data_rdata;

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if(~rst_ni) begin
      wb_pipeline_q     <= 0';
    end else begin
      wb_pipeline_q     <= wb_pipeline_d;
    end
  end

  assign wb_pipeline_o  = wb_pipeline_q;
  assign branch_addr_o  = branch_addr;
  assign taken_o        = b_taken;

endmodule