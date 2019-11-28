function [height,width,blk_h,blk_w]=get_img_size(jpg_data,loc_ff)
%GET_IMG_SIZE get the JPEG image size by parsing the SOF0 (Start of Frame)
%segment, which begins with FFC2.
a = find(jpg_data(loc_ff+1,1)==192);
b = loc_ff(a,1);
height = jpg_data((b+5),1)*16*16 + jpg_data((b+6),1);
width = jpg_data((b+7),1)*16*16 + jpg_data((b+8),1);
blk_h = ceil(height/8); 
blk_w = ceil(width/8);
end