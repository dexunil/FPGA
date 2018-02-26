onbreak {quit -f}
onerror {quit -f}

vsim -voptargs="+acc" -t 1ps -L secureip -L xbip_utils_v3_0_5 -L axi_utils_v2_0_1 -L xbip_pipe_v3_0_1 -L xbip_bram18k_v3_0_1 -L mult_gen_v12_0_10 -L xbip_dsp48_wrapper_v3_0_4 -L xbip_dsp48_addsub_v3_0_1 -L xbip_dsp48_multadd_v3_0_1 -L dds_compiler_v6_0_11 -L xil_defaultlib -lib xil_defaultlib xil_defaultlib.dds_compiler_0

do {wave.do}

view wave
view structure
view signals

do {dds_compiler_0.udo}

run -all

quit -force
