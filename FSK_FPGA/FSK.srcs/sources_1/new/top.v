`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/02/06 09:47:06
// Design Name: 
// Module Name: top
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


module top(
    input sys_clk
    );
    
    
    reg din = 0;
    reg [6:0]count = 0;
    //always #800 din <= ~din;
    always@(posedge sys_clk)
    begin
        if(count==7'd50)
        begin
            din <= ~din;
            count <= 7'd0;
        end
        else
            count <= count + 1;
            
    end
    

    (*MARK_DEBUT="TRUE"*)wire signed [15:0]dout_5M;
    (*MARK_DEBUT="TRUE"*)wire signed [15:0]dout8_5M;
    (*MARK_DEBUT="TRUE"*) wire signed [15:0]dout_all;    
    FSK_mod myFskMod(
    .clk(sys_clk),
    //rst,
    .din(din),
    .dout_5M(dout_5M),
    .dout8_5M(dout8_5M),
    .dout_all(dout_all)    
    );
    
    
    (*MARK_DEBUT="TRUE"*)wire signed[39:0] fir_4to6_out,fir_8to9_out;
    (*MARK_DEBUT="TRUE"*)wire signed[15:0]abs_fir_4to6_16,abs_fir_8to9_16;
    (*MARK_DEBUT="TRUE"*)wire signed [39:0] fir_lowpass0,fir_lowpass1;

    FSK_demod myFskDmod(
    .clk(sys_clk),
    .mod_data(dout_all),
    .fir_4to6(fir_4to6_out),
    .fir_8to9(fir_8to9_out),
    .abs_fir_4to6_16(abs_fir_4to6_16),
    .abs_fir_8to9_16(abs_fir_8to9_16),
    .fir_lowpass0(fir_lowpass0),
    .fir_lowpass1(fir_lowpass1)
    );
    
    
    
    
    
    
    
    reg signed[39:0] sub;
    (*MARK_DEBUT="TRUE"*)wire signed[39:0] sub_look;
    always@(posedge sys_clk)
    begin
        sub <= fir_lowpass0 - fir_lowpass1;
    end
    assign sub_look = sub;
    
    ila_0 aa0 (
        .clk(sys_clk), // input wire clk
    
    
        .probe0(dout_all), // input wire [15:0]  probe0  
        .probe1(sub_look) // input wire [39:0]  probe1
    );
endmodule
