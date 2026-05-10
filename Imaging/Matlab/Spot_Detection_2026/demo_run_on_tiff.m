function demo_run_on_tiff()
% DEMO_RUN_ON_TIFF
% Minimal demo showing how to run the foci pipeline on a single TIFF.
% Assumptions:
%   - You have DIPimage installed and on the MATLAB path.
%   - The TIFF is either:
%       (A) a single-channel image (used as the spot channel), OR
%       (B) a 2-page TIFF where page 1=DAPI and page 2=spot channel.
%   - If you do not have a precomputed nuclear mask, this demo will
%     segment nuclei from the DAPI image using nuc_segmentor_local.
%
% Output:
%   - displays label image of nuclei and detected foci mask.

addpath(genpath(fullfile(pwd,'..','src')));

param_file = fullfile(pwd,'human_blood_params.txt');
params = load_params(param_file);

tif_file = fullfile(pwd,['30 min sans evs 2.tif']);
disp(tif_file)
img = readim(tif_file, 'bioformats');


% Image2D lue avec deux canaux1
if ndims(img) == 3 && size(img,3) >= 2
    dapi = squeeze (img(:,:,0));
    spot = squeeze (img(:,:,1));
else
    % Fallback: single-channel demo
    dapi = img;
    spot = img;
end

% Segment nuclei (rough) if no mask provided
%[label_nuc, nuc_mask] = nuc_segmentor_local(dapi, params.nuc_rad, params.nuc_th, 1, 1, 1);
%label_nuc = relabel(label_nuc);

nuc_mask=threshold (dapi, 'isodata');
%measure (label (nuc_mask),dapi,'size') % we used the measure function to determine min and max size of nuclei
nuc_mask = areaopening (nuc_mask,1000); 
large_mask = areaopening (nuc_mask, 10000);
nuc_mask= nuc_mask - large_mask;

% Create an empty seed image of the same size as 
edge_mask = newim(nuc_mask, 'bin'); 
edge_mask (0,:) = 1;
edge_mask (end,:) = 1;
edge_mask (:,0) = 1;
edge_mask (:,end) = 1;
nuc_mask = nuc_mask + edge_mask;
label_mask = label (nuc_mask);
nuc_mask = label_mask > 1;
label_nuc = label (nuc_mask);

% Run spot detection (core)
[spot_struct, spot_mask, label_nuc, full_spot] = james_spot_detection7(spot, label_nuc, params.max_foci_size, 100, params.min, params.k_val, 2, 1);
foci_per_nucleus = [spot_struct.nucID, spot_struct.count];
disp(foci_per_nucleus);
disp(spot_struct);

figure; dipshow(label_nuc); title('Nuclei labels');
figure; dipshow(full_spot>0); title('Detected foci regions (full\_spot>0)');
end
