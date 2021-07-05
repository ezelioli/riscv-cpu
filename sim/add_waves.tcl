add wave /tb_top/clk
add wave /tb_top/rst_n
add wave /tb_top/c_fetch_enable
add wave /tb_top/c_boot_addr

# # instruction memory
# add wave -group instr_mem /tb_top/i_instr_mem/*

# data memory
add wave -group data_mem /tb_top/i_data_mem/*
add wave -group data_mem /tb_top/i_data_mem/mem

# core
add wave -group c_instr_mem /tb_top/i_core/instr_*
add wave -group c_data_mem /tb_top/i_core/data_*
add wave -group c_interrupt /tb_top/i_core/irq_*

add wave -group core /tb_top/i_core/*

add wave -group "if" /tb_top/i_core/if_stage_i/*
add wave -group "id" /tb_top/i_core/id_stage_i/*
add wave -group "ex" /tb_top/i_core/ex_stage_i/*
add wave -group "mem" /tb_top/i_core/mem_stage_i/*
add wave -group "wb" /tb_top/i_core/wb_stage_i/*