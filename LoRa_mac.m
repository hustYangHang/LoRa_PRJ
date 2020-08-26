clear all;
close all;
clc;
%% LoRa Communication Protocol
% all_round_time = 1000;
% BER = ones(all_round_time,1);
% SNR = 0;
% f = waitbar(0,'Please wait...');
% for round_time = 1:all_round_time
% try
%% Parameter  Setting
BW = 250e3;     % 7.8, 10.4, 15.6, 20.8, 31.2, 41.7, 62.5, 125(-132dbm), 250(-129dbm), 500(-126dbm)
SF = 12;             % range from 6 to 12
Fc = 1.2e6; 

parity_num = 4;

CR = 4/(4 + parity_num);           % code rate

byte_num = 6;
info_bit_num = 8 * byte_num;
code_num = info_bit_num / CR;        %the number of codeword

%% EnCoding (Hamming)
bits = randn(1,info_bit_num) > 0;     % randomly generate information
[code_bit] = HammingCode(parity_num,bits);

%% InterleaveCode
[interLeave_codeword,cOld_length] = Interleavecode(code_bit,parity_num,SF);

%% Modulation
[IQdata,symbol_num] = Modulation(interLeave_codeword,SF,BW);

% value_max = max ( max(real(IQdata)) , max(real(IQdata)) );
% IQdata = IQdata / value_max;
% IQdata = IQdata * 2^15;                         %让DAC满量程
% 
% fp = fopen('WaveFormImag.txt','w+');     %以写的方式打开指定路径下的.txt文件
% fprintf(fp,'%d\n',imag(IQdata));               %把数据竖地写入.txt文件
% fclose(fp);
% 
% fp = fopen('WaveFormReal.txt','w+');      %以写的方式打开指定路径下的.txt文件
% fprintf(fp,'%d\n',real(IQdata));                  %把数据竖地写入.txt文件
% fclose(fp);
% save Bits.mat bits

%% Add PLoRa Modulation

%% Add channel
Tpkt = length(IQdata)/BW;
IQ_delay = [zeros(1,(floor(Tpkt)/2)*BW + 1) IQdata];
IQ_channel = awgn(IQ_delay,SNR,'measured');

%% Demod
[c_recovered] = Demod(IQ_channel,SF,BW,symbol_num);
sum(abs(c_recovered - interLeave_codeword))/length(c_recovered)
%% Add PLoRa Demod


%% DeInterleavecode
[codeword_old] = DeInterleavecode(c_recovered,cOld_length,parity_num,SF);
sum(abs(codeword_old - code_bit))/length(codeword_old)
%% Decode (Hamming)
[source_code] = HammingDecode(parity_num,codeword_old);
sum(abs(source_code - bits))/length(source_code)
% test1 = (c_recovered - interLeave_codeword);
% test2 = (codeword_old - code_bit);
% test3 = (source_code - bits);
% [max(test1) max(test2) max(test3)]
% BER(round_time,1) = sum(abs(test3))/length(test3);
% ['BER = ' num2str(BER)];
% disp('run success!');

% waitbar(round_time/all_round_time,f,'generating your data');
% end
% end
% close(f);
% PER = 1 - length(find(BER == 0))/length(BER)
% save BER.mat BER
