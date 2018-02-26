`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/02/01 16:53:37
// Design Name: 
// Module Name: FSK_demod
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module FSK_demod(
    clk,
    mod_data,
    fir_4to6,
    fir_8to9,
    abs_fir_4to6_16,
    abs_fir_8to9_16,
    fir_lowpass0,
    fir_lowpass1
    );
    input clk;
    input signed[15:0] mod_data;
    output [39:0]fir_4to6,fir_8to9;
    output signed [15:0] abs_fir_4to6_16,abs_fir_8to9_16;
    output signed [39:0] fir_lowpass0,fir_lowpass1;
    wire signed[15:0]fir_4to6_16,fir_8to9_16;
    wire s_axis_data_tvalid=1; 
    wire signed[39:0] fir_4to6_out,fir_8to9_out;
    wire bandpassOK;
    fir_compiler_0 bandpass_4to6 (
      .aclk(clk),                              // input wire aclk
      .s_axis_data_tvalid(s_axis_data_tvalid),  // input wire s_axis_data_tvalid
      .s_axis_data_tready(s_axis_data_tready),  // output wire s_axis_data_tready
      .s_axis_data_tdata(mod_data),    // input wire [15 : 0] s_axis_data_tdata
      .m_axis_data_tvalid(bandpassOK),  // output wire m_axis_data_tvalid
      .m_axis_data_tdata(fir_4to6_out)    // output wire [39 : 0] m_axis_data_tdata
    );
    fir_compiler_1 bandpass_8to9 (
      .aclk(clk),                              // input wire aclk
      .s_axis_data_tvalid(s_axis_data_tvalid),  // input wire s_axis_data_tvalid
      .s_axis_data_tready(s_axis_data_tready),  // output wire s_axis_data_tready
      .s_axis_data_tdata(mod_data),    // input wire [15 : 0] s_axis_data_tdata
      .m_axis_data_tvalid(m_axis_data_tvalid),  // output wire m_axis_data_tvalid
      .m_axis_data_tdata(fir_8to9_out)    // output wire [39 : 0] m_axis_data_tdata
    );
    
    assign fir_4to6 = fir_4to6_out;
    assign fir_8to9 = fir_8to9_out;
    
    assign fir_4to6_16 = fir_4to6_out[39:24];
    assign fir_8to9_16 = fir_8to9_out[39:24];
    
   reg signed [15:0] abs_fir_4to6_16_reg,abs_fir_8to9_16_reg;
    //abs
    always@(posedge clk)
    begin
        if(fir_4to6_16[15])
            abs_fir_4to6_16_reg <= -fir_4to6_16;
        else
            abs_fir_4to6_16_reg <= fir_4to6_16;
        if(fir_8to9_16[15])
            abs_fir_8to9_16_reg <= -fir_8to9_16;
        else 
            abs_fir_8to9_16_reg <= fir_8to9_16;         
     end
     assign abs_fir_4to6_16 = abs_fir_4to6_16_reg;
     assign abs_fir_8to9_16 = abs_fir_8to9_16_reg;
    //µÍÍ¨ÂË²¨
    wire signed [39 : 0] fir_lowpass0_out,fir_lowpass1_out;

    fir_compiler_2 lowpass0 (
      .aclk(clk),                              // input wire aclk
      .s_axis_data_tvalid(bandpassOK),  // input wire s_axis_data_tvalid
      .s_axis_data_tready(s_axis_data_tready),  // output wire s_axis_data_tready
      .s_axis_data_tdata(abs_fir_4to6_16),    // input wire [15 : 0] s_axis_data_tdata
      .m_axis_data_tvalid(m_axis_data_tvalid),  // output wire m_axis_data_tvalid
      .m_axis_data_tdata(fir_lowpass0_out)    // output wire [39 : 0] m_axis_data_tdata
    );
    
       fir_compiler_2 lowpass1 (
      .aclk(clk),                              // input wire aclk
      .s_axis_data_tvalid(bandpassOK),  // input wire s_axis_data_tvalid
      .s_axis_data_tready(s_axis_data_tready),  // output wire s_axis_data_tready
      .s_axis_data_tdata(abs_fir_8to9_16),    // input wire [15 : 0] s_axis_data_tdata
      .m_axis_data_tvalid(m_axis_data_tvalid),  // output wire m_axis_data_tvalid
      .m_axis_data_tdata(fir_lowpass1_out)    // output wire [39 : 0] m_axis_data_tdata
    );
    assign fir_lowpass0 = fir_lowpass0_out;
    assign fir_lowpass1 = fir_lowpass1_out;
endmodule
