function [interLeave_codeword,cOld_length] = Interleavecode(codeword,parity_num,SF)
%UNTITLED2 交织 本质上 c_matrix[(4+parity),code_num/(4 + parity_num)] -> interleave_matrix[SF,code_num/SF]
%  将码字分配到不同的Symbol中去，防止链路中的突发错误
%  codeword ：原始码字
%  parity_num ：冗余bit 
%  interLeave_codeword ：交织后的码字 
%  cOld_length ：为了解决交织出现的随机错误添加了 0 bit，所以需要记录原始码字的长度
%% 以下部分是19/2/21所做的处理部分，直接补全symbol的bit以便发送
c_old = codeword;
cOld_length = length(c_old);
if mod(length(c_old),lcm((4 + parity_num), SF)) ~= 0
   c_old = [zeros(1,lcm((4 + parity_num), SF) - mod(length(c_old),lcm((4 + parity_num), SF))) c_old];
end
interLeave_codeword = c_old;
%% 以下部分是原来的交织代码，缺点是添加了太多的冗余的0bit
% c_old = codeword;
% c_old = [zeros(1,(4 + parity_num) * (SF-2)) c_old zeros(1,4 + parity_num)];
% % c_matrix[(4+parity),code_num/(4 + parity_num)] -> interleave_matrix[SF,code_num/SF]
% cOld_length = length(c_old);
% 
% if mod(length(c_old),(4 + parity_num) * SF) ~= 0
%    c_old = [zeros(1,(4 + parity_num) * SF - mod(length(c_old),(4 + parity_num) * SF)) c_old];
% end
% % if mod(length(c_old),(4 + parity_num) * SF) ~= 0
% %    c_old = [zeros(1,lcm((4 + parity_num), SF) - mod(length(c_old),lcm((4 + parity_num), SF))) c_old];
% % end
% 
% c_new = c_old;
% code_num = length(c_new);
% c_matrix_new = reshape(c_new,4 + parity_num,code_num/(4 + parity_num));
% numCodewords = code_num/(4 + parity_num);
% interleave_matrix = zeros(SF,code_num/SF);
% for x = 1:(numCodewords/SF - 1)
%     cwOff = x * SF;
%     symOff = x * (4 + parity_num);
%     for k = 1:(4 + parity_num)
%         for m = 1:SF
%             i = mod((m + k + SF),SF);
%             bit = c_matrix_new(k,cwOff + i);
%             interleave_matrix(m,symOff + k) = bit;
%         end
%     end
% end
% interLeave_codeword = reshape(interleave_matrix,1,code_num);
end

