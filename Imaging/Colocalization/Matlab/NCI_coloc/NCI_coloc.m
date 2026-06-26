% [list_out,col3D,ROI_mask,P_img,Col_mask,red_th,green_th,colAREA] = NCI_coloc(img1,img2,'option string',option value)
%
% FUNCTION:  NCI_coloc evaluate thoroughly the colocalization between img1 and img2.
%
% There are a variety of input parameters that can be changed in order to assess the
% colocalization between both images.
%
% Basid input: img1,img2
% img1:  input "red" image
% img2:  input "green" image
%
% Additional option
% 'background': Background options:
%        - [rbg,gbg]   = Use entered fixed backgrounds for red and green
%        - If no proper vector of background values entered, it will prompt
%        user to enter manually a region of interest to use for background
%        computation
% 'mask': Analysis only in region of interest
%        - mask= Binary mask image to use for co-localization.
%        - If no valid binary image is given, it will prompt the user to
%        draw it manually
% 'pvalue': If 1, will compute P-value (expensive in CPU time), otherwise
% will skip this. 
%
% Output:
% 1 - Text file: 'colocalization_summary.txt' saved under current directory.
% 2 - Same output is also listed out into output variable list_out.
% 3 - Output variables: [list_out,col3D,ROI_mask,P_img,Col_mask,red_th,green_th]
%   - list_out (all important scalars derived from analysis. see below for details)
%   - col3D: color image with the red and green image shown only in
%            region of interest (i.e. where colocalization is computed) and with a
%            blue contour indicating colocalized region. Note, this image is
%            automatically displayed during execution. To save it as a variable
%            though, you need to pass it as an output variable.
%   - ROI_mask: mask of regions where colocalization was computed
%   - P_img: Pearson image computed by ppiterative, i.e.:
%            corrrelation contribution for individual pixels 
%           (img1-<img1>)*(img2-<img2>)/[sqrt(img1^2)xsqrt(img2^2)]
%            Note: This image is automatically displayed during execution
%   - Col_mask: Mask of colocalized area
%   - red_th: thresholded red image
%   - green_th: thresholded green image
%   - colAREA: Overlay of red and green mask. Parts where yellow appears is
%              the colocalized area.
%              Note: This image is automatically displayed during execution
%
% IntCor               (1)  = Correlation coefficient between img1 and img2 over mask (rp in pgr)
% Probab               (2)  = Probability to have colocalization
% AutoX, AutoY, AutoZ (3-5) = Minimum FWHMs of autocorrelation of img1 and img2 in all three directions
%
% ROIarea              (6)  = ROI area         (Rarea in pgr)
% COLarea              (7)  = Colocalized area (Carea in pgr)
%
% RIntR                (8)  = Mean red intensity of ROI
% RIntG                (9)  = Mean green intensity of ROI
% CIntR                (10) = Mean colocalized red intensity
% CIntG                (11) = Mean colocalized green intensity
% IIntR                (12) = Mean red non-colocalized intensity
% IIntG                (13) = Mean green non-colocalized intensity
% TRIntR               (14) = Total red intensity of ROI
% TRIntG               (15) = Total green intensity of ROI
% TCIntR               (16) = Total colocalized red intensity
% TCIntG               (17) = Total colocalized green intensity
% TIIntR               (18) = Total red non-colocalized intensity
% TIIntG               (19) = Total green non-colocalized intensity
%
% colocI               (20) = % colocalized area  () = COLarea/ROIarea
% IColR                (21) = % colocalized red intensity   () = TCIntR/TRIntR
% IColG                (22) = % colocalized green intensity   () = TCIntG/TRIntG
% AColR                (23) = % colocalized area of the thresholded red
% AColG                (24) = % colocalized area of the thresholded green
% TACol                (25) = % colocalized area of the total thresholded area
% RedBckgd             (26) = Red background
% GreenBckgd           (27) = Green background
% RedTh                (28) = Red threshold value
% GreenTh              (29) = Green threshold value
%
% (C) Copyright 2000-2004               Image Analysis Laboratory
%     All rights reserved               SAIC-Frederick, Inc.
%                                       National Cancer Institute
%                                       PO BOX B
%                                       FREDERICK, MD 21702 USA 
%
% Sylvain Costes, November 2001
%
% Cleaned up for Zeiss, December 2006, March 2007
% Sylvain Costes, Lawrence berkeley National Laboratory

function [list_out,col3D,ROI_mask,P_img,Col_mask,red_th,green_th,colAREA] = NCI_coloc(img1,img2,varargin)


%**************************
% Check image sizes  first
%**************************

w1 = size(img1,1);
h1 = size(img1,2);
d1 = size(img1,3);
w2 = size(img2,1);
h2 = size(img2,2);
d2 = size(img2,3);

if (w1~=w2 || h1~=h2 || d1~=d2)
    fprintf('Images for inside colocalization must be the same size');
    return;
end

% Test if images have any content. Necessary for some weird images at
% NCI
if (w1 == 0 || h1 == 0)
    fprintf('Blank images...\n');
    col3D = [];
    ROI_mask = [];
    P_img = [];
    Col_mask = [];
    red_th = [];
    green_th = [];
    list_out = [];
    return;
end

% *******************************************
% Set default options or read optional input
% *******************************************

n_arg = length(varargin); % # of arguments
maskopt = 'none';
bgdopt = 'none';
ROI_mask = newim(size(img1)); % Set ROI to full image initially
pvalue_opt = 0;

for i=1:2:n_arg
    switch(varargin{i})
        case 'mask'
            try % In case no second input entered, then go manual for mask
                if (strcmp(class(varargin{i+1}),'dip_image')) % In case second input is not an image, then go manual for mask too
                    ROI_mask = varargin{i+1}>0; % Boolean test here to turn any non boolean image into one
                    maskopt = 'mask';
                else
                    maskopt = 'manual';
                end
            catch
                maskopt = 'manual';
            end
        case 'background'
            if (length(varargin{i+1})==2)
                rbg = varargin{i+1}(1);
                gbg = varargin{i+1}(2);
                rsbg = 0; % Standard deviation for background. This variable only makes sense if bgg is computed from ROI (see below)
                gsbg = 0;
                fprintf('Background entered manually: %d %d\n',rbg,gbg);
            else
                bgdopt = 'manual'; % In this case, ROI will be drawn and background set equal to the mean + 1 Standard deviation
            end
        case 'pvalue'
            pvalue_opt = varargin{i+1}>0;
    end
end

% *****************
% Start processing
% *****************

% Open summary file
ofp = fopen('colocalization_summary.txt','w');

img1 = reshape(img1,[w1,h1,d1]); %This reshape is necessary
img2 = reshape(img2,[w2,h2,d2]); %to make img1 and img2 look 3D in any case
ROI_mask = reshape(ROI_mask,[w2,h2,d2]); %to make img1 and ROI look 3D in any case

% Apply background corrections
switch bgdopt
    case 'none'
        rbg = 0;
        gbg = 0;
        rsbg = 0;
        gsbg = 0;
    case 'manual'
        mid_img1 = img1(:,:,fix(d1/2));
        mid_img1 = reshape(mid_img1,[w1,h1]);
        dipshow(90,mid_img1,'percentile');
        set(90,'Position',[200,100,600,600]);
        set(90,'Name','Please, select the background area for the red image');
        roi1 = dipcrop(90);
        rbg = mean(roi1);
        rsbg = std(roi1);
        mid_img2 = img2(:,:,fix(d1/2));
        mid_img2 = reshape(mid_img2,[w1,h1]);
        dipshow(90,mid_img2,'percentile');
        set(90,'Position',[200,100,600,600]);
        set(90,'Name','Please, select the background area for the green image');
        roi2 = dipcrop(90);
        delete(90);
        gbg = mean(roi2);
        gsbg = std(roi2);
        fprintf('The red background is %5.2f +/- %5.2f\n',rbg,rsbg);
        fprintf('The green background is %5.2f +/- %5.2f\n',gbg,gsbg);
end
rbg = rbg + rsbg;
gbg = gbg + gsbg;
img1 = clip(img1,Inf,rbg)-rbg; % Subtract background and set neg value to 0 for red image
img2 = clip(img2,Inf,gbg)-gbg; % Subtract background and set neg value to 0 for green image

% Determine mask
switch (maskopt)
    case 'manual'
        for k=0:d1-1 % Enter manually for each slice (in case of 3D image) contour where colocalization should be computed
            display_img = colorspace(newimar(stretch(img1(:,:,k)),stretch(img2(:,:,k)),ROI_mask(:,:,k)),'rgb');
            dipshow(90,display_img);
            set(90,'Position',[200,100,600,600]);
            set(90,'Name','Draw around the ROI inside which you want to test colocalization');
            ROI_mask(:,:,k) = diproi(90);
        end
        delete(90);
    case 'none'
        ROI_mask(:) = 1;
end

ROI_mask = ROI_mask >0; %Make sure resulting is binary

% Determine overlap and pearson values (i.e. ro, rp)
[ro,rp]=overlap(img1,img2,ROI_mask);

% Determine probability that reported colocalization is real. Only do it 
% if pearson greater than 5%. Under, most likely waste of time. Not real.
if (pvalue_opt && rp > 0.05)   
    [proba,stepout] = shrink_proba(img1,img2,ROI_mask,100,0,0,0);
    fprintf('Colocalization (Pearson coef: %5.2f%%)\n',rp*100);
    fprintf('Probability of inside colocalization: %6.4f\n',proba);
    stepx = stepout(1);
    stepy = stepout(2);
    stepz = stepout(3);
else
    proba = NaN;
    stepx=1;stepy=1;stepz=1;
end

% Call iterative method that extract colocalization mask based on 2D
% histogram of img1 and img2 over ROI_mask. red_th and green_th are the
% thresholded mask for each channel. Col_mask is the overlap of these two
% masks. P_img is the Pearson image (corrrelation contribution for
% individual pixels (img1-<img1>)*(img2-<img2>)/[sqrt(img1^2)xsqrt(img2^2)]
[P_img,Col_mask,red_th,green_th,th] = ppiterative(img1,img2,ROI_mask);
% Shop Pearson image with hot lookup table. red indicates strong
% correlation of pixel... blue none

%% Display of images has been turned off
% figure(99)
% subplot(3,1,1)
% dipshow(99,P_img,'lin')
% colormap(jet)

%Compute intensities and % colocalization
Carea = sum(Col_mask);
Rarea = sum(ROI_mask);
colocI = Carea/Rarea;
AColR = Carea/sum(red_th);
AColG = Carea/sum(green_th);
g_r_th = or(green_th,red_th); % Store in g_r_th overlap of red and green th 
TACol  = Carea/sum(g_r_th);
TRIntR = sum(img1(ROI_mask));
TRIntG = sum(img2(ROI_mask));
RIntR  = mean(img1,ROI_mask);
RIntG  = mean(img2,ROI_mask);
if (Carea)
    TCIntR = sum(img1(Col_mask));
    TCIntG = sum(img2(Col_mask));
    CIntR = mean(img1(Col_mask));
    CIntG = mean(img2(Col_mask));
else
    TCIntR = 0;
    TCIntG = 0;
    CIntR = 0;
    CIntG = 0;
end
inverse_mask = and(ROI_mask,~Col_mask);
TIIntR = sum(img1,inverse_mask);
TIIntG = sum(img2,inverse_mask);
IIntR = mean(img1,inverse_mask);
IIntG = mean(img2,inverse_mask);
IColR = TCIntR/TRIntR;
IColG = TCIntG/TRIntG;

% Create color image: Red = img1, Green = img2, Blue contour = coloc area
img1 = img1*ROI_mask;
img2 = img2*ROI_mask;
roi3 = (bdilation(Col_mask,2)-Col_mask)*255;
col3D = newimar(stretch(img1),stretch(img2),roi3);
col3D = colorspace(col3D,'RGB');

% Create color overlay of red threshold, green threshold and coloc
% threshold image (binary overlap)
colAREA = colorspace(newimar(red_th*255,green_th*255,newim(size(img1))),'rgb');

% Print simple output
fprintf('Volume-based co-localization values (object concept):\n');
fprintf('Volume of ROI being co-localized: %5.2f%%\n',colocI*100);
fprintf('Volume of red "objects" being co-localized in ROI: %5.2f%%\n',AColR*100);
fprintf('Volume of green "objects" being co-localized in ROI: %5.2f%%\n',AColG*100);
fprintf('\nIntensity-based co-localization values (to quantify protein proximity in a diffuse pattern)\n');
fprintf('Pearson coefficient: %5.2f%%\n',rp*100);
fprintf('Red intensity being co-localized: %5.2f%%\n',IColR*100);
fprintf('Green intensity being co-localized: %5.2f%%\n',IColG*100);
fprintf('Probability of co-localization to not be the result of random pixel distribution:%5.2f\n\n',proba);

% Print full output
fprintf(ofp,'IntCor\tProbab\tAutoX\tAutoY\tAutoZ\tROIarea\tCOLarea\t');
fprintf(ofp,'RIntR\tRIntG\tCIntR\tCIntG\tIIntR\tIIntG\tTRIntR\tTRIntG\tTCIntR\tTCIntG\tTIIntR\tTIIntG\t');
fprintf(ofp,'colocI\tIColR\tIColG\tAColR\tAColG\tTACol\tRedBckgd\tGreenBckgd\tRedTh\tGreenTh\n');
fprintf(ofp,'%5.2f%%\t',rp*100);
fprintf(ofp,'%6.4f\t',proba);
fprintf(ofp,'%d\t',[stepx,stepy,stepz,Rarea,Carea]);
fprintf(ofp,'%5.4e\t',[RIntR,RIntG,CIntR,CIntG,IIntR,IIntG,TRIntR,TRIntG,TCIntR,TCIntG,TIIntR,TIIntG]);
fprintf(ofp,'%f\t',[colocI,IColR,IColG,AColR,AColG,TACol,rbg,gbg,th(1),th(2)]);
list_out =  [rp,proba,stepx,stepy,stepz,Rarea,Carea,RIntR,RIntG,CIntR,CIntG,IIntR,IIntG];
list_out = [list_out,TRIntR,TRIntG,TCIntR,TCIntG,TIIntR,TIIntG,colocI,IColR,IColG,AColR,AColG,TACol,rbg,gbg,th(1),th(2)];

fclose(ofp);