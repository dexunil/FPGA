`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/02/01 13:54:58
// Design Name: 
// Module Name: simu
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


module simu(

    );
    reg clk = 0;
    always #10 clk = ~clk;
    reg din = 0;
    always #1000 din = ~din;  
    wire signed [15:0]dout_5M;
    wire signed [15:0]dout8_5M;
    wire signed [15:0]dout_all;
    FSK_mod myFskMod(
    .clk(clk),
    //rst,
    .din(din),
    .dout_5M(dout_5M),
    .dout8_5M(dout8_5M),
    .dout_all(dout_all)    
    );
    wire signed[39:0] fir_4to6_out,fir_8to9_out;
    wire signed[15:0] fir_4to6_16,fir_8to9_16;
    wire signed[15:0]abs_fir_4to6_16,abs_fir_8to9_16;
    wire signed [39:0] fir_lowpass0,fir_lowpass1;
    wire signed [39:0] fir_lowpass0_look,fir_lowpass1_look;
    wire signed [15:0] fir_lowpass0_16,fir_lowpass1_16;
    FSK_demod myFskDmod(
    .clk(clk),
    .mod_data(dout_all),
    .fir_4to6(fir_4to6_out),
    .fir_8to9(fir_8to9_out),
    .abs_fir_4to6_16(abs_fir_4to6_16),
    .abs_fir_8to9_16(abs_fir_8to9_16),
    .fir_lowpass0(fir_lowpass0),
    .fir_lowpass1(fir_lowpass1)
    );
    assign fir_4to6_16 = fir_4to6_out[39:24];
    assign fir_8to9_16 = fir_8to9_out[39:24];
    
    assign fir_lowpass0_16 = fir_lowpass0[39:24];
    assign fir_lowpass1_16 = fir_lowpass1[39:24];
    
    assign fir_lowpass0_look = fir_lowpass0;
    assign fir_lowpass1_look = fir_lowpass1;
    
    reg signed[39:0] sub;
    always@(posedge clk)
    begin
        sub <= fir_lowpass0 - fir_lowpass1;
    end
    wire  signed[39:0] sub_look;
    wire signed[15:0] sub_look_16;
    assign sub_look = sub;
    assign sub_look_16 = sub[39:24];
    
endmodule
