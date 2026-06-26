function [pear,over] = pearson(varargin)
% [pear,over] = pearson(img1,img2,mask)
% Will compute the pearson coefficient between img1 and img2 for positive
% pixels in mask image.
% 
% Sylvain Costes, National Cancer Institute, 2002

% Flag for array of images
flagA = 0;

% Parse input
if nargin > 1
    ii = 1;
    while ii<nargin
        arg = varargin{ii};
        if ~isa(arg,'dip_image')
            error('Input must be at least 2 images or one array of images.');
        elseif isa(arg,'dip_image_array')
            error('Cannot proceed on two or more arrays of images');
        end
        ii = ii+1;
    end
elseif nargin == 1
    arg = varargin{1};
    if ~isa(arg,'dip_image_array') 
        error('Need at least two images');
    else
        fprintf('You enter an array of images. \nCorrelation between layer 1 and 2 for positive values of layer 3 is computed\n');
        flagA = 1;
    end
end

if flagA
    img1 = varargin{1}{1};
    img2 = varargin{1}{2};
    try 
        img3 = varargin{1}{3};
    catch
        img3 = newim(size(img1));
        img3(:) = 1;
    end
else
    img1 = varargin{1};
    img2 = varargin{2};
    try 
        img3 = varargin{3};
    catch
        img3 = newim(size(img1));
        img3(:) = 1;
    end
end

w1 = size(img1,1);
h1 = size(img1,2);
d1 = size(img1,3);
w2 = size(img2,1);
h2 = size(img2,2);
d2 = size(img2,3);
w3 = size(img3,1);
h3 = size(img3,2);
d3 = size(img3,3);

if (w1~=w2 | h1~=h2 | d1~=d2)
    error('Images 1 and 2 must be the same dimensions');
end
if (w1~=w3 | h1~=h3 | d1~=d3)
    error('Mask image must have the same dimensions as input images');
end

img1 = reshape(img1,w1,h1,d1);
img2 = reshape(img2,w1,h1,d1);
img3 = reshape(img3,w1,h1,d1);

[over,pear] = overlap(img1,img2,img3);

