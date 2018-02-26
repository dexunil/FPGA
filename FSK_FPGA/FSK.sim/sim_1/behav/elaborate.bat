@echo off
set xv_path=D:\\program_file\\Xilinx\\Vivado\\2015.4\\bin
call %xv_path%/xelab  -wto 3256dda551e44dd6bbd9fced7dfd9f7f -m64 --debug typical --relax --mt 2 -L xbip_utils_v3_0_5 -L axi_utils_v2_0_1 -L fir_compiler_v7_2_5 -L xil_defaultlib -L xbip_pipe_v3_0_1 -L xbip_bram18k_v3_0_1 -L mult_gen_v12_0_10 -L xbip_dsp48_wrapper_v3_0_4 -L xbip_dsp48_addsub_v3_0_1 -L xbip_dsp48_multadd_v3_0_1 -L dds_compiler_v6_0_11 -L unisims_ver -L unimacro_ver -L secureip --snapshot simu_behav xil_defaultlib.simu xil_defaultlib.glbl -log elaborate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
