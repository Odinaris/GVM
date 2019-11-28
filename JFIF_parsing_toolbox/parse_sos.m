function data_ecs = parse_sos(loc_ff, jpg_data, fidorg)
% parse_sos - parse the SOS segment and get the entropy-coded data(from FFDA to FFD9(EOI)).
% data_ecs - the entropy-coded data.
ind_sos = find(jpg_data(loc_ff+1) == 218);
ind_sos = loc_ff(ind_sos,1);  % the position of FFDA
length_sos = jpg_data((ind_sos+2),1)*16*16 + jpg_data((ind_sos+3),1);
ind_eoi = find(jpg_data(loc_ff+1)==217);
length_ecs = loc_ff(ind_eoi,1) - ind_sos - length_sos - 2;
status = fseek(fidorg, ind_sos + length_sos + 1,'bof');
data_ecs = fread(fidorg, length_ecs, 'uint8');
end

