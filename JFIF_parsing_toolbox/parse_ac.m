function [ptr_cur,ac_code] = parse_ac(bits_sos, table_huff_ac, pos_dc)
%PARSE_AC
table = table_huff_ac;
num_code = length(table(:,1));
idx_code = 5;
flag = false;
num_ac = 0;
num_zrv = 1;
ptr_cur = pos_dc;
tmp = ones(num_code,1); 
while flag == false && num_ac < 63
    tmp = tmp.*(table(:,idx_code) == bits_sos(ptr_cur));
    if sum(tmp) == 1
        idx_code = 5;   % reset the pointer.
        row = find(tmp);
        tmp = ones(num_code,1); % reset the temp vector.
        run = table(row, 1); 
        cat = table(row, 2);
        len_vlc = table(row, 4);
        ac_vlc = table(row,5:5+len_vlc-1);
        ac_code{num_zrv,1} = row;
        ac_code{num_zrv,2} = [run,cat];
        ac_code{num_zrv,3} = run * 16 + cat;
        ac_code{num_zrv,4} = ac_vlc;
        ac_code{num_zrv,5} = bits_sos(ptr_cur + 1 : ptr_cur + cat);
        num_zrv = num_zrv + 1;
        if run == 15 && cat == 0
            num_ac = num_ac + 16;
        elseif run == 0 && cat == 0
            flag = true;
        else
            num_ac = num_ac + 1 + run;
        end
        ptr_cur = ptr_cur + cat;
    else
        idx_code = idx_code + 1;
    end
    ptr_cur = ptr_cur + 1;
end
end

