module alu import riscv_cpu_pkg::*;
#(
) (
  input  logic  [DATA_WIDTH-1:0] 		data_a_i,
  input  logic  [DATA_WIDTH-1:0] 		data_b_i,
  input  logic  [ALU_OP_WIDTH-1:0]  op_i,

  output logic  [DATA_WIDTH-1:0] 		data_o
);

// ALU result mux //
always_comb begin
	data_o = '0;
	unique case(op_i)
    ALU_ADD:  data_o = data_a_i + data_b_i;
    ALU_SUB:  data_o = data_a_i - data_b_i;
    ALU_XOR:  data_o = data_a_i ^ data_b_i;
		ALU_AND:  data_o = data_a_i & data_b_i;
    ALU_OR :  data_o = data_a_i | data_b_i;
    ALU_SLT:  data_o = (data_a_i - data_b_i) < 0 ? 1 : 0;
    ALU_SLTU: data_o = (data_a_i - data_b_i) < 0 ? 1 : 0;
    ALU_SLL:  data_o = data_a_i << data_b_i[4:0];
    ALU_SRL:  data_o = data_a_i >> data_b_i[4:0];
    ALU_SRA:  data_o = data_a_i >> data_b_i[4:0];
	endcase
end

endmodule : alu