function y = gen_bits(x)
%GEN_BITS convert the 
%x sos段去零后的数据压缩部分
%y 拉成0或1的码流一行
x = int2bin(x,8);
[m,n] = size(x);
y = reshape(x.',[1 m*n]);
end
