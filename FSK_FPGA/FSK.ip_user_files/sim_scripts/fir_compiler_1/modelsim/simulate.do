onbreak {quit -f}
onerror {quit -f}

vsim -voptargs="+acc" -t 1ps -L secureip -L xbip_utils_v3_0_5 -L axi_utils_v2_0_1 -L fir_compiler_v7_2_5 -L xil_defaultlib -lib xil_defaultlib xil_defaultlib.fir_compiler_1

do {wave.do}

view wave
view structure
view signals

do {fir_compiler_1.udo}

run -all

quit -force
