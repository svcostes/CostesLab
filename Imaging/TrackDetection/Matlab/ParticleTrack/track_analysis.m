function [track_data] = track_analysis(color_img,nuc_label,scale)
% [track_data] = track_analysis(color_img,scale)
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

nuc = color_img{3};
foci1 = color_img{2};
foci2 = color_img{1};

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
total_nuc = max(nuc_label);
sigma = 0.25/scale(1);
plane_foci1 = max(foci1,[],3);
plane_foci1 = reshape(plane_foci1,size(plane_foci1,1),size(plane_foci1,2),1);
plane_foci2 = max(foci2,[],3);
plane_foci2 = reshape(plane_foci2,size(plane_foci2,1),size(plane_foci2,2),1);
plane_nuc = nuc_label(:,:,fix(end/2));
nuc_list = select_nuclei(colorspace(newimar(plane_foci2,plane_foci1,plane_nuc),'rgb'));
sel_nuc = find(nuc_list(:,4)==2);
num_nuc = length(sel_nuc);
track_data = [];
    
% First get all tracks processed
for n_nuc = 1:num_nuc %Loop on each nucleus
    fprintf('%d/%d\n',n_nuc,num_nuc);
    nuc_label == sel_nuc(n_nuc);
    croped_nuc = crop_from_mask(color_img,nuc_label == sel_nuc(n_nuc));
    dipshow(99,croped_nuc,'lin');
    diptruesize(99,300);
    [track_intensity{n_nuc},track_coords{n_nuc}] = multiprofile(99);
    n_track = length(track_intensity{n_nuc});
    track_cnt = 1;
    for i=1:n_track % Loop on each track in nucleus
        if length(track_intensity{n_nuc}{i})>1
            nucID = ones(size(track_coords{n_nuc}{i}(:,1)),1)*n_nuc; % First column index label the nucleus number
            trackID = track_cnt*(nucID>0); % Second column index label track number for the nucleus
            x = track_coords{n_nuc}{i}(:,1);
            y = track_coords{n_nuc}{i}(:,2);
            z = track_coords{n_nuc}{i}(:,3);
            in1 = track_intensity{n_nuc}{i}(:,1);
            in2 = track_intensity{n_nuc}{i}(:,2);
            in3 = track_intensity{n_nuc}{i}(:,3);
            max2 = track_intensity{n_nuc}{i}(:,4);
            max3 = track_intensity{n_nuc}{i}(:,5);
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
            %     temp_max = randomize_track2(a{i}.data(:,7).*a{i}.data(:,5),'iteration',iteration,'size',min_size); % This will generate random foci position
            %     for iter =1:iteration
            %         max_index = find(temp_max(iter,:)==1);
            %         a{i}.data(:,8+iter)=0; % Clear in case it was ran before
            %         for k=1:length(max_index)-1
            %             j = max_index(k);
            %             jj = max_index(k+1);
            %             dist = sqrt((x(j)-x(jj))^2 + (y(j)-y(jj))^2)*scale;
            %             a{i}.data(j,8+iter) = dist;
            %         end
            %     end
            track_data = [track_data; nucID trackID x y z in1 in2 in3 max2 max3 dist2 dist3];
            track_cnt = track_cnt + 1;
        end
    end
end
