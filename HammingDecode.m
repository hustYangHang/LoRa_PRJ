function [source_code] = HammingDecode(parity_num,code_bit)
%UNTITLED3 Hanming Decode
%   coderate 1 2 3 4: parity :1 2 3 4 => CR = 4/5 4/6 4/7 4/8
code_num = length(code_bit);
CR = 4/(4 + parity_num); 
info_bit_num = code_num*CR;
switch (parity_num)
%     case 1
%     case 2
    case 3 % 4/7
        rc_temp = reshape(code_bit,(4+parity_num),code_num/(4+parity_num));
        decode_p = zeros(3,code_num/(4+parity_num));
        source_code_matrix = zeros(4,code_num/(4+parity_num));
        for i = 1:code_num/(4+parity_num)
            decode_p(1,i) = xor(xor(xor(rc_temp(1,i),rc_temp(2,i)),rc_temp(3,i)),rc_temp(5,i));% 1 2 3 5
            decode_p(2,i) = xor(xor(xor(rc_temp(2,i),rc_temp(3,i)),rc_temp(4,i)),rc_temp(6,i));% 2 3 4 6
            decode_p(3,i) = xor(xor(xor(rc_temp(1,i),rc_temp(2,i)),rc_temp(4,i)),rc_temp(7,i));% 1 2 4 7
            parity = decode_p(3,i)*4 + decode_p(2,i)*2 +decode_p(1,i);
        %     parity = bitor(bitor(bitor([0,0,0,decode_p(1,i)],[0,0,decode_p(2,i),0]),[0,decode_p(3,i),0,0]),[decode_p(4,i),0,0,0]);
            switch (parity)
                case 5
                    x_temp = bitxor(rc_temp(:,i),[0,0,0,0,0,0,0,1]);
                    source_code_matrix(:,i) = x_temp(1:4);
%                     [parity i]
                case 7
                    x_temp = bitxor(rc_temp(:,i),[0,0,0,0,0,0,1,0]);
                    source_code_matrix(:,i) = x_temp(1:4);
%                     [parity i]
                case 3
                    x_temp = bitxor(rc_temp(:,i),[0,0,0,0,0,1,0,0]);
                    source_code_matrix(:,i) = x_temp(1:4);
%                     [parity i]
                case 6
                    x_temp = bitxor(rc_temp(:,i),[0,0,0,0,1,0,0,0]);
                    source_code_matrix(:,i) = x_temp(1:4);
%                     [parity i]
                case 8
                    source_code_matrix(:,i) = rc_temp(1:4,i);
%                     [parity i]
                case 0
                    source_code_matrix(:,i) = rc_temp(1:4,i);
            end
        end
        source_code = reshape(source_code_matrix,1,info_bit_num);
    case 4
        rc_temp = reshape(code_bit,(4+parity_num),code_num/(4+parity_num));
        decode_p = zeros(4,code_num/(4+parity_num));
        source_code_matrix = zeros(4,code_num/(4+parity_num));
        for i = 1:code_num/8
            decode_p(1,i) = xor(xor(xor(rc_temp(1,i),rc_temp(2,i)),rc_temp(3,i)),rc_temp(5,i));% 1 2 3 5
            decode_p(2,i) = xor(xor(xor(rc_temp(2,i),rc_temp(3,i)),rc_temp(4,i)),rc_temp(6,i));% 2 3 4 6
            decode_p(3,i) = xor(xor(xor(rc_temp(1,i),rc_temp(2,i)),rc_temp(4,i)),rc_temp(7,i));% 1 2 4 7
            decode_p(4,i) = xor(xor(xor(rc_temp(1,i),rc_temp(3,i)),rc_temp(4,i)),rc_temp(8,i));% 1 3 4 8
            parity = decode_p(4,i)*8 + decode_p(3,i)*4 + decode_p(2,i)*2 +decode_p(1,i);
        %     parity = bitor(bitor(bitor([0,0,0,decode_p(1,i)],[0,0,decode_p(2,i),0]),[0,decode_p(3,i),0,0]),[decode_p(4,i),0,0,0]);
            switch (parity)
                case 13
                    x_temp = bitxor(rc_temp(:,i),[0,0,0,0,0,0,0,1]);
                    source_code_matrix(:,i) = x_temp(1:4);
%                     [parity i]
                case 7
                    x_temp = bitxor(rc_temp(:,i),[0,0,0,0,0,0,1,0]);
                    source_code_matrix(:,i) = x_temp(1:4);
%                     [parity i]
                case 11
                    x_temp = bitxor(rc_temp(:,i),[0,0,0,0,0,1,0,0]);
                    source_code_matrix(:,i) = x_temp(1:4);
%                     [parity i]
                case 14
                    x_temp = bitxor(rc_temp(:,i),[0,0,0,0,1,0,0,0]);
                    source_code_matrix(:,i) = x_temp(1:4);
%                     [parity i]
                case 8
                    source_code_matrix(:,i) = rc_temp(1:4,i);
%                     [parity i]
                case 0
                    source_code_matrix(:,i) = rc_temp(1:4,i);
            end
        end
        source_code = reshape(source_code_matrix,1,info_bit_num);
end
end

