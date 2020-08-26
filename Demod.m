function [c_recovered] = Demod(IQdata,SF,BW,symbol_num)
%% Parameter passing
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
% % downchirp
% chirpI = chirp(t, f1, symbol_time, f0, 'linear', 90);
% chirpQ = chirp(t, f1, symbol_time, f0, 'linear', 0);
% downChirp = complex(chirpI, chirpQ);
% clear chirpI chirpQ
% corr_downChirp = repmat(downChirp,1,8);

%% Signal synchronization and cropping
[corr, lag] = xcorr(IQdata, corr_upChirp);   % I am not sure that whether we should employ more symbols to improve the synchronization performance
plot(abs(corr))
corrThresh = max(abs(corr));
% corrThresh = max(abs(corr))/3;

cLag = find(abs(corr) >= (corrThresh * 78/80), 1);
% cLag = find(abs(corr) >= (corrThresh * 1), 1);
% Spl = length(find(abs(corr) >= corrThresh));
Spl = 8;
signalStartIndex = abs(lag(cLag)) + (Spl)*2^SF;           % We have sett the number of preamble as 8 in the modulation module.

signalEndIndex = signalStartIndex + symbol_num*(2^SF);
if signalEndIndex > length(IQdata)
    disp('Demod failed!');
end

% x = IQdata(1 : 32768);
x = IQdata(signalStartIndex + 1:signalEndIndex);
% figure
% x_shift = [];
% for i = 1 : length(x)/2^SF   
%     x_shift = [x_shift circshift( x(1,((i - 1) * 2^SF) + 1:i * 2^SF), [1,2^SF/2])];
% end
% [S,F,T,P] = spectrogram(x,32,30,64,Fs);
% surf(T,F,10*log10(P),'edgecolor','none'); axis tight; 
% view(0,90);
% xlabel('Time (Seconds)'); ylabel('Hz');

% x_payload = x(1,4*2^SF+1:end);
%% De-chirping
deChirp = repmat(upChirp , 1 , ceil(length(x) / length(upChirp)) );
signal = x .* deChirp;

%% Spectrogram computation
% Nfft = 2^SF; % 512
% window_length = Nfft; % same as symbol_time*Fs;
% [s, f, t] = spectrogram(signal, blackman(window_length), 0, Nfft, Fs);

for i = 1:symbol_num
    s(:,i) = fft(signal(1,((i - 1) * 2^SF) + 1:i * 2^SF));
end
% figure;plot(abs(s(:,10)));
% figure;plot(10*log10(abs(s(:,10))));
%% Bit extraction
% Here need to be optimized
% [~, symbols_recovered] = max(abs(s));
s_matrix = abs(s);
[m,n] = size(s_matrix);
% symbols_recovered = zeros(1,n);
[~, symbols_recovered] = max(abs(s));
% for i = 1:n
%     [~,symbols_recovered(1,i)] = max(s_matrix(:,i));
%     for j = 1:m
%         if s_matrix(j,i) >= 1.5*mean(s_matrix(j:j+20,i)) + 500
%             symbols_recovered(1,i) = j;
%             break;
%         elseif j >= m - 21
%             i
%             figure;plot(abs(s(:,i)));
%             [~,symbols_recovered(1,i)] = max(s_matrix(:,i));
%             break
%         end 
%     end
% end
symbols_recovered = symbols_recovered - 1;        % Because the index of ouput begin with 1
c_recovered = 0;
for i = 1 : length(symbols_recovered)
%     symbols_temp = mod(symbols_recovered(i) - round(mean(symbols_recovered(1:8))), 2^SF);
%     c_recovered = [ c_recovered bitget(symbols_temp,1:SF) ];
    c_recovered = [ c_recovered , bitget(symbols_recovered(i), 1:SF) ];
end
c_recovered = c_recovered(2:end);
end