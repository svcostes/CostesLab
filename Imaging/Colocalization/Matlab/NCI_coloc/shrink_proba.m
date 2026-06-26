%shrink_proba computes probability of the co-localization between two images is not the
% result of a random spatial event.
%
% Input:
% IMAGE  img1   Input image1
% IMAGE  img2   Input image2
% IMAGE  mask   Mask image
% int    N      Maximum number of randomization used
% int    own_step;   Boolean for using own step
% Default is 0 -> stepx,stepy,stepy are based on max FWHM of
% the auto-correlation of img1 & img2.
% If option 1  -> use input stepx,stepy,stepz entered by user
%
% Output:
% Probability = pp
% 
% (C) Copyright 2000-2001               Image Analysis Laboratory
%     All rights reserved               SAIC-Frederick, Inc.
%                                       National Cancer Institute
%                                       PO BOX B
%                                       FREDERICK, MD 21702 USA 
%
% Sylvain Costes, October 2001
% Adapted from Pearson_shrink_proba.c in scilimage written by S. Costes

function [pp,stepout,distri] = shrink_proba(img1,img2,mask,N,own_step,stepx,stepy,stepz)

%t = cputime;
w1 = size(img1,1);
h1 = size(img1,2);
d1 = size(img1,3);
w2 = size(img2,1);
h2 = size(img2,2);
d2 = size(img2,3);
w3 = size(mask,1);
h3 = size(mask,2);
d3 = size(mask,3);

if (w1~=w2 | h1~=h2 | d1~=d2)
    fprintf('Images for probability must be the same size');
    return;
end
if (w1~=w3 | h1~=h3 | d1~=d3)   
    fprintf('Images for probability must be the same size');
    return;
end

img1 = reshape(img1,[w1,h1,d1]); %This reshape is necessary since
img2 = reshape(img2,[w2,h2,d2]); %size(img) can be 512x512 only
mask = reshape(mask,[w3,h3,d3]); %it will still return 1 for size(img,3)
%This forces 2D image to carry the singleton in its dimenstion and look 3D

% make sure mask mask is binary
mask = mask>0;

%
% Determine the FWHM for img1 and img2 and keep smallest block
%

 if (~own_step)
   step1 = autocor(img1,mask);
   step2 = autocor(img2,mask); 
   fprintf('Autocorrelation returned the following x,y,z sizes:\n');
   fprintf('Image 1: Xsize = %d, Ysize = %d, Zsize = %d.\n',step1(1),step1(2),step1(3));
   fprintf('Image 2: Xsize = %d, Ysize = %d, Zsize = %d.\n',step2(1),step2(2),step2(3));
   if (step1(1)*step1(2)*step1(3) > step2(1)*step2(2)*step2(3))
    stepx = step2(1);
    stepy = step2(2);
    stepz = step2(3);
    temp_img1 = img1;
    temp_img2 = img2;
   else
    stepx = step1(1);
    stepy = step1(2);
    stepz = step1(3);
    temp_img1 = img2;
    temp_img2 = img1;
   end
 else
   temp_img1 = img1;
   temp_img2 = img2;
end

%
% Shrink images with stepx, stepy, stepz so that the resulting 
% images are temp_img1 and temp_img2 with temp_img2 having 
% an autocorrelation of 1.
%
 mask_size = sum(mask);
 reduction_factor = 4*sqrt(stepx*stepy*stepz/mask_size);
 if (reduction_factor > 1)
  stepx = fix(stepx/reduction_factor);
  stepy = fix(stepy/reduction_factor);
  stepz = fix(max((stepz/reduction_factor),1));
  fprintf('Shrinking was too drastic, adjusted to have at least 16 pixels in the shrinked mask\n');
  fprintf('New step used: %f %f %f\n',stepx,stepy,stepz);
 end
 temp_img1 = subsample(temp_img1,[stepx,stepy,stepz]);
 temp_img2 = subsample(temp_img2,[stepx,stepy,stepz]);
 temp_mask = subsample(mask,[stepx,stepy,stepz]);
 step2 = autocor(temp_img2,temp_mask);
 fprintf('Shrinked image autocorrelation:\n Xsize = %d, Ysize = %d, Zsize = %d.\n',step2(1),step2(2),step2(3));
 w3 = size(temp_img1,1);
 h3 = size(temp_img1,2);
 d3 = size(temp_img1,3);
 fprintf('New dimensions of images: %d x %d x %d\n',w3,h3,d3);
 fprintf('Number of pixels in ROI where probability is computed: %d\n',sum(temp_mask*1.0));

%
% Compute the probability of colocalization of img1 & img2
% as the number of shifted randomized temp_img2
% which scored lower than the initial img2 Pearson coef.
%

 [ro,rp]=overlap(temp_img1,temp_img2,temp_mask);
 distri(1) = rp;
 pos_cnt = 0;

 for i = 1:N
    if (rem(i,N/4) == 0)
      fprintf('%d %% done\n',i*100/N);
    end
    temp2 = randomize(temp_img2,temp_mask);
    [sro,srp] = overlap(temp_img1,temp2,temp_mask);
    distri(i+1) = srp;
    if (srp < rp) pos_cnt= pos_cnt + 1; end
 end

 pp = pos_cnt*1.0/N;

 fprintf('Proba of colocalization is %f as %f / %f\n',pp,pos_cnt,N);
 fprintf('Value based on %d shifted images\n',N);
 stepout = [stepx,stepy,stepz];
 %fprintf('Computed in %f\n',cputime-t);
