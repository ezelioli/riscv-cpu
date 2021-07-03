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