%% Initial code environment.
clear;clc;dbstop if error
table_huff_ac_default = load('table_huff_ac_default.mat');
table_huff_ac_default = table_huff_ac_default.table_huff_ac;
addpath(genpath(pwd));
payload = 5000;
tic;
%% Read an image.
img_name = 'stego_Boat_70.jpg';
fidorg = fopen(img_name);
jpg_data = fread(fidorg);
loc_ff = find(jpg_data == 255);    % record the positions of FF.
[~,~,blk_h,blk_w] = get_img_size(jpg_data,loc_ff);
blk_num = blk_h * blk_w;
%% Parse the Huffman table (DHT segment, started from FFC4).
loc_c4 = find(jpg_data(loc_ff+1,1) == 196);
if length(loc_c4)>1
    data_huff_dc = parse_dht(loc_ff,jpg_data,fidorg,1);  % segment of the huffman table of DC.
    table_huff_dc = get_huff_dc_table(data_huff_dc);
    data_huff_ac = parse_dht(loc_ff,jpg_data,fidorg,2);   % segment of the huffman table of AC.
    table_huff_ac = get_huff_ac_table(data_huff_ac);
end
%% Parse the entropy-coded data.
data_sos = dlt_zero(parse_sos(loc_ff,jpg_data,fidorg));
bits_sos = gen_bits(data_sos);
flag = 1;
dc_code = cell(blk_num,1);  % dc_code includes huffman bits and appended bits.
ac_code = cell(blk_num,1);  % ac_code includes huffman bits and appended bits.
dc_pos = ones(blk_num+1,1); % dc_pos includes the position of dc_code.
ac_pos = ones(blk_num+1,1); % ac_pos includes the position of ac_code.
while flag <= blk_num
    [ac_pos(flag),~,dc_code{flag}] = parse_dc(bits_sos, table_huff_dc, dc_pos(flag));  
    [dc_pos(flag+1), ac_code{flag}] = parse_ac(bits_sos, table_huff_ac, ac_pos(flag));
    flag = flag + 1;
end
%% Re-establish GVM relationship.
huffval = table_huff_ac(:,3) + 1;
GVM_group = accumarray(huffval, 1:length(huffval), [], @(x) {sort(x)});
GVM_flag = cellfun(@(x) length(x)>1, GVM_group);
GVM_idx = find(GVM_flag == 1);
num_map_sets = sum(GVM_flag);
GVM_relationship = cell(num_map_sets,1);
GVM_val = zeros(num_map_sets,3);
for i = 1:num_map_sets
    len_map_sets = length(GVM_group{GVM_idx(i)});
    len_bits = log2(len_map_sets);
    for j = 1 : len_map_sets
        idx = GVM_group{GVM_idx(i)}(j);
    	GVM_relationship{i,1}{j,1} = table_huff_ac(idx,5:5+table_huff_ac(idx,4)-1);
        GVM_relationship{i,1}{j,2} = int2bin(j-1,len_bits);
    end
    GVM_val(i,1) = table_huff_ac(GVM_group{GVM_idx(i)}(1),3);
    GVM_val(i,2:3) = table_huff_ac(GVM_group{GVM_idx(i)}(1),1:2);
end
%% Extract secret messages.
num_secret = 0;
secret = zeros(payload+8,1);
for i = 1:blk_num
    [num_zrv,~] = size(ac_code{i,1});
    for j = 1:num_zrv
        val = ac_code{i,1}{j, 2}(1) * 16 + ac_code{i,1}{j, 2}(2);
        ind = find(val == GVM_val(:,1));
        if ~isempty(ind) && num_secret < payload 
            len_map_sets = length(GVM_relationship{ind,1}(:,1));
            len_bit = log2(len_map_sets);  
            for k = 1:len_map_sets
                if isequal(ac_code{i,1}{j, 4},GVM_relationship{ind,1}{k,1})
                    secret(num_secret+1:num_secret+len_bit) = GVM_relationship{ind,1}{k,2};
                    break;
                end
            end
            num_secret = num_secret + len_bit;
            flag = num_secret - payload;
        end
        if num_secret > payload
            break;
        end
    end
    if num_secret > payload
        break;
    end
end
% if flag >= 0
%    secret = secret(1:payload+flag); 
% end
secret = secret(1:payload);
%% Restore the VLCs.
rst_ac_code = ac_code;
for i = 1:blk_num
    [num_zrv,~] = size(ac_code{i,1});
    for j = 1:num_zrv
        ind = find(ac_code{i,1}{j, 3}==table_huff_ac_default(:,3));
    	rst_ac_code{i,1}{j, 4} = table_huff_ac_default(ind,5:5+table_huff_ac(ind,4)-1); 
    end   
end
%% Reconstruct the cover JPEG bitstream.
jpg_header = rpl_jpg_dht(jpg_data, loc_ff, table_huff_ac_default);
jpg_ecs = gen_ecs(bits_sos,dc_code,rst_ac_code,blk_num);
stego_jpg = [jpg_header;jpg_ecs];
fid=fopen(strcat('rst_',img_name), 'w+');
fwrite(fid,stego_jpg,'uint8');

%% Extraction and restoration are over.
fi = (length(stego_jpg) - length(jpg_data))*8;
fprintf('The file change(bits) is %d\n',int16(fi));
fclose('all');
toc;