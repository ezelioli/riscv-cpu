module load_store_unit import riscv_cpu_pkg::*;
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
  output logic                 [3:0]  data_be_o,
  output logic      [DATA_WIDTH-1:0]  data_wdata_o,
  input  logic      [DATA_WIDTH-1:0]  data_rdata_i,

  // Signals from MEM stage
  input  logic                        data_we_ex_i,         // write enable                      -> from ex stage
  input  logic                 [1:0]  data_type_ex_i,       // Data type word, halfword, byte    -> from ex stage
  input  logic      [DATA_WIDTH-1:0]  data_wdata_ex_i,      // data to write to memory           -> from ex stage
  input  logic                 [1:0]  data_reg_offset_ex_i, // offset inside register for stores -> from ex stage
  input  logic                        data_load_event_ex_i, // load event                        -> from ex stage

  output logic      [DATA_WIDTH-1:0]  data_rdata_ex_o,      // requested data                    -> to ex stage
  input  logic                        data_req_ex_i,        // data request                      -> from ex stage
  input  logic      [DATA_WIDTH-1:0]  operand_a_ex_i,       // operand a from RF for address     -> from ex stage
  input  logic      [DATA_WIDTH-1:0]  operand_b_ex_i        // operand b from RF for address     -> from ex stage

);

endmodule