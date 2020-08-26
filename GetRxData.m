function [Y] = GetRxData(path,NumSample)

path1 = [path,'\RX1.bin'];

fid = fopen(path1,'r');
fseek(fid, 0 ,'bof'); temp = fread(fid,'int16');
Y(1,:) = temp(1:2:2*NumSample) + 1i*temp(2:2:2*NumSample);
fclose(fid);

end


