onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /iq_comp_testbench/RESETn
add wave -noupdate -radix unsigned /iq_comp_testbench/sample_count
add wave -noupdate -format Analog-Step -height 74 -max 15.0 -min 1.0 -radix unsigned /iq_comp_testbench/Ix
add wave -noupdate -format Analog-Step -height 74 -max 14.000000000000002 -min 2.0 -radix unsigned /iq_comp_testbench/Qx
add wave -noupdate /iq_comp_testbench/freeze_iqcomp
add wave -noupdate /iq_comp_testbench/op_mode
add wave -noupdate /iq_comp_testbench/clk_16MHz
add wave -noupdate -format Analog-Step -height 74 -max 6.0 -min -8.0 -radix decimal /iq_comp_testbench/Iy
add wave -noupdate -format Analog-Step -height 74 -max 6.0 -min -8.0 -radix decimal /iq_comp_testbench/Qy
add wave -noupdate /iq_comp_testbench/i_thread
add wave -noupdate /iq_comp_testbench/q_thread
add wave -noupdate /iq_comp_testbench/i_out_thread
add wave -noupdate /iq_comp_testbench/q_out_thread
add wave -noupdate -format Analog-Step -height 74 -max 6.0 -min -8.0 -radix decimal /iq_comp_testbench/DUT/I_math
add wave -noupdate -format Analog-Step -height 74 -max 6.0 -min -8.0 -radix decimal /iq_comp_testbench/DUT/Q_math
add wave -noupdate -format Analog-Step -height 74 -max 2871.0 -min -53.0 -radix decimal -childformat {{{/iq_comp_testbench/DUT/Wr[12]} -radix decimal} {{/iq_comp_testbench/DUT/Wr[11]} -radix decimal} {{/iq_comp_testbench/DUT/Wr[10]} -radix decimal} {{/iq_comp_testbench/DUT/Wr[9]} -radix decimal} {{/iq_comp_testbench/DUT/Wr[8]} -radix decimal} {{/iq_comp_testbench/DUT/Wr[7]} -radix decimal} {{/iq_comp_testbench/DUT/Wr[6]} -radix decimal} {{/iq_comp_testbench/DUT/Wr[5]} -radix decimal} {{/iq_comp_testbench/DUT/Wr[4]} -radix decimal} {{/iq_comp_testbench/DUT/Wr[3]} -radix decimal} {{/iq_comp_testbench/DUT/Wr[2]} -radix decimal} {{/iq_comp_testbench/DUT/Wr[1]} -radix decimal} {{/iq_comp_testbench/DUT/Wr[0]} -radix decimal}} -subitemconfig {{/iq_comp_testbench/DUT/Wr[12]} {-height 15 -radix decimal} {/iq_comp_testbench/DUT/Wr[11]} {-height 15 -radix decimal} {/iq_comp_testbench/DUT/Wr[10]} {-height 15 -radix decimal} {/iq_comp_testbench/DUT/Wr[9]} {-height 15 -radix decimal} {/iq_comp_testbench/DUT/Wr[8]} {-height 15 -radix decimal} {/iq_comp_testbench/DUT/Wr[7]} {-height 15 -radix decimal} {/iq_comp_testbench/DUT/Wr[6]} {-height 15 -radix decimal} {/iq_comp_testbench/DUT/Wr[5]} {-height 15 -radix decimal} {/iq_comp_testbench/DUT/Wr[4]} {-height 15 -radix decimal} {/iq_comp_testbench/DUT/Wr[3]} {-height 15 -radix decimal} {/iq_comp_testbench/DUT/Wr[2]} {-height 15 -radix decimal} {/iq_comp_testbench/DUT/Wr[1]} {-height 15 -radix decimal} {/iq_comp_testbench/DUT/Wr[0]} {-height 15 -radix decimal}} /iq_comp_testbench/DUT/Wr
add wave -noupdate -format Analog-Step -height 74 -max 1494.0 -min -402.0 -radix decimal /iq_comp_testbench/DUT/Wj
add wave -noupdate -radix decimal /iq_comp_testbench/DUT/Wr_math
add wave -noupdate -radix decimal /iq_comp_testbench/DUT/Wj_math
add wave -noupdate /iq_comp_testbench/clk_16MHz
add wave -noupdate -radix decimal -childformat {{{/iq_comp_testbench/DUT/Ix_s[3]} -radix decimal} {{/iq_comp_testbench/DUT/Ix_s[2]} -radix decimal} {{/iq_comp_testbench/DUT/Ix_s[1]} -radix decimal} {{/iq_comp_testbench/DUT/Ix_s[0]} -radix decimal}} -subitemconfig {{/iq_comp_testbench/DUT/Ix_s[3]} {-height 15 -radix decimal} {/iq_comp_testbench/DUT/Ix_s[2]} {-height 15 -radix decimal} {/iq_comp_testbench/DUT/Ix_s[1]} {-height 15 -radix decimal} {/iq_comp_testbench/DUT/Ix_s[0]} {-height 15 -radix decimal}} /iq_comp_testbench/DUT/Ix_s
add wave -noupdate -radix decimal /iq_comp_testbench/DUT/Qx_s
add wave -noupdate -radix decimal /iq_comp_testbench/DUT/Wr_use
add wave -noupdate -radix decimal /iq_comp_testbench/DUT/Wj_use
add wave -noupdate -radix decimal /iq_comp_testbench/DUT/product1
add wave -noupdate -radix decimal /iq_comp_testbench/DUT/product2
add wave -noupdate -radix decimal /iq_comp_testbench/DUT/product3
add wave -noupdate -radix decimal /iq_comp_testbench/DUT/product4
add wave -noupdate -radix binary /iq_comp_testbench/DUT/sum1
add wave -noupdate -radix binary /iq_comp_testbench/DUT/shifted1
add wave -noupdate -radix decimal /iq_comp_testbench/DUT/sum2
add wave -noupdate -radix decimal /iq_comp_testbench/DUT/shifted2
add wave -noupdate -radix decimal /iq_comp_testbench/DUT/IplusQ
add wave -noupdate -radix decimal /iq_comp_testbench/DUT/IminusQ
add wave -noupdate -radix decimal /iq_comp_testbench/DUT/IQprod1
add wave -noupdate -radix decimal /iq_comp_testbench/DUT/IQprod2
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2125000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 217
configure wave -valuecolwidth 242
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits us
update
WaveRestoreZoom {1117180 ps} {2474820 ps}
