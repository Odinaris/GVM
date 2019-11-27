function jpeg_header = rpl_jpg_dht(jpg_data, loc_ff, mdf_table_huff_ac)
%rpl_jpg_hht Replace the jpeg dht
pos_c4 = find(jpg_data(loc_ff+1,1) == 196);
pos_c4 = pos_c4(end,1);
loc_ac_table = loc_ff(pos_c4,1);
ind_sos = loc_ff(find(jpg_data(loc_ff+1) == 218),1);  % the position of FFDA
length_sos = jpg_data((ind_sos+2),1)*16*16 + jpg_data((ind_sos+3),1);
jpeg_header = jpg_data(1:ind_sos+length_sos+1);
for i = 1:length(mdf_table_huff_ac(:,1))
    jpeg_header(loc_ac_table+21+i-1) = mdf_table_huff_ac(i,1)*16 + mdf_table_huff_ac(i,2);
end
end