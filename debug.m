clear;
close all;
clc;
path = 'D:\LoRaPrj\data';
% path = 'F:\YH_PRJ\LoRa_MAC';
NumSample = 40960*2;
[Y] = GetRxData(path,NumSample);
% plot(real(Y(1,1:1000)));
BW = 250e3;     % 7.8, 10.4, 15.6, 20.8, 31.2, 41.7, 62.5, 125(-132dbm), 250(-129dbm), 500(-126dbm)
SF = 12;             % range from 6 to 125
Fc = 1.2e6; 

parity_num = 4;

CR = 4/(4 + parity_num);           % code rate

byte_num = 6;
info_bit_num = 8 * byte_num;
code_num = info_bit_num / CR;        %the number of codeword

% load('Bits.mat');
% bits = randn(1,info_bit_num) > 0;     % randomly generate information
% [code_bit] = HammingCode(parity_num,bits);

%% InterleaveCode
% [interLeave_codeword,cOld_length] = Interleavecode(code_bit,parity_num,SF);

%% Modulation
% [IQdata,symbol_num] = Modulation(interLeave_codeword,SF,BW);
%% Demod
Fs = BW;           % sample frequency
symbol_time = 2^SF / BW; 
%% Signal Genneration
t = 0: 1/Fs: (symbol_time - 1/Fs);
f0 = 0;
f1 = BW;
%% design upchirp and downchirp
% upchirp
chirpI = chirp(t, f0, symbol_time, f1, 'linear', 90);
chirpQ = chirp(t, f0, symbol_time, f1, 'linear', 0);
upChirp = complex(chirpI, chirpQ);
corr_upChirp = repmat(upChirp,1,8);
clear chirpI chirpQ
% downchirp
chirpI = chirp(t, f1, symbol_time, f0, 'linear', 90);
chirpQ = chirp(t, f1, symbol_time, f0, 'linear', 0);
downChirp = complex(chirpI, chirpQ);
clear chirpI chirpQ
corr_downChirp = repmat(downChirp,1,8);
paytest = repmat(downChirp,1,20);
IQdata = [paytest];
% Demod_data = IQdata;
Demod_data = Y;
%% Signal synchronization and cropping
[corr, lag] = xcorr(Demod_data, downChirp);
figure;plot(abs(corr));
% corrThresh = max(abs(corr));
%% Peak detect algorithm
Detectdata_field = abs(corr(1,8.1e4+1:16.1e4));
figure;plot(Detectdata_field);
corrPeak_num = 0;
%% 以下3个参数调节灵敏度
% 在维持其余参数不变时
% window_length越大，灵敏度越高；
% judge_num_max越小，灵敏度越高；
% ratio_index越小，（不超过1），灵敏度越高。
% 灵敏度的直观反映就是检测出峰值的个数，灵敏度越高，个数越少
window_length = 1000;
judge_num_max = 3;
ratio_index = 0.90;
%%
bias = mean(Detectdata_field);
max_temp = max(Detectdata_field);
% Detectdata_field = Detectdata_field - bias;
% 如果在这个窗里能找到不少于1个不多于3个和最大值接近的值，那么认为该值是一个峰值
for i = 1:length(Detectdata_field)/window_length
    window_max = max(Detectdata_field(1,(i-1)*window_length+1:i*window_length));
    judge_thresh = max(window_max*ratio_index,bias + max_temp/4);
    judge_num = length(find(Detectdata_field(1,(i-1)*window_length+1:i*window_length)>=judge_thresh));
    if (judge_num >= 1)&&(judge_num < judge_num_max)
        corrPeak_num = corrPeak_num + 1;
    end
    [corrPeak_num i judge_num judge_thresh]
    judge_num = 0;
end
if (max_temp-bias) < max_temp/2
    corrPeak_num = 100;
end
corrPeak_num
% corrPeak_num = length(find(abs(corr) >= corrThresh/3));
% detectdata_diff1 = diff(Detectdata_field);
% detectdata_diff2 = diff(detectdata_diff1);
% figure;plot(detectdata_diff1);
% figure;plot(detectdata_diff2);
% detect_sensitivity = max(detectdata_diff2)/2;
% for i = 1:4e4 - 2
%    if detectdata_diff2(1,i) > detect_sensitivity
%        corrPeak_num = corrPeak_num + 1;
%    end
% end
% corrPeak_num
