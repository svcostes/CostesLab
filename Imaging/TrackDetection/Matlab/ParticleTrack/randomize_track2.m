function [rand_track,rand_gauss] = randomize_track2(foci_track,dna_track,varargin)
% rand_track = randomize_track2(foci_track,varargin)
% foci_track is a vector made of 0, except for position of focus center
% where the value is set to the intensity of the peak.
% dna_track is a vector of the DAPI intensity along track. Used as a
% weighting factor for randomizing spot position
%
% Output:
% rand_track is the same vector length with foci center position
% randomized.
% rand_gauss is the same vector length with gaussian peak simulated for
% random peaks.
%
% Options:
% 'size': Default is set to 2, and can be modified. This is the sigma value
% used to simulate the focus shape using a gaussian filter. Then a local
% minima approach is used to detect the position of the peak.
%
% 'iteration': Default is 1. Number of randomization along the track. If
% more than 1, then rand_track and rand_gauss will be arrays, whose number
% of columns will be the lenght of foci_track and each row will represent
% one randomization.
% 
% 'max_depth': Default is 0.1. NOT AN OPTION ANYMORE. SINCE WE ONLY HAVE
% PEAKS TO RANDOMIZE, FAULT TO DETECT SHOULD ONLY HAPPEN WHEN TWO RANDOM
% EVENTS ARE LEADING TO A SINGLE PEAK. SO SET THIS TO VERY LOW TO MAKE SURE
% WE DONT MISSS ANY PEAK.
% 'max_size': Default is 2. Parameter used for local minima.
%
% 'min_dist': Default is 1. During randomization, minimum pixel distance
% between peak, befor running the gaussian.
%
% Example
% rand_track = randomize_track2(foci_track,'iteration',5,'size',2)

%
% Sylvain Costes, LBNL, August 2005
%
% See randomize_track for a simpler alternative

% default values
sigma = 2;
iteration = 1;
max_depth = 0.01;%DO NOT CHANGE!!!
max_size = 2;
min_dist = 1;

for i=1:2:length(varargin)
    if (~isstr(varargin{i}))
        fprintf('Property #%d is not a string\n',round(i/2));
        return;
    end
    switch(varargin{i})
        case 'size'
            sigma = varargin{i+1};
        case 'iteration'
            iteration = varargin{i+1};
        case 'max_size'
            max_size = varargin{i+1}; 
        case 'min_dist'
            min_dist = varargin{i+1};
    end
end

% In case tracks were made much larger than nucleus, force randomization
% only between first and last focus along track.
index_edge = find(foci_track > 0);
if length(index_edge) == 1
    rand_track = repmat(foci_track,[iteration,1]);
    rand_gauss = rand_track;
    fprintf('Only one focus for this track\n');
else
    min_edge = min(index_edge);
    max_edge = max(index_edge);
    mean_peak = mean(foci_track(foci_track>0));
    % Got rid of DNA track. Only kept it as weighting factor of value 1 if
    % between the first and last peak along the track.
     dna_track(1:min_edge-1) = 0;
     dna_track(min_edge:max_edge) = 1;
     dna_track(max_edge+1:end) = 0;
    num_foci = sum(foci_track>0);
    foci_track = sort(reshape(foci_track,[max(size(foci_track)),1]),1,'descend'); % Make foci track a single column vector and sort it.
    num_pixel = length(foci_track);
    foci_track(num_foci+1:end) = mean_peak; % Set all other pixel to mean peak in case we need to generate more random spot to get the same
                                            % total number of foci.
    rand_track = zeros(iteration,size(foci_track,1));
    index = 1:num_pixel;
        
    for k=1:iteration
        pos_rand = rand(num_pixel,1).*double((dna_track)); % Create a random number along track between 0 and 1 weighted by DAPI intensity value of pixel.
        [pos_rand,index] = sort(pos_rand); % Sort it and keep the highest num_foci values. Equates them to foci values
        flag = 1;
        numr_foci = num_foci;
        while flag % Loop until radomization lead to the same number of foci.
            rand_track(k,index(num_pixel-numr_foci+1:end)) = foci_track(1:numr_foci);
            temp_gauss = gaussf(dip_image(rand_track(k,:)),sigma);
            temp_max = dip_localminima(-temp_gauss,[],1,max_depth,max_size,1);
            % Get center of consecutive max and set them as the only maximum
            ms1 = measure(label(dip_image(temp_max),1,1,max_size),[],'center',[]);
            num_foci2 = size(ms1.Center,2);
            flag = 0; % If this set to 0, no forcing on the # of foci
            % Make sure same number of peaks...
            if (num_foci2>=num_foci)
                flag = 0;
            else
                numr_foci = numr_foci +1;
                if numr_foci >= num_pixel % could never find the right number of peak, search again...
                    pos_rand = rand(num_pixel,1);%.*double(sqrt(dna_track)); % Create a random number along track between 0 and 1 weighted by DAPI intensity value of pixel.
                    [pos_rand,index] = sort(pos_rand); % Sort it and keep the highest num_foci values. Equates them to foci values
                    numr_foci = num_foci;
                end
            end
        end
        temp_max(:)=0;
        temp_max(round(ms1.center+1))=1;
        temp_max = label(temp_max,1,0,1)>0;
        rand_track(k,:) = double(temp_max);
        rand_gauss(k,:) = double(temp_gauss);
    end
end



