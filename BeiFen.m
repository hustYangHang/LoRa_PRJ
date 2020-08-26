clear all;
clc;
%% The initial debug program, all process steps in one .m file
%% Parameter  Setting
BW = 125e3;     % 7.8, 10.4, 15.6, 20.8, 31.2, 41.7, 62.5, 125, 250, 500
SF = 12;             % range from 6 to 12
Fc = 1.2e6; 
Fs = BW;           % sample frequency
symbol_time = 2^SF / BW; 

parity_num = 4;
CR = 4/(4 + parity_num);           % code rate

byte_num = 120;
info_bit_num = 8 * byte_num;
code_num = info_bit_num / CR;        %the number of codeword

 
% P = [1 1 1 0; 0 1 1 1;1 1 0 1;1 0 1 1] ;   % the matrix of parity.
% H = [eye(4); P];

%% EnCoding (Hamming)
bits = randn(1,info_bit_num) > 0;     % randomly generate information

[code_bit] = HanmingCode(parity_num,bits);

% c = code_bit;
% here should insert an interleave module
[interLeave_codeword,cOld_length] = Interleavecode(code_bit,parity_num,SF);

bit_num = length(interLeave_codeword);
symbol_num = bit_num / SF;
%% Signal Genneration
t = 0: 1/Fs: (symbol_time - 1/Fs);
f0 = 0;
f1 = BW;

% upchirp
chirpI = chirp(t, f0, symbol_time, f1, 'linear', 90);
chirpQ = chirp(t, f0, symbol_time, f1, 'linear', 0);
upChirp = complex(chirpI, chirpQ);
clear chirpI chirpQ

% downchirp
chirpI = chirp(t, f1, symbol_time, f0, 'linear', 90);
chirpQ = chirp(t, f1, symbol_time, f0, 'linear', 0);
downChirp = complex(chirpI, chirpQ);
clear chirpI chirpQ

%% modulation
CRC = 0;
IH = 0;
DE = 0;
if symbol_time > 16e-3
    DE = 1;
end
%generate preamble
% Spl = 8;% here need to redesign
Spl = 8 + max(ceil(4 * parity_num*((8 * byte_num - 4 * SF + 28 + 16 * CRC - 20 * IH)/(4 * (SF - 2 * DE)))),0);
preamble =  repmat(upChirp,1,Spl);
IQdata = preamble;
% here insert mandatory bits

symbols = reshape(interLeave_codeword, SF,  bit_num/SF);
shift_wight = [2^0,2^1,2^2,2^3,2^4,2^5,2^6,2^7,2^8,2^9,2^10,2^11];

shift_num_per_symbol = shift_wight(1 : SF) * symbols;

pay_load = [];
for i = 1 : symbol_num   
    pay_load = [pay_load circshift( downChirp,  [ 1, shift_num_per_symbol(i) ] )];
%     IQdata = [ IQdata, temp ];
end
IQdata = [ IQdata, pay_load ];

% [S,F,T,P] = spectrogram(IQdata,256,250,64,Fs);
% surf(T,F,10*log10(P),'edgecolor','none'); axis tight; 
% view(0,90);
% xlabel('Time (Seconds)'); ylabel('Hz');
%% ----------------------------------------Reciever------------------------------------------------- %%
%% Signal synchronization and cropping
[corr, lag] = xcorr(IQdata, upChirp);   % I am not sure that whether we should employ more symbols to improve the synchronization performance
% plot(abs(corr))
corrThresh = max(abs(corr))/4;

cLag = find(abs(corr) > corrThresh, 1);
signalStartIndex = abs(lag(cLag)) + Spl*2^SF;           % We have sett the number of preamble as 8 in the modulation module.
signalEndIndex = signalStartIndex + symbol_num*(2^SF);

x = IQdata(signalStartIndex+1 : signalEndIndex);

%% De-chirping
deChirp = repmat(upChirp , 1 , ceil(length(x) / length(upChirp)) );
signal = x .* deChirp;

%% Spectrogram computation
Nfft = 2^SF; % 512
window_length = Nfft; % same as symbol_time*Fs;
[s, f, t] = spectrogram(signal, blackman(window_length), 0, Nfft, Fs);

%% Spectrogram plotting
% surf(f,t,10*log10(abs(s.')),'EdgeColor','none')
% axis xy; axis tight; colormap(jet); view(0,90);
% ylabel('Time');
% xlabel('Frequency (Hz)');
% % xlim([0 BW])
% ylim([0.0001 1])

%% Bit extraction
[~, symbols_recovered] = max(abs(s));
symbols_recovered = symbols_recovered - 1;        % Because the index of ouput begin with 1

c_recovered = 0;
for i = 1 : length(symbols_recovered)
    c_recovered = [ c_recovered , bitget(symbols_recovered(i) , 1:SF) ];  
end
c_recovered = c_recovered(2:end);

bit_matrix_recovered= reshape(c_recovered, 4 + parity_num , length(c_recovered)/(4 + parity_num));

test = (c_recovered - interLeave_codeword);
[codeword_old] = DeInterleavecode(interLeave_codeword,cOld_length,parity_num,SF);
[source_code] = HanmingDecode(parity_num,codeword_old);

test1 = (c_recovered - interLeave_codeword);
test2 = (bits - source_code);
[max(test1) max(test2)]
BER = sum(abs(test2))/length(test2);
