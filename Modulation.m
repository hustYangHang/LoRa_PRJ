function [IQdata,symbol_num] = Modulation(interLeave_codeword,SF,BW)
%% Parameter passing
Fs = BW;           % sample frequency
symbol_time = 2^SF / BW; 
bit_num = length(interLeave_codeword);
symbol_num = bit_num / SF;
%% Signal Genneration
t = 0: 1/Fs: (symbol_time - 1/Fs);
f0 = 0;
f1 = BW;
%% design upchirp and downchirp
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
% CRC = 0;
% IH = 0;
% DE = 0;
% if symbol_time > 16e-3
%     DE = 1;
% end
%% generate preamble
% Spl = 8 + max(ceil(4 * parity_num*((8 * byte_num - 4 * SF + 28 + 16 * CRC - 20 * IH)/(4 * (SF - 2 * DE)))),0);
Spl = 8;
preamble =  repmat(upChirp,1,Spl);
% here insert mandatory bits
% mandatory_bits = [repmat(upChirp,1,2) repmat(downChirp,1,2) downChirp(1,1:length(downChirp) * 0.25)];

IQdata = [preamble];

% paytest = repmat(downChirp,1,10);
% IQdata = [paytest];
% figure
% x_shift = [];
% for i = 1 : length(IQdata)/2^SF   
%     x_shift = [x_shift circshift( IQdata(1,((i - 1) * 2^SF) + 1:i * 2^SF), [1,2^SF])];
% end
% [S,F,T,P] = spectrogram(x_shift,32,30,64,Fs);
% surf(T,F,10*log10(P),'edgecolor','none'); axis tight; 
% view(0,90);
% xlabel('Time (Seconds)'); ylabel('Hz');
% IQdata = upChirp;
% value_max = max ( max(real(IQdata)) , max(real(IQdata)) );
% IQdata = IQdata / value_max;
% IQdata = IQdata * 2^15;                         %让DAC满量程
% r = real(IQdata);
% i = imag(IQdata);
% save IQdataReal.mat r
% save IQdataimag.mat i
% 
% fp = fopen('WaveFormImag_forhuixin.txt','w+');     %以写的方式打开指定路径下的.txt文件
% fprintf(fp,'%d\n',imag(IQdata));               %把数据竖地写入.txt文件
% fclose(fp);
% 
% fp = fopen('WaveFormReal_forhuixin.txt','w+');      %以写的方式打开指定路径下的.txt文件
% fprintf(fp,'%d\n',real(IQdata));                  %把数据竖地写入.txt文件
% fclose(fp);

symbols = reshape(interLeave_codeword, SF,  bit_num/SF);
shift_wight = [2^0,2^1,2^2,2^3,2^4,2^5,2^6,2^7,2^8,2^9,2^10,2^11];

shift_num_per_symbol = shift_wight(1 : SF) * symbols;

pay_load = [];
for i = 1 : symbol_num   
    pay_load = [pay_load circshift( downChirp,  [ 1, shift_num_per_symbol(i) ] )];
end
IQdata = [ IQdata, pay_load ];

end
