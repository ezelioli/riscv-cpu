module forwarding_unit import riscv_cpu_pkg::*;
#(
) (
  input  logic clk_i,
  input  logic rst_ni,

  // detect hazard for JALR
  input  logic [ADDR_WIDTH-1:0] id_raddr_a_i,
  
  // detect hazard for ALU OPs
  input  logic [ADDR_WIDTH-1:0] ex_raddr_a_i,
  input  logic [ADDR_WIDTH-1:0] ex_raddr_b_i,
  input  logic                  ex_data_a_reg_i,
  input  logic                  ex_data_b_reg_i,
  
  input  logic [ADDR_WIDTH-1:0] ex_dest_reg_i,
  input  logic [ADDR_WIDTH-1:0] mem_dest_reg_i,
  input  logic [ADDR_WIDTH-1:0] wb_dest_reg_i,

  input  logic ex_reg_we_i,
  input  logic mem_reg_we_i,
  input  logic wb_reg_we_i,

  input  logic jalr_op_i,
  input  logic mem_wb_mux_i,

  output logic [ALU_DATA_A_MUX_WIDTH-1:0] alu_data_a_mux_o,
  output logic [ALU_DATA_B_MUX_WIDTH-1:0] alu_data_b_mux_o,

  output logic [JALR_RDATA_MUX_WIDTH-1:0] jalr_rdata_mux_o,

  output logic stall_id_o,
  output logic stall_ex_o
);

  logic stall_id; // jalr bubble
  logic stall_ex; // ld bubble

  logic is_load_mem;

  assign is_load_mem = (mem_wb_mux_i == WDATA_MEM) ? 1'b1 : 1'b0;

  always_comb begin
    jalr_rdata_mux_o = JALR_RDATA_REG;
    if(((id_raddr_a_i == mem_dest_reg_i && mem_reg_we_i) && jalr_op_i) && mem_dest_reg_i != '{ADDR_WIDTH{1'b0}}) begin
      jalr_rdata_mux_o = JALR_RDATA_MEM;
    end // not checking for wb stage as assuming same cycle write/read of register file
  end

  always_comb begin
    alu_data_a_mux_o = ALU_DATA_A_REG;
    if(((ex_raddr_a_i == mem_dest_reg_i && mem_reg_we_i) && ex_data_a_reg_i) && mem_dest_reg_i != '{ADDR_WIDTH{1'b0}}) begin
      alu_data_a_mux_o = ALU_DATA_A_MEM;
    end else if(((ex_raddr_a_i == wb_dest_reg_i && wb_reg_we_i) && ex_data_a_reg_i) && wb_dest_reg_i != '{ADDR_WIDTH{1'b0}}) begin
      alu_data_a_mux_o = ALU_DATA_A_WB;
    end

    alu_data_b_mux_o = ALU_DATA_B_REG;
    if(((ex_raddr_b_i == mem_dest_reg_i && mem_reg_we_i) && ex_data_b_reg_i) && mem_dest_reg_i != '{ADDR_WIDTH{1'b0}}) begin
      alu_data_b_mux_o = ALU_DATA_B_MEM;
    end else if(((ex_raddr_b_i == wb_dest_reg_i && wb_reg_we_i) && ex_data_a_reg_i) && wb_dest_reg_i != '{ADDR_WIDTH{1'b0}}) begin
      alu_data_b_mux_o = ALU_DATA_B_WB;
    end
  end

  always_comb begin
    stall_id = '0;
    stall_ex = '0;
    if(((id_raddr_a_i == ex_dest_reg_i && ex_reg_we_i) && jalr_op_i) && ex_dest_reg_i != '{ADDR_WIDTH{1'b0}}) begin
      stall_id = 1'b1;
    end
    if((((ex_raddr_a_i == mem_dest_reg_i || ex_raddr_b_i == mem_dest_reg_i) && mem_reg_we_i) && is_load_mem) && mem_dest_reg_i != '{ADDR_WIDTH{1'b0}}) begin
      stall_id = 1'b1;
      stall_ex = 1'b1;
    end
  end

  assign stall_id_o = stall_id;
  assign stall_ex_o = stall_ex;

endmodule : forwarding_unit