module data_mem import tb_pkg::*;
(
  input  logic                          clk_i,

  input  logic                          en_i,
  input  logic    [DATA_ADDR_WIDTH-1:0] addr_i,
  input  logic    [DATA_WORD_WIDTH-1:0] wdata_i,
  output logic    [DATA_WORD_WIDTH-1:0] rdata_o,
  input  logic                          we_i
);

  localparam N_BYTES = 2 ** DATA_ADDR_WIDTH;

  logic   [7:0]                 mem[N_BYTES];
  logic   [DATA_ADDR_WIDTH-1:0] addr_int;

  assign addr_int = {addr_i[31:2], 2'b00};

  always @(posedge clk_i) begin
    if (en_i) begin
      if (we_i) begin
        mem[addr_int    ]  <= wdata_i[ 7: 0];
        mem[addr_int + 1]  <= wdata_i[15: 8];
        mem[addr_int + 2]  <= wdata_i[23:16];
        mem[addr_int + 3]  <= wdata_i[31:24];
      end
      else begin
        rdata_o[ 7: 0]  <= mem[addr_int    ];
        rdata_o[15: 8]  <= mem[addr_int + 1];
        rdata_o[23:16]  <= mem[addr_int + 2];
        rdata_o[31:24]  <= mem[addr_int + 3];
      end
    end
  end

endmodule : data_mem