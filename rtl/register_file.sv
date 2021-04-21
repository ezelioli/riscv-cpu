module register_file import riscv_cpu_pkg::*;
#(
) (
  input  logic                  clk_i,
  input  logic                  rst_ni,

  //Read port R1
  input  logic [ADDR_WIDTH-1:0]  raddr_a_i,
  output logic [DATA_WIDTH-1:0]  rdata_a_o,

  //Read port R2
  input  logic [ADDR_WIDTH-1:0]  raddr_b_i,
  output logic [DATA_WIDTH-1:0]  rdata_b_o,

  // Write port W1
  input logic [ADDR_WIDTH-1:0]   waddr_a_i,
  input logic [DATA_WIDTH-1:0]   wdata_a_i,
  input logic                    we_a_i
);
  
  localparam NUM_WORDS = 2 ** ADDR_WIDTH;

  logic [NUM_WORDS-1:0][DATA_WIDTH-1:0] mem_d, mem_q;

  always_comb begin
    mem_d = mem_q;
    if(we_a_i == 1'b1) begin
      mem_d[waddr_a_i] = wdata_a_i;
    end
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin : proc_mem_q
    if(~rst_ni) begin
      mem_q <= '0;
    end else begin
      mem_q <= mem_d;
    end
  end

  assign rdata_a_o = mem_q[raddr_a_i[ADDR_WIDTH-1:0]];
  assign rdata_b_o = mem_q[raddr_b_i[ADDR_WIDTH-1:0]];

endmodule