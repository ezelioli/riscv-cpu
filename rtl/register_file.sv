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

  logic [DATA_WIDTH-1:0] registers [NUM_WORDS-1:0];

  logic [NUM_WORDS-1:0] we_a_dec;

  generate
    genvar j;
    for(j = 0; j < NUM_WORDS; j++) begin
      assign we_a_dec[j] = (j == waddr_a_i) ? we_a_i : 1'b0;
    end
  endgenerate

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (~rst_ni) begin
      registers[0] <= 32'b0;
    end else begin
      registers[0] <= 32'b0;
    end
  end

  generate
    genvar i;
    for(i = 1; i < NUM_WORDS; i++) begin
      always @(posedge clk_i or negedge rst_ni) begin
        if(~rst_ni) begin
          registers[i] <= '0;
        end else if(we_a_dec[i] == 1'b1) begin
          registers[i] = wdata_a_i;
        end
      end
    end
  endgenerate

  always_comb begin // allow sigle cycle read/write to avoid hazards from wb stage
    rdata_a_o = registers[raddr_a_i];
    rdata_b_o = registers[raddr_b_i];
    if(we_a_i == 1'b1) begin
      if(waddr_a_i == raddr_a_i) begin
        rdata_a_o = wdata_a_i;
      end
      if(waddr_a_i == raddr_b_i) begin
        rdata_b_o = wdata_a_i;
      end
    end
  end

  // assign rdata_a_o = registers[raddr_a_i];
  // assign rdata_b_o = registers[raddr_b_i];

endmodule