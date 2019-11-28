function segment = parse_dht( loc_ff, jpg_data, fidorg, num )
% parse_dht - parse the DHT segment in the JPEG file header.
pos_c4 = find(jpg_data(loc_ff+1,1) == 196);
pos_c4 = pos_c4(num,1);
c = loc_ff(pos_c4,1);
len_segment = jpg_data((c+2),1)*16*16 + jpg_data((c+3),1);
status = fseek(fidorg,c-1,'bof');
segment = fread(fidorg, len_segment+2, 'uint8');
end
