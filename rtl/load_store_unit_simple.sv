module load_store_unit_simple import riscv_cpu_pkg::*;
#(
) (
  input  logic                   clk_i,
  input  logic                   rst_ni,

  // Interface to data memory
  output logic                   data_req_o,
  input  logic                   data_gnt_i,
  input  logic                   data_rvalid_i,
  output logic  [DATA_WIDTH-1:0] data_addr_o,
  output logic                   data_we_o,
  output logic             [3:0] data_be_o,
  output logic  [DATA_WIDTH-1:0] data_wdata_o,
  input  logic  [DATA_WIDTH-1:0] data_rdata_i,

  // Signals from MEM stage
//  input  logic                   mem_req_i,        // data request                      -> from ex stage
  input  logic                   mem_we_i,         // write enable                      -> from ex stage
//  input  logic             [1:0] mem_data_type_i,  // Data type word, halfword, byte    -> from ex stage
  input  logic  [DATA_WIDTH-1:0] mem_wdata_i,      // data to write to memory           -> from ex stage
//  input  logic                   mem_load_event_i, // load event                        -> from ex stage
  input  logic            [31:0] mem_addr_i,
  output logic  [DATA_WIDTH-1:0] mem_rdata_o      // requested data                    -> to ex stage
);

  assign data_addr_o  = mem_addr_i;
  assign data_we_o    = mem_we_i;
  assign data_wdata_o = mem_wdata_i;
  assign data_be_o    = 4'hF; // assign based on mem_data_type
  assign data_req_o   = 1'b1;

  assign mem_rdata_o = data_rdata_i;

endmodule