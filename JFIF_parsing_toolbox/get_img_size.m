function [height,width,blk_h,blk_w]=get_img_size(jpg_data,loc_ff)
a = find(jpg_data(loc_ff+1,1)==192);
b = loc_ff(a,1);
height = jpg_data((b+5),1)*16*16 + jpg_data((b+6),1);
width = jpg_data((b+7),1)*16*16 + jpg_data((b+8),1);
blk_h = ceil(height/8); 
blk_w = ceil(width/8);
end