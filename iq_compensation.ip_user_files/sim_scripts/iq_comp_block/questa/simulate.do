onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib iq_comp_block_opt

do {wave.do}

view wave
view structure
view signals

do {iq_comp_block.udo}

run -all

quit -force
