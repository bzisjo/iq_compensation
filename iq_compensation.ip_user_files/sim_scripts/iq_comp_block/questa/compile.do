vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xil_defaultlib

vmap xil_defaultlib questa_lib/msim/xil_defaultlib

vlog -work xil_defaultlib -64 "+incdir+../../../../iq_compensation.srcs/sources_1/bd/iq_comp_block/ipshared/5123" "+incdir+../../../../iq_compensation.srcs/sources_1/bd/iq_comp_block/ipshared/5123" \
"d:/Projects/iq_compensation/iq_compensation.srcs/sources_1/bd/iq_comp_block/ip/iq_comp_block_clk_wiz_0_0/iq_comp_block_clk_wiz_0_0_sim_netlist.v" \
"d:/Projects/iq_compensation/iq_compensation.srcs/sources_1/bd/iq_comp_block/ip/iq_comp_block_rst_clk_wiz_0_16M_0/iq_comp_block_rst_clk_wiz_0_16M_0_sim_netlist.v" \
"../../../bd/iq_comp_block/ip/iq_comp_block_iq_comp_0_0/sim/iq_comp_block_iq_comp_0_0.v" \
"../../../bd/iq_comp_block/sim/iq_comp_block.v" \


vlog -work xil_defaultlib \
"glbl.v"

