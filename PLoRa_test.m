clear all;
close all;
clc;
BW = 250e3;     % 7.8, 10.4, 15.6, 20.8, 31.2, 41.7, 62.5, 125(-132dbm), 250(-129dbm), 500(-126dbm)
SF = 12;             % range from 6 to 12
Fc = 1.2e6; 

parity_num = 4;

CR = 4/(4 + parity_num);           % code rate

byte_num = 6;
info_bit_num = 8 * byte_num;
code_num = info_bit_num / CR;        %the number of codeword

% load('Bits.mat');
bits = randn(1,info_bit_num) > 0;     % randomly generate information
[code_bit] = HammingCode(parity_num,bits);

%% InterleaveCode
[interLeave_codeword,cOld_length] = Interleavecode(code_bit,parity_num,SF);

%% Modulation
[IQdata,symbol_num] = Modulation(interLeave_codeword,SF,BW);

Backscatter_data = [zeros(1,8) randi([0,1],1,symbol_num)];% 前8个是preamble，不进行反射
PLoRa_data = [];
for i = 1 : 8 + symbol_num   
    PLoRa_data = [PLoRa_data circshift( IQdata(1,((i - 1) * 2^SF) + 1:i * 2^SF), [1,Backscatter_data(i)*2^SF/2])];
end
Y = IQdata + PLoRa_data;
%% Demod
% [c_recovered] = Demod(Y(1,2.5*32768 + 1:ceil(4.1*32768)),SF,BW,symbol_num);
[c_recovered] = DemodPLoRa(Y,SF,BW,symbol_num);

test = (c_recovered - Backscatter_data);
BER = sum(abs(test))/length(test)
% IQdata = [ IQdata, PLoRa_data ];