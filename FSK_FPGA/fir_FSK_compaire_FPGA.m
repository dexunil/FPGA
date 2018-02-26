clc;
clear;
close all;
fclose('all');
%% ����CSV�ļ���ȡ��Χ������ȡһ�е����˲�ǰ����
srow = 1;       %��ʼ��(�б��0��ʼ);
erow = 1024;    %������(һ��Ϊ�������);
scol =5;       %��ʼ��(�б��0��ʼ);(�б��0��ʼ);(�б��0��ʼ);(�б��0��ʼ);(�б��0��ʼ);
ecol = scol;      %������;
%% ��ȡcsv�ļ�
[filename, pathname] = uigetfile('D:\FPGA\Vivado\ASK_mod_demod\test.csv','��ȡ����');
csv_file  = [pathname filename];
%% ��ȡcsv�ļ�
csv_data = csvread(csv_file,srow,scol,[srow,scol,erow,ecol]);
%% ��������Ϊһ��
csv_data_resp = reshape(csv_data',[],1);
s=num2str(csv_data_resp,'%012d');
% %% ����ת��Ϊ�������ı�
% csv_data_str = num2str(csv_data_resp);
% %% ����ת��Ϊ��16λ�з�����
% csv_data_sign = typecast(uint16(bin2dec(csv_data_str)), 'int16');
%% ������λ�����ж������ǲ���ת����������
n = length(s);
abs_mod = zeros(n,1);
m = length(s(1,:));
for i=1:n
   sign_is = bin2dec( s(i,1) ); % ����

if sign_is == 1
    abs_mod(i) = bin2dec(s(i,:))-2^m;
else
    abs_mod(i) = bin2dec(s(i,:));
end
end
%% ��ȡFPGA�˲������� 
%%��16λ
srow = 1;       %��ʼ��(�б��0��ʼ);
erow = 1024;    %������(һ��Ϊ�������);
scol =7;       %��ʼ��(�б��0��ʼ);(�б��0��ʼ);(�б��0��ʼ);(�б��0��ʼ);(�б��0��ʼ);
ecol = scol;      %������;

after_fir_low16 = csvread(csv_file,srow,scol,[srow,scol,erow,ecol]);
after_fir_low16_resp = reshape(after_fir_low16',[],1);
s_after_fir_low16=num2str(after_fir_low16_resp,'%016d');
%%��16λ
srow = 1;       %��ʼ��(�б��0��ʼ);
erow = 1024;    %������(һ��Ϊ�������);
scol =8;       %��ʼ��(�б��0��ʼ);(�б��0��ʼ);(�б��0��ʼ);(�б��0��ʼ);(�б��0��ʼ);
ecol = scol;      %������;

after_fir_high16 = csvread(csv_file,srow,scol,[srow,scol,erow,ecol]);
after_fir_high16_resp = reshape(after_fir_high16',[],1);
s_after_fir_high16=num2str(after_fir_high16_resp,'%016d');
%%ƴ��
hang = length(s_after_fir_low16(:,1));
m = length(s_after_fir_low16(1,:))*2;%2�������λ��
for i=1:hang
    highlow(i,:) = [s_after_fir_high16(i,:),s_after_fir_low16(i,:)];
end
%% ����ʹ�õĽ���16λ�������
after_fir_high = zeros(hang,1);
for i = 1:hang
     sign_high =  bin2dec( s_after_fir_high16(i,1) ); % ����
     if sign_high == 1
         after_fir_high(i) = bin2dec(s_after_fir_high16(i,:))-2^16;
    else
        after_fir_high(i) = bin2dec(s_after_fir_high16(i,:));
    end         
end
%���ֵ
for i = 1:hang-201
    sum_high(i) = sum(after_fir_high(i:i+201));
    mean_high(i) = sum_high(i)/201;
end
%% �õ�FPGA��������ݣ������ɸ���
after_fir_highlow = zeros(hang,1);
for i = 1:hang
    sign_is =  bin2dec( highlow(i,1) ); % ����
    if sign_is == 1
        after_fir_highlow(i) = bin2dec(highlow(i,:))-2^m;
    else
        after_fir_highlow(i) = bin2dec(highlow(i,:));
    end
end
%% �������ݣ�֮ǰ�Ѿ�����FPGA�˲�ǰ������abs_mod������ֻ����˲���ϵ��
%% �˲���ϵ�� FIR_coe_complement�Ѹ��������˲���,FIR_coe�Ǵ���������
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
%% ���
conv_matlab=filter(FIR_coe,1,abs_mod);
%% ����ʱ�ӵĴ��ڣ���Ҫ������
 plot(conv_matlab)
 hold on
 plot(after_fir_highlow,'r')