module instr_mem import tb_pkg::*;
(
  input  logic                          clk_i,

  input  logic                          en_i,
  input  logic   [INSTR_ADDR_WIDTH-1:0] addr_i,
  output logic   [INSTR_WORD_WIDTH-1:0] rdata_o
);

  //localparam N_BYTES = 2 ** INSTR_ADDR_WIDTH;
  localparam N_BYTES = 2 ** 12;

  logic                    [7:0] mem[N_BYTES];
  logic   [INSTR_ADDR_WIDTH-1:0] addr_int;

  assign addr_int = {addr_i[31:2], 2'b00};

  initial begin
    int i;
    for(i = 0; i < 2 ** 12; ++i) begin
      mem[i] = '0;
    end
    $readmemh(INSTR_INIT_FILE, mem);
  end

  always_comb begin
    if(en_i) begin
      rdata_o[ 7: 0] = mem[addr_int    ];
      rdata_o[15: 8] = mem[addr_int + 1];
      rdata_o[23:16] = mem[addr_int + 2];
      rdata_o[31:24] = mem[addr_int + 3];
    end else begin
      rdata_o = '0;
    end
  end

endmodule : instr_mem