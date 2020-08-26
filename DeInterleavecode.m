function [codeword_old] = DeInterleavecode(interLeave_codeword,cOld_length,parity_num,SF)
%UNTITLED3 解交织
%  
%% 以下是19/2/21修改的部分，直接去掉因为发送需要补全的冗余0bit
codeword_old = interLeave_codeword(1,end - cOld_length + 1:end);
%% 以下部分是原来的解交织
% code_num = length(interLeave_codeword);
% interleave_matrix = reshape(interLeave_codeword,SF,code_num/SF);
% numSymbols = code_num/SF;
% codeword_matrix = zeros((4 + parity_num),code_num/(4 + parity_num));
% for x = 1:(numSymbols/(4 + parity_num) - 1)
%     cwOff = x * SF;
%     symOff = x * (4 + parity_num);
%     for k = 1:(4 + parity_num)
%         for m = 1:SF
%             i = mod((m + k),SF);
%             bit = interleave_matrix(m,symOff + k);
%             codeword_matrix(k,cwOff + i) = bit;
%         end
%     end
% end
% codeword_new = reshape(codeword_matrix,1,code_num);
% codeword_old = codeword_new(1,end - cOld_length + 1:end);
% codeword_old = codeword_old(1,(4 + parity_num) * (SF - 2) + 1:end - (4 + parity_num));
end

