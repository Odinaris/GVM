# High Capacity Lossless Data Hiding in JPEG Bitstream Based on General VLC Mapping(GVM)
A High capacity lossless data hiding scheme for JPEG images. [paper link](https://arxiv.org/abs/1905.05627v2 )

## Abstract

JPEG is the most popular image format, which is widely used in our daily life. Therefore, reversible data hiding (RDH) for JPEG images is important. Most of the RDH schemes for JPEG images will cause significant distortions and large file size increments in the marked JPEG image. As a special case of RDH, the lossless data hiding (LDH) technique can keep the visual quality of the marked images no degradation. In this paper, a novel high capacity LDH scheme is proposed. In the JPEG bitstream, not all the variable length codes (VLC) are used to encode image data. By constructing the mapping between the used and unused VLCs, the secret data can be embedded by replacing the used VLC with the unused VLC. Different from the previous schemes, our mapping strategy allows the lengths of unused and used VLCs in a mapping set to be unequal. We present some basic insights into the construction of the mapping relationship. Experimental results show that most of the JPEG images using the proposed scheme obtain smaller file size increments than previous RDH schemes. Furthermore, the proposed scheme can obtain high embedding capacity while keeping the marked JPEG image with no distortion.

## Code running environment

The code has been tested by Matlab R2018b on Windows 10. 

## How to use

- Please see the comparison results before and after extraction in `demo_gvm.m`. The experimental results demonstrate our code can achieve the feature of high capacity and lossless, which are referred in our paper.

- You can run the  `demo_embed.m` to see the related results of embedding. In  `demo_embed.m`, the test image is `Boat_70.jpg`, which quality factor = 70.


- You can run the  `demo_extract.m` to see the related results of extraction. In  `demo_extract.m`, the extracted image is `stego.jpg`, which is the stego version of `Boat_70.jpg`.
- Other related functions are all listed in out repositories.

## Tips

If you find any problems, please feel free to contact to the authors ([yangdu@stu.ahu.edu.cn](mailto:yangdu@stu.ahu.edu.cn)).







