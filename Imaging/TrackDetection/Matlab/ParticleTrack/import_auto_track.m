function [out_cell, dist, dist_rand, Ntrack, Rdna, Rgrad] = import_auto_track(filename, xyscale, num_iteration ,image_name)
% [out_cell, dist, dist_rand, N_track, Rdna, Rgrad] = import_auto_track(filename, xyscale, num_iteration, image_name)
% image_name is optional. If on, then, will load this image for Dapi
% profile overloading anything else that was in the excel file read
% This routine will read a line scan log from automatic detection of track and upload into
% out_cell array of structure
% This is the assumed format for track:
% Image ID, nuc ID,  track ID, x,  y,  z,  I red, I green, I blue, Green Focus Binary, Red Focus Binary, dist Green,  dist Red
% Each Image ID listing are separated by a 2 lines header information
%
% If num_iteration is 0, no randomization will be done to compute random
% distances
%
% Example:
% out_cell = import_auto_track('/path/wc102306wc1_track_data.xls',0.16,100,'/image_dir/wc102306wc1')
% This will load the excel file wc102306wc1_track_data.xls, give a xy scale
% of 0.16 um to the output profiles and operate 100 random iteration per
% track. It will also load wc102306wc1_D???.tif corresponding images to get
% the blue profile. This is due to an old bug that had created xls files
% without the blue component.
%
% Format of out_cell
% Image ID nuc ID  track ID x  y  z  I red  I green I blue Max Green  Max Red dist Green  dist Red
% Note: x y z are in subpixel resolution (line extrapolation) but in pixel
% not in um. On the other hand distances are already in um.
% example : 1 1 1 etc....
% format of dist
% dist{image_id,1:2} = column vectors with all distances computed for image
% number Image ID
% dist_rand{image_id,1:2} = column vectors with all distances computed for image
% number Image ID after randomization of maximum (with num_iteration
% iterations)
% Rdna{image_id,1:2} = column vectors Rdna Rdna_rand Rdna_rand_std for
% image Image ID, for signal 1 and signal 2
% Rgrad{image_id,1:2} = column vectors Rgrad Rgrad_rand Rgrad_rand_std for
% image Image ID, for signal 1 and signal 2

% Sylvain Costes, LBL, September 2007
% Modified from import_line_Sylvain


% Initial values for max detection
max_depth1 = 50;
max_depth2 = 50;
max_size = 100;
Ntrack(1) = 0;
nogreen = 0; % If set to 1, randomization will be skipped
nored = 0; % If set to 1, randomization will be skipped

% START LOOP ON INDIVIDUAL SET OF LINES
try
    num_iteration;
catch
    num_iteration = 0;
end
try
    fprintf('scale in xy direction: %f\n',xyscale);
catch
    xyscale = 0;
end
try % Due to forgetting to load nuclear profile in track_analysis_subsample.m, need to read image and apply coordinate to it. Temp fix, if image_name exists
    if (isstr(image_name))
        load_dapi = 1;
    else
        load_dapi = 0;
    end
catch
    load_dapi = 0;
end

fid = fopen(filename,'r');
%added by Duncan, revised output file
% dfid = fopen('complete','a');
% dfiddist = fopen('dist','a');
% dfiddistrand = fopen('distrand','a');
% if dfid==-1
%     error('Cannot open/create file: %s','complete');
% end
% %end added by Duncan
% if fid==-1
%     error('Cannot open file: %s',filename);
% end
% fseek(fid, 0, 'eof'); %Determine position of end of file
% num_eof = ftell(fid);
% frewind(fid);

% Automatic output is a single file with no space between tracks or
% imageID. Read the whole thing at once.
a = textscan(fid,'%d%d%d%f%f%f%f%f%f%d%d%f%f%*[^\n]','headerlines',2);
% Find each image. image_index stores the index of the last input line for
% an image
[a_temp,image_index] = unique(a{1});
image_index = [0; image_index];
for i=1:13 % This is necessary, otherwise vertical cat for out_cell turns everything into int32 !!!
    a{i} = double(a{i});
end

% Try to figure out scale from distance vector in case not known by operator
if (xyscale ==0)
    try
        positive_dist = find(a{12}>0);
        xyz = [a{4}(:,1) a{5}(:,1) a{6}(:,1)];
        if isempty(positive_dist) % this check is here in case image only had red. Then need to look at distance from red distance instead
            positive_dist = find(a{13}>0);
        end
        v = sqrt(sum(diff(xyz(positive_dist(1:2),:)).^2,2));
        xyscale = a{12}(positive_dist(1),:)./v;
        fprintf('scale in xy direction: %f\n',xyscale);
    catch
        fprintf('Could not figure out scale in image. Distance will be in pixel\n');
    end
end

for count_input = 1:length(image_index)-1

    imageID = a{1}(image_index(count_input+1));
    fprintf('Processing tracks from imageID: %d, %d ouf of %d images\n',imageID,count_input,length(image_index));

    if load_dapi
        fprintf('Loading:%s\n',[image_name,'_D',int2str_format(double(imageID),3),'.stk']);
        dapi_img = read_gray_stack([image_name,'_D',int2str_format(double(imageID),3),'.stk']);
    end

    image_range = [image_index(count_input)+1:image_index(count_input+1)];

    out_cell{imageID} = [a{1}(image_range),a{2}(image_range),a{3}(image_range),a{4}(image_range),a{5}(image_range),...
        a{6}(image_range),a{7}(image_range),a{8}(image_range),a{9}(image_range),a{10}(image_range),...
        a{11}(image_range),a{12}(image_range),a{13}(image_range)];

    dist{1}{imageID} = [];
    dist{2}{imageID} = [];
    Rdna{1}{imageID} = [];
    Rdna{2}{imageID} = [];
    Rgrad{1}{imageID} = [];
    Rgrad{2}{imageID} = [];
    dist_rand{1}{imageID} = [];
    dist_rand{2}{imageID} = [];

    % If num_iteration exists, randomization for all track in image_ID
    if num_iteration > 0
        [track_ID,track_index] = unique(a{3}(image_range));
        Ntrack(imageID) = length(track_index);
        track_index = image_range(track_index); % This is necessary to put track_index back in absolute index
        track_index = [image_range(1); track_index'+1];
        % Start loop on track. For each track, randomize it and store
        % distances of random peaks into dist_rand{imageID,:}
        %
        for count_track = 1:Ntrack(imageID)
            % Get track coordinates and load dapi profile in case need
            % to overload it (option due to an old bug)
            track_range = track_index(count_track):(track_index(count_track+1)-1);
            xyz = [a{4}(track_range,1) a{5}(track_range,1) a{6}(track_range,1)]; %These xyz coordinates are subpixels
            if load_dapi
                a{9}(track_range,1) = get_subpixel(dapi_img,xyz);
            end
            temp_gray = dip_image(a{8}(track_range,1));
            temp =  label(dip_image(a{10}(track_range,1)),1);% Green channel is first
            temp_max1 = newim(size(temp));
            for seg_i = 1:max(temp)
                [mtemp,in_temp]=max(temp_gray*(temp==seg_i));
                temp_max1(in_temp) = 1;
            end
            temp_gray = dip_image(a{7}(track_range,1));
            temp =  label(dip_image(a{11}(track_range,1)),1); % Red channel is second
            temp_max2 = newim(size(temp));
            for seg_i = 1:max(temp)
                [mtemp,in_temp]=max(temp_gray*(temp==seg_i));
                temp_max2(in_temp) = 1;
            end
            temp_max1 = double(temp_max1');
            temp_max2 = double(temp_max2');
            a{10}(track_range,1) = temp_max1;
            a{11}(track_range,1) = temp_max2;
            % Get dna track and compute its gradient in 1D
            dna_track = a{9}(track_range,1);
            track_grad = sqrt(diff(dna_track).^2);
            track_grad(end+1) = track_grad(end);
            track_grad(2:end-1) = 0.5*(track_grad(1:end-2) + track_grad(2:end-1)); % Average over two points around peak for derivative

            % Compute max distance, Rdna and Rgrad for green signal
            positive_dist = find(temp_max1>0);
            if length(positive_dist)>2 % Do not store any track info made of 2 foci or less
                %                 min_edge = min(positive_dist);
                %                 max_edge = max(positive_dist);
                nuc_mask = dna_track>0;
                %                 nuc_mask(1:min_edge-1) = 0;
                %                 nuc_mask(max_edge+1:end) = 0;
                Rdna1 = mean(dna_track(positive_dist))/mean(dna_track(nuc_mask));
                Rgrad1 = mean(track_grad(positive_dist))/mean(track_grad(nuc_mask));                
                dist_temp = sqrt(sum(diff(xyz(positive_dist,:)).^2,2)).*xyscale;
                a{12}(track_range(positive_dist(1:end-1)),1) = dist_temp;
                dist{1}{imageID} = [dist{1}{imageID}; dist_temp]; % these distances are already in um from the dipprofile_syl routine
                % Randomize Green maximum
                if (nogreen == 0)
                    [rand_track,Rdna1_rand,Rgrad1_rand]  = randomize_track3(temp_max1',dna_track,'iteration',num_iteration,'size',0.05/xyscale*2); % sigma was optimized for scale of 0.05 in randomize_track2
                    rand_track = rand_track'; % Random track come out as rows. Need columns
                    for i=1:num_iteration
                        positive_rdist = find(rand_track(:,i)>0);
                        if length(positive_rdist)>1 % Make sure more than one peak before computing distance
                            rdist = sqrt(sum(diff(xyz(positive_rdist,:)).^2,2)).*xyscale;
                            dist_rand{1}{imageID} = [dist_rand{1}{imageID}; rdist];
                        end
                    end
                end
                % save Rdna and Rgrad values
                Rgrad{1}{imageID} = [Rgrad{1}{imageID};Rgrad1 Rgrad1_rand];
                Rdna{1}{imageID} = [Rdna{1}{imageID};Rdna1 Rdna1_rand];
            end

            % Compute max distance, Rdna and Rgrad for red signal
            positive_dist = find(temp_max2>0);
            if length(positive_dist)>2 % Do not store any track info made of 2 foci or less
                %                 min_edge = min(positive_dist);
                %                 max_edge = max(positive_dist);
                nuc_mask = dna_track>0;
                %                 nuc_mask(1:min_edge-1) = 0;
                %                 nuc_mask(max_edge+1:end) = 0;
                Rdna2 = mean(dna_track(positive_dist))/mean(dna_track(nuc_mask));
                Rgrad2 = mean(track_grad(positive_dist))/mean(track_grad(nuc_mask));
                dist_temp = sqrt(sum(diff(xyz(positive_dist,:)).^2,2)).*xyscale;
                a{13}(track_range(positive_dist(1:end-1)),1) = dist_temp;
                dist{2}{imageID} = [dist{2}{imageID}; dist_temp];
                % Randomize Red maximum
                if (nored == 0)
                    [rand_track,Rdna2_rand,Rgrad2_rand]  = randomize_track3(temp_max2',dna_track,'iteration',num_iteration,'size',0.05/xyscale*2); %Use default gaussian bluring, pretty optimized for 40X0.95
                    rand_track = rand_track';
                    for i=1:num_iteration
                        positive_rdist = find(rand_track(:,i)>0);
                        if length(positive_rdist)>1 % Make sure more than one peak before computing distance
                            rdist = sqrt(sum(diff(xyz(positive_rdist,:)).^2,2)).*xyscale;
                            dist_rand{2}{imageID} = [dist_rand{2}{imageID}; rdist];
                        end
                    end
                end
                % save Rdna and Rgrad values
                Rgrad{2}{imageID} = [Rgrad{2}{imageID};Rgrad2 Rgrad2_rand];
                Rdna{2}{imageID} = [Rdna{2}{imageID};Rdna2 Rdna2_rand];
            end
        end
    end

    % Reupdate output cell for max detected.
    %     for i=1:13 % This is necessary, otherwise vertical cat for out_cell turns everything into int32 !!!
    %         a{i} = double(a{i});
    %     end
    out_cell{imageID} = [a{1}(image_range),a{2}(image_range),a{3}(image_range),a{4}(image_range),a{5}(image_range),...
        a{6}(image_range),a{7}(image_range),a{8}(image_range),a{9}(image_range),a{10}(image_range),...
        a{11}(image_range),a{12}(image_range),a{13}(image_range)];
    % Added by Duncan
    %     [info] = read_gray_info2([image_name,'_D' ,int2str_format(double(imageID),3),'.stk']);
    %     treatment = info.treatment;
    %     fprintf(dfid,'%s\t%s\n',treatment,[image_name '_',int2str_format(double(imageID),3),'.stk']);
    %     fprintf(dfiddist,'%s\t%s\n',treatment,[image_name '_',int2str_format(double(imageID),3),'.stk']);
    %     fprintf(dfiddistrand,'%s\t%s\n',treatment,[image_name '_',int2str_format(double(imageID),3),'.stk']);
    %     fprintf(dfid,'\t\tImage ID\tnuc ID\ttrack ID\tx\ty\tz\tI red\tI green\tI blue\tMax Green\tMax Red\tdist Green\tdist Red\n');
    %
    %     for l=1:length(out_cell{imageID})
    %         fprintf(dfid,'\t');
    %         fprintf(dfid,'\t%f',out_cell{16}(l,:));
    %         %     fprintf(dfid,'\t%f',dist);
    %         %     fprintf(dfid,'\t%f',dist_rand);
    %         fprintf(dfid,'\n');
    %     end
    %
    %     for m=1:length(dist{2}{imageID}(1))
    %         fprintf(dfiddist,'\t');
    %         fprintf(dfiddist,'\t%f\t%f',dist{1}{imageID}(m),dist{2}{imageID}(m));
    %         fprintf(dfiddist,'\n');
    %     end
    %     for n=1:length(dist_rand{1}{imageID})
    %         fprintf(dfiddistrand,'\t%f',dist_rand{1}{imageID}(n));
    %         fprintf(dfiddistrand,'\n');
    %
    %     end
    %     save workspace
end
fclose(fid)


