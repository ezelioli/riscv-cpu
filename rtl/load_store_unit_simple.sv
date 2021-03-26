module load_store_unit_simple import riscv_cpu_pkg::*;
#(
) (
  input  logic                        clk_i,
  input  logic                        rst_ni,

  // Output to data memory
  output logic                        data_req_o,
  input  logic                        data_gnt_i,
  input  logic                        data_rvalid_i

  output logic      [DATA_WIDTH-1:0]  data_addr_o,
  output logic                        data_we_o,
  output logic      [DATA_WIDTH-1:0]  data_wdata_o,
  input  logic      [DATA_WIDTH-1:0]  data_rdata_i

  // MEM pipeline stage interface
  input  logic                   data_we_mem_i,         // write enable                      -> from ex stage
  input  logic [1:0]             data_type_mem_i,       // Data type word, halfword, byte    -> from ex stage
  input  logic [DATA_WIDTH-1:0]  data_wdata_mem_i,      // data to write to memory           -> from ex stage
  input  logic                   data_load_event_mem_i, // load event                        -> from ex stage

  output logic [DATA_WIDTH-1:0]  data_rdata_mem_o,      // requested data                    -> to ex stage
  input  logic                   data_req_mem_i         // data request                      -> from ex stage
  input  logic [DATA_WIDTH-1:0]  operand_a_mem_i,       // operand a from RF for address     -> from ex stage
  input  logic [DATA_WIDTH-1:0]  operand_b_mem_i,       // operand b from RF for address     -> from ex stage

);

  assign data_addr_o  = operand_a_mem_i;
  assign data_wdata_o = data_wdata_mem_i;
  assign data_req_o   = data_req_mem_i;
  assign data_we_o    = data_we_mem_i;

  assign data_rdata_mem_o = data_rdata_i;

endmodule