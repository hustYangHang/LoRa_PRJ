function [code_bit] = HammingCode(parity_num,sourcecode)
%UNTITLED3 Hanming encode
%   coderate 1 2 3 4: parity :1 2 3 4 => CR = 4/5 4/6 4/7 4/8
P = [1 1 1 0; 0 1 1 1;1 1 0 1;1 0 1 1] ;   % the matrix of parity.
H = [eye(4); P];
info_bit_num = length(sourcecode);
CR = 4/(4 + parity_num); 
code_num = info_bit_num / CR;
switch (parity_num)
%     case 1
%     case 2
    case 3 % 4/7
        H = H(1:(4+parity_num) , :);
        bit_matrix = reshape(sourcecode, 4 , info_bit_num/4);
        c_matrix_temp = H *  bit_matrix;    %Hamming coding
        c_matrix = mod(c_matrix_temp, 2) == 1;  %xor
        code_bit = reshape(c_matrix,1,code_num);
    case 4
        H = H(1:(4+parity_num) , :);
        bit_matrix = reshape(sourcecode, 4 , info_bit_num/4);
        c_matrix_temp = H *  bit_matrix;    %Hamming coding
        c_matrix = mod(c_matrix_temp, 2) == 1;  %xor
        code_bit = reshape(c_matrix,1,code_num);
end
end

