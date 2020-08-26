clear all;
close all;
clc;
path = 'D:\LoRaPrj\data';
% path = 'F:\YH_PRJ\LoRa_MAC';
NumSample = 327680;
[Y] = GetRxData(path,NumSample);
% plot(real(Y(1,1:1000)));
BW = 250e3;     % 7.8, 10.4, 15.6, 20.8, 31.2, 41.7, 62.5, 125(-132dbm), 250(-129dbm), 500(-126dbm)
SF = 12;             % range from 6 to 12
Fc = 1.2e6; 

parity_num = 4;

CR = 4/(4 + parity_num);           % code rate

byte_num = 6;
info_bit_num = 8 * byte_num;
code_num = info_bit_num / CR;        %the number of codeword

load('Bits.mat');
% bits = randn(1,info_bit_num) > 0;     % randomly generate information
[code_bit] = HammingCode(parity_num,bits);

%% InterleaveCode
[interLeave_codeword,cOld_length] = Interleavecode(code_bit,parity_num,SF);

%% Modulation
[IQdata,symbol_num] = Modulation(interLeave_codeword,SF,BW);
%% Demod
[c_recovered] = Demod(Y,SF,BW,symbol_num);
% [c_recovered] = Demod(IQdata,SF,BW,symbol_num);
test_out = find(interLeave_codeword ~= c_recovered);
%% DeInterleavecode
[codeword_old] = DeInterleavecode(c_recovered,cOld_length,parity_num,SF);

%% Decode (Hamming)
[source_code] = HammingDecode(parity_num,codeword_old);

test = (source_code - bits);
BER = sum(abs(test))/length(test)
% max(test)