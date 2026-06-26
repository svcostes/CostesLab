function [img3,final_mask,r_img,g_img,thresh] = ppiterative(img1,img2,maski)
% [img3,final_mask,r_img,g_img,thresh] = ppiterative(img1,img2,maski)
%
% Call iterative method that extract colocalization mask based on 2D
% histogram of img1 and img2 over maski. r_img and g_img are the
% thresholded mask for each channel. final_mask is the overlap of these two
% masks. img3 is the Pearson image (corrrelation contribution for
% individual pixels (img1-<img1>)*(img2-<img2>)/[sqrt(img1^2)xsqrt(img2^2)]

%
% Input
% IMAGE     img1,img2;                  % Input images (red and green respectively)               
% IMAGE     maski;                      % Input mask for computation     
%
% Output
% IMAGE     img3                        % Pearson image
% IMAGE     final_mask;                 % Optimum colocalized mask 
% IMAGE     r_img,g_img;                % red and green thresholded img   
% int       thresh                      % Red and green thresholds
% 
%
% (C) Copyright 2000-2002               Image Analysis Laboratory
%     All rights reserved               SAIC-Frederick, Inc.
%                                       National Cancer Institute
%                                       PO BOX B
%                                       FREDERICK, MD 21702 USA 
%
% Sylvain Costes, November 2001

%**************************
% SIZE OF THE INPUT IMAGES 
%**************************
w1 = size(img1,1);
h1 = size(img1,2);
d1 = size(img1,3);
w2 = size(img2,1);
h2 = size(img2,2);
d2 = size(img2,3);
Ndim = ndims(img1);
% Make sure mask is binary if it exists, default mask = full image
try
    maski = (maski>0);
catch
    %maski = newim(size(img1),'bin8');
    maski(:) = 1;
    maski = maski>0;
end
w3 = size(maski,1);
h3 = size(maski,2);
d3 = size(maski,3);


if (w1~=w2 | h1~=h2 | d1~=d2)
    ffprintf('Images for ppiterative must be the same size');
    return;
end
if (w1~=w3 | h1~=h3 | d1~=d3)   
    ffprintf('Images for ppiterative must be the same size');
    return;
end

img1 = reshape(img1,[w1,h1,d1]); %This reshape is necessary since
img2 = reshape(img2,[w2,h2,d2]); %size(img) can be 512x512 only
maski = reshape(maski,[w3,h3,d3]); %it will still return 1 for size(img,3)
%This forces 2D image to carry the singleton in its dimenstion and look 3D

x = double(img1(maski));
y = double(img2(maski));

fun = inline('b(1) + b(2)*x', 'b', 'x');

x1 = x - mean(x);
y1 = y - mean(y);
mu11 = sum(x1.*y1);
mu20= sum(x1.*x1);
mu02 = sum(y1.*y1);
m = 2*mu11/(mu20-mu02);
alpha = atan(m);
if alpha < 0 
    alpha = alpha + pi;
    if alpha < 0 error('Error, cannot get positive angle');
    end
end
alpha = 0.5 * alpha;
be(2) = tan(alpha);
be(1) = mean(y)-be(2)*mean(x);

max1 = max(x);
max2 = max(y);
min1 = min(x);
min2 = min(y);
if fun(be,max1) > max2
    xstart = (max2-be(1))/be(2);
else
    xstart = max1;
end
if fun(be,min1) < min2
    xfinal = (min2-be(1))/be(2);
else
    xfinal = min1;
end

no_corr = 0;
thresh1 = xstart - (xstart-xfinal)/200; % Assume intensities are integers
rp_old = pearson(img1,img2,maski);
while ~no_corr
    thresh2 = fun(be,thresh1);
    neg_mask = and(img1 >= thresh1,img2 >= thresh2);
    neg_mask = and(~neg_mask,maski);
    rp = pearson(img1,img2,neg_mask);
%     fprintf('%f %f %f\n',rp,thresh1,thresh2);
    if (rp<0. | thresh1 < xfinal)
        no_corr = 1;
    else
        rp_old = rp;
        thresh1 = thresh1 - (xstart-xfinal)/200;
    end
end
fprintf('Thresholds: %f %f\n',thresh1,thresh2);
r_img = and(img1>=thresh1,maski);
g_img = and(img2>=thresh2,maski);
thresh = [thresh1,thresh2];
final_mask = and(r_img,g_img);
if (Ndim == 2)    
    img3 = squeeze((normalize(img1,maski)*normalize(img2,maski))*final_mask);
    final_mask = squeeze(and(r_img,g_img));
    r_img = squeeze(r_img);
    g_img = squeeze(g_img);
else
    img3 = (normalize(img1,maski)*normalize(img2,maski))*final_mask;
end
    
    