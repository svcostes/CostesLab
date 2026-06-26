function [original_ratio,Rdna,Rgrad] = randomize_track5(foci_track,dna_track,track_grad,mask_track,varargin)
% [rand_track,original_ratio,Rdna,Rgrad,cnt_foci] = randomize_track4(foci_track,dna_track,mask_track,varargin)
% TRY HERE WITH A PROBABILITY APPROACH BASED ON XRAY SIMULATION RESULTS
% PROBA TO HAVE A FOCUS IS SIMPLY THE NUMBER OF FOCUS DIVIDED BY THE SUM OF
% DNA SIGNAL ALONG TRACK. THEN USE THAT PROBA TIMES THE DNA SIGNAL ALONG
% TRACK AND COMPARE THIS TO A RANDOM VALUE.
% Input:
% foci_track is a vector made of 0, except for position of focus center
% where the value is set to the intensity of the peak.
% dna_track is a vector of the DAPI intensity along track. Used as a
% weighting factor for randomizing spot position
% mask_track is a vector of the mask to use to compute Rdna and Rgrad.
% Usually this mask is smaller than the edges of DNA to avoid large
% gradient values at the edge of the nucleus.
%
% Output:
% rand_track is the same vector length with foci center position
% randomized.
%
% original_ratio: Rdna and Rgrad from given image
%
% Rdna is the random (DNA weighted) Rdna 
%
% Rgrad is the random (DNA weighted) Rgrad
%
%
% Example
% rand_track = randomize_track4(foci_track,dna_track,track_grad,mask_track)

%
% Sylvain Costes, LBNL, August 2005
% Modified from randomize_track2 on SEPT 2006
% Version 4 got rid of dip_localminima to detect max. Instead simply
% threshold with isodata. This gets rid of all the adjusting parameters
% Version 5:
% - got rid of randomization by iteration since output was the same
% by theoretical value and much fastet
% - changed track_grad to be passed in from user. randomize_track4
% version did not take into account lateral gradients. In this version,
% track_grad is the linear profile along the track of the full 3D gradient
% image.


% Compute gradient and turn all arrays to double
%track_grad = abs(gradient(dip_image(dna_track))); % this works only in dipimage. In matlab, different
%track_grad = double(track_grad)';
dna_track = double(dna_track);
foci_track = double(foci_track)>0;
mask_track = double(mask_track)>0;
original_ratio(1) = mean(dna_track(foci_track))/mean(dna_track(mask_track>0));
original_ratio(2) = mean(track_grad(foci_track))/mean(track_grad(mask_track>0));
fprintf('Rdna = %5.3f and Rgrad = %5.3f before randomization\n',original_ratio(1),original_ratio(2));

% In case tracks were made much larger than nucleus width, force randomization
% only between first and last focus along track.
index_edge = find(foci_track > 0);
if length(index_edge) == 1
    rand_track = repmat(foci_track,[iteration,1]);
    rand_gauss = rand_track;
    Rdna = [];
    Rgrad = [];
    cnt_foci = [];
    fprintf('Only one focus for this track\n');
else
    num_foci = max(label(dip_image(foci_track)*dip_image(mask_track)>0,1));
    dna_track_MC = dna_track.*mask_track;
    proba = (num_foci)/sum(dna_track_MC);
    dna_length = sum(mask_track>0);
    Rdna = sum(dna_track(mask_track).^2)/sum(dna_track(mask_track))^2*dna_length;
    Rgrad = sum(track_grad(mask_track).*dna_track(mask_track))/sum(track_grad(mask_track))/sum(dna_track(mask_track))*dna_length;
    fprintf('Theoretical random Rdna = %5.3f and Rgrad = %5.3f\n',Rdna,Rgrad);
end




