clear all;
clc;

load('IQdate.mat');

fc = 250e3;
fs = 10 * fc;
t = 1/fs:1/fs:length(IQdata) * 1/fs;
PLoRa_data = [];
for i = 1 : symbol_num   
    PLoRa_data = [PLoRa_data circshift( downChirp,  [ 1, shift_num_per_symbol(i) ] )];
end
IQdata = [ IQdata, PLoRa_data ];
back_data = IQdata .* cos(2*pi*fc*t);

IQdata_backed = back_data .* cos(2*pi*fc*t);

Wc=2*fc/fs;                                         
[b,a]=butter(4,Wc);
Signal_Filter = filter(b,a,IQdata_backed);
figure;plot(real(IQdata));
figure;plot(real(Signal_Filter));