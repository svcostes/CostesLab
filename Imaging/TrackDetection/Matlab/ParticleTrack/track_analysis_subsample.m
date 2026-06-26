function [track_data] = track_analysis_nonuc(color_img,scale)
% [track_data] = track_anlysis_nonuc(color_img,scale)
%
% Will display from a color image segmented nuclei (blue channel) and let
% you pick which nuclei should be kept for track analysis.
% Then, for each picked nucleus, the operator will have to draw the line
% defining each track.
% The routine will then identify each maximum along the track and compute
% the distance between consecutive ones.
% Output (array):
% [nucID trackID x y z in1 in2 in3 max2 max3 dist2 dist3] (X Y Z are
% position along track in absolute coordinates, assuming scale was given)
% 
%
% Sylvain Costes, LBNL November 2005

if ~exist('scale')
    scale = [1 1 1];
else
    if size(scale) == [3 1]
        scale = scale';
    elseif size(scale) ~= [1 3]
        error('Scale parameter must have 3 values [X Y Z] (um)');
    end
end

scale = scale(1); % Only use XY scale for track since they are horizontal

resolution = 0.2;
min_size = 2; % This value is used to compute the random distance. Based on data, a sigma of 2 is appropriate to represent foci from X-ray (sc041305)
iteration = 100;
distance = [];
distance_rand = [];
sigma = 0.25/scale(1);
track_data = [];
limits=size(color_img{1});
subsample = color_img; %(0:1:limits(1)-1,0:1:limits(2)-1,:);

% First get all tracks processed
    %dipshow(99,color_img,'lin');
    dipshow(99,subsample,'lin');
    diptruesize(99,300);
    [track_intensity,track_coords] = multiprofile_duncan(99);
    track_coords = track_coords;
    n_track = length(track_intensity);
    track_cnt = 1;
    for i=1:n_track % Loop on each track 
        if length(track_intensity{i})>1
            nucID = ones(size(track_coords{i}(:,1)),1); % First column index label the nucleus number
            trackID = track_cnt*(nucID>0); % Second column index label track number for the nucleus
            x = round(1.*track_coords{i}(:,1)); %Make sure if change subsample to change these too
            y = round(1.*track_coords{i}(:,2)); %Make sure if change subsample to change these too
            z = track_coords{i}(:,3);
            in1 = track_intensity{i}(:,1);
            in2 = track_intensity{i}(:,2);
            in3 = track_intensity{i}(:,3);
            max2 = track_intensity{i}(:,4);
            max3 = track_intensity{i}(:,5);
            dist2 = zeros(size(in2));
            dist3 = zeros(size(in3));
            max_index2 = find(max2==1);
            for k=1:length(max_index2)-1
                j = max_index2(k);
                jj = max_index2(k+1);
                dist2(max_index2(k)) = sqrt((x(j)-x(jj))^2 + (y(j)-y(jj))^2)*scale;
            end
            max_index3 = find(max3==1);
            for k=1:length(max_index3)-1
                j = max_index3(k);
                jj = max_index3(k+1);
                dist3(max_index3(k)) = sqrt((x(j)-x(jj))^2 + (y(j)-y(jj))^2)*scale;
            end
            track_data = [track_data; nucID trackID x y z];
            track_cnt = track_cnt + 1;
        end
    end

