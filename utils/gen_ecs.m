function jpg_ecs = gen_ecs(bin_ecs,dc_code,ac_code,blk_num)
%GEN_ECS generate the entropy coded data and the eoi.
bin_ecs_generated = zeros(length(bin_ecs)*1.5,1);    % preallocate more space to improve the speed.
flag = 1;
for i = 1:blk_num
    len_dc = length(dc_code{i, 1});
    bin_ecs_generated(flag:flag+len_dc-1) = dc_code{i, 1};
    flag = flag + len_dc;
    [num_zrv,~] = size(ac_code{i,1});
    for j = 1:num_zrv
        length_ac_vlc = length(ac_code{i,1}{j,4});
        length_ac_apd = length(ac_code{i,1}{j,5});
        bin_ecs_generated(flag:flag+length_ac_vlc+length_ac_apd-1) = [ac_code{i,1}{j,4} ac_code{i,1}{j,5}];
        flag = flag + length_ac_vlc + length_ac_apd;
    end
end
flag = flag - 1;
bin_ecs_generated = bin_ecs_generated(1:flag);
num_pad = 8 - mod((flag),8);
if num_pad ~= 8
    bin_ecs_generated(flag+1:flag+num_pad) = ones(num_pad,1);
    flag = flag + num_pad;
end
bin_ecs_generated = reshape(bin_ecs_generated, [8 flag/8]);
bin_ecs_generated = bin_ecs_generated';
dec_ecs = zeros(flag/8,1);
for i = 1:flag/8
    dec_ecs(i,1) = bin2int(bin_ecs_generated(i,:));
end
ind_ff = find(dec_ecs==255);
m = length(ind_ff);
for i = 1:m
    tmp1 = dec_ecs(1:ind_ff(m-i+1));
    tmp2 = dec_ecs(ind_ff(m-i+1)+1:end);
    dec_ecs = [tmp1;0;tmp2];
end
jpg_ecs = [dec_ecs;255;217];
end

