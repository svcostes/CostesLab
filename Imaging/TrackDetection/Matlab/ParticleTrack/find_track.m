function final_track = find_track(img,mask)
% final_track = find_track(img,mask)
% Find high LET track in image img over mask
% Look for maximum mean intensity path for a variety of direction.
% Forces all track within the mask to be parallel.
%
% Sylvain Costes, Lawrence Berkeley National Lab
% April 2007

perc_angle = 70; % Range of search for maximum intensity track
perc_index = 5; % Increment between angle for search

% Make sure image is in 3D, even if 2D is passed
[w,h,d] = size(img);
img = reshape(img,w,h,d);
mask = reshape(mask,w,h,d);
mimg = squeeze(max(img,[],3));      %max projection
mmask = squeeze(max(mask,[],3));    %max projection

ang_cnt = 1;
for ang = -perc_angle:perc_index:perc_angle     %for each angle we examine
    line_mask = newim(w,h);
    cnt = 1;
    shift_pix = round(ang/100*w);       %should be (h-1)*tan(ang*(pi/180)))?
    %shift_pix = round((h-1)*tan(ang*(pi/180)));
    % Note: drawline can only do it when x and y coordinates are positive.
    % They can be out of bounds but they must be positive...
    if ang >0
        for i=0:w-1
            line_mask = drawline(line_mask,[i,0],[i+shift_pix,h-1],cnt);
            cnt = cnt + 1;
        end
    else
        for i=0:w-1
            line_mask = drawline(line_mask,[i,h-1],[i-shift_pix,0],cnt);
            cnt = cnt + 1;
        end
    end
    %line_mask = repmat(line_mask,[1 1 d]);
    %line_mask = dip_image(uint16(line_mask*mask));
    line_mask = dip_image(uint16(line_mask*mmask));
    ms = measure(line_mask,mimg,{'mean'});
    max_i(ang_cnt) = max(ms.mean);
    ang_cnt = ang_cnt + 1;
end

% Once brightest direction is found, compute position of tracks. Repeat
% line mask production
[max_total,max_index] = max(max_i);

ang_array = -perc_angle:perc_index:perc_angle;
ang = ang_array(max_index);
line_mask = newim(w,h);
cnt = 1;
shift_pix = round(ang/100*w);
% Note: drawline can only do it when x and y coordinates are positive.
% They can be out of bonds but they must be positive...
if ang >0
    for i=0:w-1
        line_mask = drawline(line_mask,[i,0],[i+shift_pix,h-1],cnt);
        cnt = cnt + 1;
    end
else
    for i=0:w-1
        line_mask = drawline(line_mask,[i,h-1],[i-shift_pix,0],cnt);
        cnt = cnt + 1;
    end
end
%line_mask = repmat(line_mask,[1 1 d]);
line_mask = dip_image(uint16(line_mask*mmask));
% Select lines that gives mean significantly higher than mean of full mask
% > mean + 0.5 Std
ms = measure(line_mask,mimg,{'mean'});
prof_track = dip_image(ms.mean);
prof_track = prof_track-gaussf(prof_track,4); % this step is to extract peaks better
th_int = 0.5*std(img,mask); % Sensitivity level
track_index = prof_track>th_int;
line_ID = ms.ID;
ms_track = measure(squeeze(track_index),[],'center');
keep_line = line_ID(round(ms_track.center));
final_track = newim(size(img));
for i=1:length(ms_track.center)
    temp_mask = (line_mask == keep_line(i));
    % In case of 3D image, need to keep only line in the brightest focal plane
    mean_line = [];
    for j=0:d-1
        mean_line(j+1) = mean(squeeze(img(:,:,j)),temp_mask);
    end
    [max_line,max_index] = max(mean_line);
    final_track(:,:,max_index-1) = final_track(:,:,max_index-1) + temp_mask ;
end

final_track = label(final_track>0);