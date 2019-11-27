function jpg_ecs = gen_ecs(bits_sos,dc_code,ac_code,blk_num)
%GEN_ECS generate the entropy coded data and the eoi.
bin_sos = zeros(length(bits_sos)*1.5,1);    % preallocate more space to improve the speed.
flag = 1;
for i = 1:blk_num
    len_dc = length(dc_code{i, 1});
    bin_sos(flag:flag+len_dc-1) = dc_code{i, 1};
    flag = flag + len_dc;
    [num_zrv,~] = size(ac_code{i,1});
    for j = 1:num_zrv
        length_ac_vlc = length(ac_code{i,1}{j,4});
        length_ac_apd = length(ac_code{i,1}{j,5});
        bin_sos(flag:flag+length_ac_vlc+length_ac_apd-1) = [ac_code{i,1}{j,4} ac_code{i,1}{j,5}];
        flag = flag + length_ac_vlc + length_ac_apd;
    end
end
flag = flag - 1;
bin_sos = bin_sos(1:flag);
num_pad = 8 - mod((flag),8);
if num_pad ~= 8
    bin_sos(flag+1:flag+num_pad) = ones(num_pad,1);
    flag = flag + num_pad;
end
bin_sos = reshape(bin_sos, [8 flag/8]);
bin_sos = bin_sos';
dec_sos = zeros(flag/8,1);
for i = 1:flag/8
    dec_sos(i,1) = bin2int(bin_sos(i,:));
end
ind_ff = find(dec_sos==255);
m = length(ind_ff);
for i = 1:m
    tmp1 = dec_sos(1:ind_ff(m-i+1));
    tmp2 = dec_sos(ind_ff(m-i+1)+1:end);
    dec_sos = [tmp1;0;tmp2];
end
jpg_ecs = [dec_sos;255;217];
end

