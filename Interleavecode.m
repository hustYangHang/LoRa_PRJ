function [interLeave_codeword,cOld_length] = Interleavecode(codeword,parity_num,SF)
%UNTITLED2 ��֯ ������ c_matrix[(4+parity),code_num/(4 + parity_num)] -> interleave_matrix[SF,code_num/SF]
%  �����ַ��䵽��ͬ��Symbol��ȥ����ֹ��·�е�ͻ������
%  codeword ��ԭʼ����
%  parity_num ������bit 
%  interLeave_codeword ����֯������� 
%  cOld_length ��Ϊ�˽����֯���ֵ������������� 0 bit��������Ҫ��¼ԭʼ���ֵĳ���
%% ���²�����19/2/21�����Ĵ����֣�ֱ�Ӳ�ȫsymbol��bit�Ա㷢��
c_old = codeword;
cOld_length = length(c_old);
if mod(length(c_old),lcm((4 + parity_num), SF)) ~= 0
   c_old = [zeros(1,lcm((4 + parity_num), SF) - mod(length(c_old),lcm((4 + parity_num), SF))) c_old];
end
interLeave_codeword = c_old;
%% ���²�����ԭ���Ľ�֯���룬ȱ���������̫��������0bit
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

