`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/01/31 10:39:35
// Design Name: 
// Module Name: FSK_mod
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


module FSK_mod(
    clk,
    //rst,
    din,
    dout_5M,
    dout8_5M,
    dout_all
    );
    input clk;
  //  input rst;
  // h = 3.5,fc=6.75MHz,Rb = 1MHz,f1 = 5MHz,f2 = 8.5MHz
    input din;
    output signed [15:0]dout_5M;
    output signed [15:0]dout8_5M;
    output signed [15:0]dout_all;
    wire signed [15:0]sine_5M;
    wire signed [15:0]sine8_5M;
    dds_compiler_0 u0 (
      .aclk(clk),                              // input wire aclk
      .m_axis_data_tvalid(m_axis_data_tvalid),  // output wire m_axis_data_tvalid
      .m_axis_data_tdata(sine_5M)    // output wire [15 : 0] m_axis_data_tdata
    );
    dds_compiler_1 u1 (
      .aclk(clk),                              // input wire aclk
      .m_axis_data_tvalid(nouse),  // output wire m_axis_data_tvalid
      .m_axis_data_tdata(sine8_5M)    // output wire [15 : 0] m_axis_data_tdata
    );
    reg signed[15:0] temp;
    always@(posedge clk)
    begin
        if(din == 0)
            temp <= sine_5M;
        else
            temp <= sine8_5M;
    end
    
    assign dout_5M = sine_5M;
    assign dout_all = temp;
    assign dout8_5M = sine8_5M;
endmodule
