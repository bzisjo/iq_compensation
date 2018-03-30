onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+iq_comp_block -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.iq_comp_block xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {iq_comp_block.udo}

run -all

endsim

quit -force
