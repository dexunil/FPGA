clc;
clear;
close all;
fclose('all');
%% 设置CSV文件读取范围——读取一列的数滤波前数据
srow = 1;       %起始行(行标从0开始);
erow = 1024;    %结束行(一般为采样深度);
scol =5;       %起始列(列标从0开始);(列标从0开始);(列标从0开始);(列标从0开始);(列标从0开始);
ecol = scol;      %结束列;
%% 获取csv文件
[filename, pathname] = uigetfile('D:\FPGA\Vivado\ASK_mod_demod\test.csv','读取数据');
csv_file  = [pathname filename];
%% 读取csv文件
csv_data = csvread(csv_file,srow,scol,[srow,scol,erow,ecol]);
%% 矩阵重排为一列
csv_data_resp = reshape(csv_data',[],1);
s=num2str(csv_data_resp,'%012d');
% %% 矩阵转换为二进制文本
% csv_data_str = num2str(csv_data_resp);
% %% 矩阵转换为有16位有符号数
% csv_data_sign = typecast(uint16(bin2dec(csv_data_str)), 'int16');
%% 将符号位进行判断输入是补码转换成正负数
n = length(s);
abs_mod = zeros(n,1);
m = length(s(1,:));
for i=1:n
   sign_is = bin2dec( s(i,1) ); % 符号

if sign_is == 1
    abs_mod(i) = bin2dec(s(i,:))-2^m;
else
    abs_mod(i) = bin2dec(s(i,:));
end
end
%% 读取FPGA滤波后数据 
%%低16位
srow = 1;       %起始行(行标从0开始);
erow = 1024;    %结束行(一般为采样深度);
scol =7;       %起始列(列标从0开始);(列标从0开始);(列标从0开始);(列标从0开始);(列标从0开始);
ecol = scol;      %结束列;

after_fir_low16 = csvread(csv_file,srow,scol,[srow,scol,erow,ecol]);
after_fir_low16_resp = reshape(after_fir_low16',[],1);
s_after_fir_low16=num2str(after_fir_low16_resp,'%016d');
%%高16位
srow = 1;       %起始行(行标从0开始);
erow = 1024;    %结束行(一般为采样深度);
scol =8;       %起始列(列标从0开始);(列标从0开始);(列标从0开始);(列标从0开始);(列标从0开始);
ecol = scol;      %结束列;

after_fir_high16 = csvread(csv_file,srow,scol,[srow,scol,erow,ecol]);
after_fir_high16_resp = reshape(after_fir_high16',[],1);
s_after_fir_high16=num2str(after_fir_high16_resp,'%016d');
%%拼接
hang = length(s_after_fir_low16(:,1));
m = length(s_after_fir_low16(1,:))*2;%2个矩阵的位宽
for i=1:hang
    highlow(i,:) = [s_after_fir_high16(i,:),s_after_fir_low16(i,:)];
end
%% 调试使用的将高16位变成数字
after_fir_high = zeros(hang,1);
for i = 1:hang
     sign_high =  bin2dec( s_after_fir_high16(i,1) ); % 符号
     if sign_high == 1
         after_fir_high(i) = bin2dec(s_after_fir_high16(i,:))-2^16;
    else
        after_fir_high(i) = bin2dec(s_after_fir_high16(i,:));
    end         
end
%求均值
for i = 1:hang-201
    sum_high(i) = sum(after_fir_high(i:i+201));
    mean_high(i) = sum_high(i)/201;
end
%% 得到FPGA处理的数据，补码变成负数
after_fir_highlow = zeros(hang,1);
for i = 1:hang
    sign_is =  bin2dec( highlow(i,1) ); % 符号
    if sign_is == 1
        after_fir_highlow(i) = bin2dec(highlow(i,:))-2^m;
    else
        after_fir_highlow(i) = bin2dec(highlow(i,:));
    end
end
%% 计算数据，之前已经读入FPGA滤波前的数据abs_mod，这里只卷积滤波器系数
%% 滤波器系数 FIR_coe_complement把负数换成了补码,FIR_coe是带正负的数
Prec_F = 17;
% -------------------
% FIR_factor = [-0.0113   -0.0383    0.2632    0.5800    0.2632   -0.0383   -0.0113]';
FIR_factor = [-0.000938415527343750,0,0.00153350830078125,0.00366973876953125,0.00541687011718750,0.00483703613281250,0,-0.00935363769531250,-0.0204238891601563,-0.0272216796875000,-0.0223159790039063,0,0.0404510498046875,0.0930404663085938,0.145996093750000,0.185356140136719,0.199905395507813,0.185356140136719,0.145996093750000,0.0930404663085938,0.0404510498046875,0,-0.0223159790039063,-0.0272216796875000,-0.0204238891601563,-0.00935363769531250,0,0.00483703613281250,0.00541687011718750,0.00366973876953125,0.00153350830078125,0,-0.000938415527343750]';
FIR_coe = FIR_factor.*pow2(Prec_F);
FIR_coe = round(FIR_coe).';


for ii = 1:length(FIR_factor)
    if FIR_coe(ii) < 0
        FIR_coe_complement(ii) = 2^16-abs(FIR_coe(ii));
    else
         FIR_coe_complement(ii) = FIR_coe(ii);
    end
%     FIR_coe_Hex(ii,:) = dec2hex(FIR_coe(ii),4);
end
%% 卷积
conv_matlab=filter(FIR_coe,1,abs_mod);
%% 由于时延的存在，需要画出了
 plot(conv_matlab)
 hold on
 plot(after_fir_highlow,'r')