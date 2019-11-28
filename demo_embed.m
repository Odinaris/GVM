%% Initial code environment.
clear;clc;dbstop if error
possible_solutions = load('feasible_solutions.mat');
possible_solutions = possible_solutions.partion;
addpath(genpath(pwd));
payload = 5000;
num_slt_pks = 10;
tic;
%% Read JPEG image.
img_name = 'Boat_70.jpg';
fidorg = fopen(img_name);
jpg_data = fread(fidorg);
loc_ff = find(jpg_data == 255);    % record the positions of FF.
[len,~] = size(jpg_data);
[~,~,blk_h,blk_w] = get_img_size(jpg_data,loc_ff);
blk_num = blk_h * blk_w;
%% Parse the Huffman table (DHT segment, started from FFC4).
loc_c4 = find(jpg_data(loc_ff+1,1) == 196);
if length(loc_c4)>1
    data_huff_dc = parse_dht(loc_ff,jpg_data,fidorg,1);  % segment of the huffman table of DC.
    table_huff_dc = get_huff_dc_table(data_huff_dc);
    data_huff_ac = parse_dht(loc_ff,jpg_data,fidorg,2);   % segment of the huffman table of AC.
    table_huff_ac = get_huff_ac_table(data_huff_ac);
else
    error('The number of Huffman table specifications is smaller than 2!');
    %     [huff_tbl_dc,huff_tbl_ac] = fun_read_huff(loc_ff,loc_c4,jpg_data,fidorg);
    % 	tdchufftbl = fun_huff_dctable(huff_tbl_dc);
    % 	tachufftbl = fun_huff_actable(huff_tbl_ac);	%run - category - length - base code length -  base code
end
%% Parse the entropy-coded data.
data_sos = parse_sos(loc_ff,jpg_data,fidorg);
data_sos = dlt_zero(data_sos);
bits_sos = gen_bits(data_sos);
flag = 1;
dc_app_len = zeros(blk_num,1);
dc_code = cell(blk_num,1);  % dc_code includes huffman bits and appended bits.
ac_code = cell(blk_num,1);  % ac_code includes huffman bits and appended bits.
dc_pos = ones(blk_num+1,1); % dc_pos includes the position of dc_code.
ac_pos = ones(blk_num+1,1); % ac_pos includes the position of ac_code.
while flag <= blk_num
    [ac_pos(flag),dc_app_len(flag,1),dc_code{flag}] = parse_dc(bits_sos, table_huff_dc, dc_pos(flag));
    [dc_pos(flag+1), ac_code{flag}] = parse_ac(bits_sos, table_huff_ac, ac_pos(flag));
    flag = flag + 1;
end
dc_pos(end) = [];ac_pos(end) = [];
%% Parse the VLCs.
freq_vlc_used = zeros(162,1);
vlc_category = cell(1,16);
for i = 1 : blk_num
    for j = 1 : length([ac_code{i,1}{:,1}])
        cur_row = ac_code{i,1}{j,1};
        freq_vlc_used(cur_row,1) = freq_vlc_used(cur_row,1) + 1;
    end
end
for i=1:16
    vlc_category{:,i} = (reshape(freq_vlc_used(find(table_huff_ac(:,4) == i)),1,[]));
    num_unused = length(find(vlc_category{:,i}==0));
    num_used = length(vlc_category{:,i}) - num_unused;
end
vlc(:,1:2) = table_huff_ac(:,1:2);
vlc(:,4) = table_huff_ac(:,4);
flag = 1;
for i=1:16
    if(~isempty(vlc_category{1,i}))
        num_vlc_category = length(vlc_category{1,i});
        for j = 1 : num_vlc_category
            vlc(flag,3) = vlc_category{1,i}(1,j);
            flag = flag + 1;
        end
    end
end
%% Establish the optimal GVM relationship by simulated embedding.
G_opt = get_gvm_relationship( vlc, possible_solutions, payload, 6, num_slt_pks);
num_mapping_sets = length(nonzeros( G_opt.opt_mapping_set));
GVM_relationship = cell(num_mapping_sets,2);
flag = G_opt.start_peak_point;
shifted_vlc = G_opt.shifted_vlc;
mdf_rsv = shifted_vlc(:,1:2);
GVM_huff_val = zeros(num_mapping_sets,1);
for i = 1:num_mapping_sets
    GVM_relationship{i,1} = shifted_vlc(flag,1:2);
    GVM_huff_val(i) = shifted_vlc(flag,1)*16 + shifted_vlc(flag,2);
    for j = 1:G_opt.opt_mapping_set(i)+1
        GVM_relationship{i,2}{j,1} = table_huff_ac(flag,5:5+table_huff_ac(flag,4)-1);
        mdf_rsv(flag,:) = GVM_relationship{i,1};
        flag = flag + 1;
    end
end
mdf_table_huff_ac = [mdf_rsv  table_huff_ac(:,3:end)];  % modified huffman table for AC coefficients.
%% Shift the RSVs and corresponding VLCs.
mdf_ac_code = ac_code;
mdf_huff_val = shifted_vlc(:,1).*16+shifted_vlc(:,2);
for i = 1:blk_num
    [num_zrv,~] = size(mdf_ac_code{i,1});
    for j = 1:num_zrv
        ind = find(mdf_ac_code{i,1}{j, 3} == mdf_huff_val);
        mdf_ac_code{i,1}{j, 4} = table_huff_ac(ind,5:5+table_huff_ac(ind,4)-1);
    end
end
%% Embed the secret messages,
rng(0,'twister');
secret = round(rand(1,payload)*1);
idx_secret = 1;
for i = 1:blk_num
    [num_zrv,~] = size(mdf_ac_code{i,1});
    for j = 1:num_zrv
        ind = find(mdf_ac_code{i,1}{j, 3} == GVM_huff_val);
        if ind ~= 0
            len_bit = log2(length(GVM_relationship{ind, 2}(:,1)));
            if idx_secret+len_bit-1 > payload
                secret(payload+1:idx_secret+len_bit-1) = zeros(idx_secret+len_bit-1-payload,1);
            end
            cur_bits = secret(idx_secret+len_bit-1);
            idx_slt_vlc = bin2int(cur_bits);
            mdf_ac_code{i,1}{j, 4} = GVM_relationship{ind, 2}{idx_slt_vlc+1, 1};
            idx_secret = idx_secret + len_bit;
            if idx_secret > payload
                break;
            end
        end
    end
    if idx_secret > payload
        break;
    end
end
%% Generate the stego JPEG bitstream.
jpg_header = rpl_jpg_dht(jpg_data, loc_ff, mdf_table_huff_ac);
jpg_ecs = gen_ecs(bits_sos,dc_code,mdf_ac_code,blk_num);
stego_jpg = [jpg_header;jpg_ecs];
fid = fopen(strcat('stego_',img_name), 'w+');
fwrite(fid,stego_jpg,'uint8');
%% Embedding is over.
fi = (length(stego_jpg) - length(jpg_data))*8;
fprintf('The file change(bits) is %d\n',int16(fi));
fclose('all');
toc;