%randomize reshufles randomly the pixels of an input image 
%
% Input:
% IMAGE  img   Input image1
% IMAGE  mask   Input mask image
%
% Output:
% IMAGE rimg Ramdomized image of img over the mask
% 
% (C) Copyright 2000-2001               Image Analysis Laboratory
%     All rights reserved               SAIC-Frederick, Inc.
%                                       National Cancer Institute
%                                       PO BOX B
%                                       FREDERICK, MD 21702 USA 
%
% Sylvain Costes, October 2001

function rimg = randomize(img1,img2)

img1 = double(img1);
img2 = double(img2);

w1 = size(img1,1);
h1 = size(img1,2);
d1 = size(img1,3);
w2 = size(img2,1);
h2 = size(img2,2);
d2 = size(img2,3);

if (w1~=w2 | h1~=h2 | d1~=d2)
    fprintf('Input image and mask must be the same size for randomization');
    return;
end

dim1 = w1*h1*d1;
i = 1:dim1;
zero_cnt = sum(img2(i)==0);

[ignore,zero_serie] = sort(img2(i)>0);
img1(zero_serie(1:zero_cnt))=[];%remove in img1 all 0 values. 
% The resulting array img1 is the concatenated columns strip of zero elts 
rand_serie = randperm(dim1-zero_cnt);
img1 = img1(rand_serie);% access array img1 in column mode
rimg(1:w1,1:h1,1:d1) = 0;% initialize array to 0
rimg(zero_serie(zero_cnt+1:dim1))=img1(1:dim1-zero_cnt);
rimg = dip_image(rimg,'sfloat');
rimg = reshape(rimg,h1,w1,d1);
%Need this in order to keep 3rd dimension of 1 in 2D case
%DANGER!!! note h1 and w1 are inverted since they were 
%obtained from the matrix double version of the image.
%Rows and columns are inverted in comparison to images