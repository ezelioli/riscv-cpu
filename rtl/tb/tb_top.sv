module tb_top import tb_pkg;
();


  const time CLK_PHASE_HI         = 5ns;
  const time CLK_PHASE_LO         = 5ns;
  const time CLK_PERIOD           = CLK_PHASE_HI + CLK_PHASE_LO;
  const time STIM_APPLICATION_DEL = CLK_PERIOD * 0.1;
  const time RESP_ACQUISITION_DEL = CLK_PERIOD * 0.9;
  const int  RESET_WAIT_CYCLES    = 4;
  const int  SIMULATION_CYCLES    = 1000;

  logic clk;
  logic rst_n;

  // CORE INTERFACE SIGNALS
  logic                        c_instr_req    ;
  logic                        c_instr_gnt    ;
  logic                        c_instr_rvalid ;
  logic [INSTR_ADDR_WIDTH-1:0] c_instr_addr   ;
  logic [INSTR_WORD_WIDTH-1:0] c_instr_rdata  ;
  logic                        c_data_req     ;
  logic                        c_data_gnt     ;
  logic                        c_data_rvalid  ;
  logic                        c_data_we      ;
  logic                  [3:0] c_data_be      ;
  logic  [DATA_ADDR_WIDTH-1:0] c_data_addr    ;
  logic  [DATA_WORD_WIDTH-1:0] c_data_wdata   ;
  logic  [DATA_WORD_WIDTH-1:0] c_data_rdata   ;
  logic                 [31:0] c_irq          ;
  logic                        c_irq_ack      ;
  logic                  [4:0] c_irq_id       ;
  logic                        c_fetch_enable ;
  logic                 [31:0] c_boot_addr    ;

  // INSTRUCTION MEMORY INTERFACE SIGNALS
  logic                        im_en    ;
  logic [INSTR_ADDR_WIDTH-1:0] im_addr  ;
  logic [INSTR_WORD_WIDTH-1:0] im_rdata ;

  // DATA MEMORY INTERFACE SIGNALS
  logic                       dm_en    ;
  logic [DATA_ADDR_WIDTH-1:0] dm_addr  ;
  logic [DATA_WORD_WIDTH-1:0] dm_wdata ;
  logic [DATA_WORD_WIDTH-1:0] dm_rdata ;
  logic                       dm_we    ;

  assign c_instr_gnt    = 1'b1;
  assign c_instr_rvalid = 1'b1;
  assign c_data_gnt     = 1'b1;
  assign c_data_rvalid  = 1'b1;
  assign c_irq          = 32'b0;
  assign c_fetch_enable = 1'b1;
  assign c_boot_addr    = BOOT_ADDRESS;

  assign im_en          = 1'b1;
  assign dm_en          = 1'b1;

  assign c_instr_rdata  = im_rdata;
  assign c_data_rdata   = dm_rdata;
  assign im_addr        = c_instr_addr;
  assign dm_we          = c_data_we;
  assign dm_addr        = c_data_addr;
  assign dm_wdata       = c_data_wdata;


  initial begin: clock_gen
      
      forever begin
          #CLK_PHASE_HI clk = 1'b0;
          #CLK_PHASE_LO clk = 1'b1;
      end
  
  end: clock_gen


  initial begin: reset_gen

    $timeformat(-9, 0, "ns", 9);
    rst_n = 1'b0;
    
    // wait a few cycles
    repeat (RESET_WAIT_CYCLES) begin
        @(posedge clk);
    end
    
    // start running
    rst_n = 1'b1;
    $display("reset deasserted", $time);

    repeat (SIMULATION_CYCLES) begin
      @(posedge clk);
    end

    $display("Simulation terminated after %d cycles", SIMULATION_CYCLES);
    $stop();
  
  end: reset_gen


  core i_core (
    .clk_i           ( clk            ),
    .rst_ni          ( rst_n          ),

    .instr_req_o     ( c_instr_req    ),
    .instr_gnt_i     ( c_instr_gnt    ),
    .instr_rvalid_i  ( c_instr_rvalid ),
    .instr_addr_o    ( c_instr_addr   ),
    .instr_rdata_i   ( c_instr_rdata  ),

    .data_req_o      ( c_data_req     ),
    .data_gnt_i      ( c_data_gnt     ),
    .data_rvalid_i   ( c_data_rvalid  ),
    .data_we_o       ( c_data_we      ),
    .data_be_o       ( c_data_be      ),
    .data_addr_o     ( c_data_addr    ),
    .data_wdata_o    ( c_data_wdata   ),
    .data_rdata_i    ( c_data_rdata   ),

    .irq_i           ( c_irq          ),
    .irq_ack_o       ( c_irq_ack      ),
    .irq_id_o        ( c_irq_id       ),

    .fetch_enable_i  ( c_fetch_enable ),
    .boot_addr_i     ( c_boot_addr    )
  );


  instr_mem i_instr_mem (
    .clk_i           ( clk      ),
    .en_i            ( im_en    ),
    .addr_i          ( im_addr  ),
    .rdata_o         ( im_rdata )
  );


  data_mem i_data_mem (
    .clk_i           ( clk      ),
    .en_i            ( dm_en    ),
    .addr_i          ( dm_addr  ),
    .wdata_i         ( dm_wdata ),
    .rdata_o         ( dm_rdata ),
    .we_i            ( dm_we    )
  );

endmodule : tb_top