%autocor_FWHM  computes autocorrelation FWHM in x, y, z directions
% Returns the full with half max (FWHM) of the auto-correlation of the input image.
% This routine is based on a mask and the images are shifted via the routine shift_nowrap.
% The overlapping region of the mask with its shifted copy is the region where the pearson
% coefficient is computed.

% input: Grey 2D/3D image
% input: Mask image where autocorelation FWHM must be computed.
% output: Returns integer array: (stepx,stepy,stepy).

% (C) Copyright 2000-2001               Image Analysis Laboratory
%     All rights reserved               SAIC-Frederick, Inc.
%                                       National Cancer Institute
%                                       PO BOX B
%                                       FREDERICK, MD 21702 USA 
%
% Sylvain Costes, November 2001
% Adapted from autocor_FWHM.c in scilimage written by S. Costes in March 2001

function stepxyz = autocor(img1,mask)

t = cputime;

w1 = size(img1,1);
h1 = size(img1,2);
d1 = size(img1,3);

mask = mask>0; % make sure mask is binary

% Make routine work on 2D and 3D at the same time...
img1 = reshape(img1,[w1,h1,d1]);
mask = reshape(mask,[w1,h1,d1]);

% Determine the FWHM in the x direction as stepx

 step_flag = 1;
 i = 1;
 xmax = 0;
 while (step_flag)
   temp=shift_nowrap(img1,[i,0,0]);
   temp_mask=shift_nowrap(mask,[i,0,0]);
   temp_mask = and(mask,temp_mask);
   [sro,srp] = overlap(img1,temp,temp_mask);
   if (sum(temp_mask)<1)
       fprintf('FWHM was not reached on x+, last ratio was %5.2f\n',srp);
       break;
   end
   if (srp < 0.5) xmax = i-1; step_flag = 0; end
   i = i + 1;
   if (i > w1/2) break; end
 end

 step_flag = 1;
 i = -1;
 xmin = 0;
 while (step_flag)
   temp = shift_nowrap(img1,[i,0,0]);
   temp_mask=shift_nowrap(mask,[i,0,0]);
   temp_mask = and(mask,temp_mask);
   [sro,srp] = overlap(img1,temp,temp_mask);
   if (sum(temp_mask)<1)
       fprintf('FWHM was not reached on x-, last ratio was %5.2f\n',srp);
       break;
   end
   if (srp < 0.5) xmin = i+1; step_flag = 0; end
   i = i - 1;   
   if (i < -w1/2) break; end
 end

 stepx = xmax - xmin;

 if (stepx == 0 ) stepx = 1; end
 
% Determine the FWHM in the y direction as stepy

 step_flag = 1;
 i = 1;
 ymax = 0;
 while (step_flag)
   temp=shift_nowrap(img1,[0,i,0]);
   temp_mask=shift_nowrap(mask,[0,i,0]);
   temp_mask = and(mask,temp_mask);
   [sro,srp] = overlap(img1,temp,temp_mask);
   if (sum(temp_mask)<1)
       fprintf('FWHM was not reached on y+, last ratio was %5.2f\n',srp);
       break;
   end
   if (srp < 0.5) ymax = i-1; step_flag = 0; end
   i = i + 1;
   if (i > h1/2) break; end
 end

 step_flag = 1;
 i = -1;
 ymin = 0;
 while (step_flag)
   temp = shift_nowrap(img1,[0,i,0]);
   temp_mask=shift_nowrap(mask,[0,i,0]);
   temp_mask = and(mask,temp_mask);
   [sro,srp] = overlap(img1,temp,temp_mask);
   if (sum(temp_mask)<1)
       fprintf('FWHM was not reached on y-, last ratio was %5.2f\n',srp);
       break;
   end
   if (srp < 0.5) ymin = i+1; step_flag = 0; end
   i = i - 1;   
   if (i < -h1/2) break; end
 end

 stepy = ymax - ymin;

 if (stepy == 0 ) stepy = 1; end
 
 % Determine the FWHM in the z direction as stepz

 if (d1 > 1)
   step_flag = 1;
   i = 1;
   zmax = 0;
   while (step_flag)
     temp=shift_nowrap(img1,[0,0,i]);
     temp_mask=shift_nowrap(mask,[0,0,i]);
     temp_mask = and(mask,temp_mask);
     [sro,srp] = overlap(img1,temp,temp_mask);
     if (sum(temp_mask)<1)
         fprintf('FWHM was not reached on z+, last ratio was %5.2f\n',srp);
         break;
     end
     if (srp < 0.5) zmax = i-1; step_flag = 0; end
     i = i + 1;
     if (i > d1/2) break; end
   end

   step_flag = 1;
   i = -1;
   zmin = 0;
   while (step_flag)
     temp = shift_nowrap(img1,[0,0,i]);
     temp_mask=shift_nowrap(mask,[0,0,i]);
     temp_mask = and(mask,temp_mask);
     [sro,srp] = overlap(img1,temp,temp_mask);    
     if (sum(temp_mask)<1)
         fprintf('FWHM was not reached on z-, last ratio was %5.2f\n',srp);
         break;
     end

     if (srp < 0.5) zmin = i+1; step_flag = 0; end
     i = i - 1;   
     if (i < -d1/2) break; end
   end

   stepz = zmax - zmin;
 
   if (stepz == 0 ) stepz = 1; end
 
 else  
   stepz = 1;
 end
 
 stepxyz = [stepx,stepy,stepz];
 
 e = cputime - t;
 fprintf('Time used:%f\n',e);