%normalize images by mean substraction and variance division over mask
%
% (C) Copyright 2000-2001               Image Analysis Laboratory
%     All rights reserved               SAIC-Frederick, Inc.
%                                       National Cancer Institute
%                                       PO BOX B
%                                       FREDERICK, MD 21702 USA 
%
% Sylvain Costes, October 2001

function nimg1 = normalize(img1,mask)

% Make sure mask is binary if it exists
try
    mask = (mask>0);
catch
    mask = dip_image(ones(size(img1)),'bin8');
end
img1 = (img1-mean(img1(mask)));
img1 = img1*mask;
nimg1 = img1/sqrt(sum(img1^2));
