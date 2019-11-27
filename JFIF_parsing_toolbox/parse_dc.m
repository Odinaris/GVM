function [pos_ac, cat, cur_dcc] = parse_dc(bits_sos, table_huff_dc, pos_dc)
%PARSE_DC 
% len_dc_apd - length of the appended bits of DC coeffcient.
table = table_huff_dc;
num_code = length(table(:,1));
flag = false;
tmp = ones(num_code,1);
pos_ac = pos_dc;
idx_code = 3;
while flag ~= true
    tmp = tmp.*(table(:,idx_code) == bits_sos(pos_ac));
    if sum(tmp) == 1
        cat = table(find(tmp),1);
        flag = true;
        pos_ac = pos_ac + cat;
    else
        idx_code = idx_code + 1;
    end
    pos_ac = pos_ac + 1;
end
cur_dcc = bits_sos(pos_dc:pos_ac-1);
end

