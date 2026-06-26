function read_track(file_name)

a = import_line_scan(file_name,',',1);

% First round, check visually that it found max. If not, let you adjust the
% parameter
nlines = length(a);
ncount = 1;
max_depth = 10;
max_size = 10;
while ncount <= nlines
    temp = a{ncount}.data(:,5);
    temp_max = double(dip_localminima(-dip_image(temp),[],1,max_depth,max_size,1));
    % Get center of consecutive max and set them as the only maximum
    ms = measure(label(dip_image(temp_max),1,1,max_size),[],'center',[]);
    temp_max(:)=0;
    temp_max(round(ms.center+1))=1;
    figure(90);
    set(90,'Position',[20 200 400 300]);
    plot(temp);hold;plot(temp_max.*temp','o');
    max_ok = questdlg('Is this OK','Confirm max','OK','Bad','OK');
    if (strcmp(max_ok,'OK'))
        a{ncount}.data(:,7) = temp_max';
        ncount = ncount + 1;
    else
        adj_p = inputdlg({'Max I depth','Max size'},'Adjust ranges for max',1,{num2str(max_depth),num2str(max_size)});
        max_depth = str2num(adj_p{1});
        max_size = str2num(adj_p{2});
    end
    delete(90);
end

% First round, check visually that it found max. If not, let you adjust the
% parameter
nlines = length(b);
ncount = 1;
max_depth = 10;
max_size = 10;
while ncount <= nlines
    temp = b{ncount}.data(:,5);
    temp_max = double(dip_localminima(-dip_image(temp),[],1,max_depth,max_size,1));
    % Get center of consecutive max and set them as the only maximum
    ms = measure(label(dip_image(temp_max),1,1,max_size),[],'center',[]);
    temp_max(:)=0;
    temp_max(round(ms.center+1))=1;
    figure(90);
    set(90,'Position',[20 200 400 300]);
    plot(temp);hold;plot(temp_max.*temp','o');
    max_ok = questdlg('Is this OK','Confirm max','OK','Bad','OK');
    if (strcmp(max_ok,'OK'))
        b{ncount}.data(:,7) = temp_max';
        ncount = ncount + 1;
    else
        adj_p = inputdlg({'Max I depth','Max size'},'Adjust ranges for max',1,{num2str(max_depth),num2str(max_size)});
        max_depth = str2num(adj_p{1});
        max_size = str2num(adj_p{2});
    end
    delete(90);
end

% First round, check visually that it found max. If not, let you adjust the
% parameter. C is 53BP1, was analyzed on one channel only.
nlines = length(c);
ncount = 1;
max_depth = 10;
max_size = 10;
while ncount <= nlines
    temp = c{ncount}.data(:,4);
    temp_max = double(dip_localminima(-dip_image(temp),[],1,max_depth,max_size,1));
    % Get center of consecutive max and set them as the only maximum
    ms = measure(label(dip_image(temp_max),1,1,max_size),[],'center',[]);
    temp_max(:)=0;
    temp_max(round(ms.center+1))=1;
    figure(90);
    set(90,'Position',[20 200 400 300]);
    plot(temp);hold;plot(temp_max.*temp','o');
    max_ok = questdlg('Is this OK','Confirm max','OK','Bad','OK');
    if (strcmp(max_ok,'OK'))
        c{ncount}.data(:,7) = temp_max';
        ncount = ncount + 1;
    else
        adj_p = inputdlg({'Max I depth','Max size'},'Adjust ranges for max',1,{num2str(max_depth),num2str(max_size)});
        max_depth = str2num(adj_p{1});
        max_size = str2num(adj_p{2});
    end
    delete(90);
end

% First round, check visually that it found max. If not, let you adjust the
% parameter
nlines = length(d);
ncount = 1;
max_depth = 10;
max_size = 10;
while ncount <= nlines
    temp = d{ncount}.data(:,5);
    temp_max = double(dip_localminima(-dip_image(temp),[],1,max_depth,max_size,1));
    % Get center of consecutive max and set them as the only maximum
    ms = measure(label(dip_image(temp_max),1,1,max_size),[],'center',[]);
    temp_max(:)=0;
    temp_max(round(ms.center+1))=1;
    figure(90);
    set(90,'Position',[20 200 400 300]);
    plot(temp);hold;plot(temp_max.*temp','o');
    max_ok = questdlg('Is this OK','Confirm max','OK','Bad','OK');
    if (strcmp(max_ok,'OK'))
        d{ncount}.data(:,7) = temp_max';
        ncount = ncount + 1;
    else
        adj_p = inputdlg({'Max I depth','Max size'},'Adjust ranges for max',1,{num2str(max_depth),num2str(max_size)});
        max_depth = str2num(adj_p{1});
        max_size = str2num(adj_p{2});
    end
    delete(90);
end

% First round, check visually that it found max. If not, let you adjust the
% parameter. This group was analyzed on one channel only. 16 bit. A bit
% noisy. Need to add a Gaussian filter ****
nlines = length(e);
ncount = 1;
max_depth = 10;
max_size = 10;
while ncount <= nlines
    temp = e{ncount}.data(:,4);
    temp_max = double(dip_localminima(gaussf(-dip_image(temp)),[],1,max_depth,max_size,1));
%    temp_max = double(dip_localminima(gaussf(-dip_image(temp)),1,max_depth,max_size));
    % Get center of consecutive max and set them as the only maximum
    ms = measure(label(dip_image(temp_max),1,1,max_size),[],'center',[]);
    temp_max(:)=0;
    temp_max(round(ms.center+1))=1;
    figure(90);
    set(90,'Position',[20 200 400 300]);
    plot(temp);hold;plot(temp_max.*temp','o');
    max_ok = questdlg('Is this OK','Confirm max','OK','Bad','OK');
    if (strcmp(max_ok,'OK'))
        e{ncount}.data(:,7) = temp_max';
        ncount = ncount + 1;
    else
        adj_p = inputdlg({'Max I depth','Max size'},'Adjust ranges for max',1,{num2str(max_depth),num2str(max_size)});
        max_depth = str2num(adj_p{1});
        max_size = str2num(adj_p{2});
    end
    delete(90);
end

% *************************************************************************
% *************************************************************************
min_size = 2; % This value is used to compute the random distance. Based on data, a sigma of 2 is appropriate to represent foci from X-ray (sc041305)
iteration = 100;

% Compute corresponding distance in um
scale = 6.45/40/1.6; % Meta Hamamatsu camera, 40X dry, 1.6X optivar
nlines = length(a)
for i=1:nlines
    x = a{i}.data(:,1);
    y = a{i}.data(:,2);
    a{i}.data(:,9) = 0; % Reset in case it was already ran
    temp_max = a{i}.data(:,7);
    max_index = find(temp_max==1);
    for k=1:length(max_index)-1
        j = max_index(k);
        jj = max_index(k+1);
        dist = sqrt((x(j)-x(jj))^2 + (y(j)-y(jj))^2)*scale;
        a{i}.data(j,8) = dist;
    end
    temp_max = randomize_track2(a{i}.data(:,7).*a{i}.data(:,5),'iteration',iteration,'size',min_size); % This will generate random foci position
    for iter =1:iteration
        max_index = find(temp_max(iter,:)==1);
        a{i}.data(:,8+iter)=0; % Clear in case it was ran before
        for k=1:length(max_index)-1
            j = max_index(k);
            jj = max_index(k+1);
            dist = sqrt((x(j)-x(jj))^2 + (y(j)-y(jj))^2)*scale;
            a{i}.data(j,8+iter) = dist;
        end
    end
end

scale = 6.45/40/1.6; % Meta Hamamatsu camera, 40X dry, 1.6X optivar
nlines = length(b);
for i=1:nlines
    x = b{i}.data(:,1);
    y = b{i}.data(:,2);
    b{i}.data(:,9) = 0; % Reset in case it was already ran
    temp_max = b{i}.data(:,7);
    max_index = find(temp_max==1);
    for k=1:length(max_index)-1
        j = max_index(k);
        jj = max_index(k+1);
        dist = sqrt((x(j)-x(jj))^2 + (y(j)-y(jj))^2)*scale;
        b{i}.data(j,8) = dist;
    end
    temp_max = randomize_track2(b{i}.data(:,7).*b{i}.data(:,5),'iteration',iteration,'size',min_size); % This will generate random foci position
    for iter =1:iteration
        max_index = find(temp_max(iter,:)==1);
        b{i}.data(:,8+iter)=0; % Clear in case it was ran before
        for k=1:length(max_index)-1
            j = max_index(k);
            jj = max_index(k+1);
            dist = sqrt((x(j)-x(jj))^2 + (y(j)-y(jj))^2)*scale;
            b{i}.data(j,8+iter) = dist;
        end
    end
end

scale = 1; % Since done on a gray calibrated image, distances are already in um
nlines = length(c);
for i=1:nlines
    x = c{i}.data(:,1);
    y = c{i}.data(:,2);
    c{i}.data(:,9) = 0; % Reset in case it was already ran
    temp_max = c{i}.data(:,7);
    max_index = find(temp_max==1);
    for k=1:length(max_index)-1
        j = max_index(k);
        jj = max_index(k+1);
        dist = sqrt((x(j)-x(jj))^2 + (y(j)-y(jj))^2)*scale;
        c{i}.data(j,8) = dist;
    end
    temp_max = randomize_track2(c{i}.data(:,7).*c{i}.data(:,4),'iteration',iteration,'size',min_size); % This will generate random foci position
    for iter =1:iteration
        max_index = find(temp_max(iter,:)==1);
        c{i}.data(:,8+iter)=0; % Clear in case it was ran before
        for k=1:length(max_index)-1
            j = max_index(k);
            jj = max_index(k+1);
            dist = sqrt((x(j)-x(jj))^2 + (y(j)-y(jj))^2)*scale;
            c{i}.data(j,8+iter) = dist;
        end
    end
end

scale = 6.45/40/1.6; % Meta Hamamatsu camera, 40X dry, 1.6X optivar
nlines = length(d);
for i=1:nlines
    x = d{i}.data(:,1);
    y = d{i}.data(:,2);
    d{i}.data(:,9) = 0; % Reset in case it was already ran
    temp_max = d{i}.data(:,7);
    max_index = find(temp_max==1);
    for k=1:length(max_index)-1
        j = max_index(k);
        jj = max_index(k+1);
        dist = sqrt((x(j)-x(jj))^2 + (y(j)-y(jj))^2)*scale;
        d{i}.data(j,8) = dist;
    end
    temp_max = randomize_track2(d{i}.data(:,7).*d{i}.data(:,5),'iteration',iteration,'size',min_size); % This will generate random foci position
    for iter =1:iteration
        max_index = find(temp_max(iter,:)==1);
        d{i}.data(:,8+iter)=0; % Clear in case it was ran before
        for k=1:length(max_index)-1
            j = max_index(k);
            jj = max_index(k+1);
            dist = sqrt((x(j)-x(jj))^2 + (y(j)-y(jj))^2)*scale;
            d{i}.data(j,8+iter) = dist;
        end
    end
end

scale = 1; % Since done on a gray calibrated image, distances are already in um
nlines = length(e);
for i=1:nlines
    x = e{i}.data(:,1);
    y = e{i}.data(:,2);
    e{i}.data(:,9) = 0; % Reset in case it was already ran
    temp_max = e{i}.data(:,7);
    max_index = find(temp_max==1);
    for k=1:length(max_index)-1
        j = max_index(k);
        jj = max_index(k+1);
        dist = sqrt((x(j)-x(jj))^2 + (y(j)-y(jj))^2)*scale;
        e{i}.data(j,8) = dist;
    end
    temp_max = randomize_track2(e{i}.data(:,7).*e{i}.data(:,4),'iteration',iteration,'size',min_size); % This will generate random foci position
    for iter =1:iteration
        max_index = find(temp_max(iter,:)==1);
        e{i}.data(:,8+iter)=0; % Clear in case it was ran before
        for k=1:length(max_index)-1
            j = max_index(k);
            jj = max_index(k+1);
            dist = sqrt((x(j)-x(jj))^2 + (y(j)-y(jj))^2)*scale;
            e{i}.data(j,8+iter) = dist;
        end
    end
end

% Finalize analysis. Generate excel files with distance histogram and angle
% histogram
img_num_a = [28 56 75 103 139 171]; % Index number that delimits new group in image itself
time_a = [10 30 60 120 180 300];
ncount = 1; % index for line scan number
i = 1; % index for group
distance_a{i} = [];
distance_ar{i} = [];
angle_a{i} = [];
for ncount = 1:length(a)
    if (str2num(a{ncount}.textdata(end-2:end))>=img_num_a(i))
        img_count_a(i) = ncount; % img_count_a keeps track of the index number in actuall track corresponding to time
        i = i + 1;
        distance_a{i} = [];
        distance_ar{i} = [];
        angle_a{i} = [];
    end
    x1 = a{ncount}.data(1,1);
    x2 = a{ncount}.data(end,1);
    y1 = a{ncount}.data(1,2);
    y2 = a{ncount}.data(end,2);
    dist = sqrt((x1-x2)^2+(y1-y2)^2);
    angle_a{i} = [angle_a{i},acos(abs(y1-y2)/dist)];
    dist = a{ncount}.data(:,8);
    distance_a{i} = [distance_a{i},(dist(dist>0))'];
    for iter = 1:iteration
        dist = a{ncount}.data(:,8+iter);
        distance_ar{i} = [distance_ar{i},(dist(dist>0))'];
    end
end
img_count_a(i) = ncount+1;

img_num_b = [25 58 89 120 153 186]; % Index number that delimits new group in image itself
time_b = [300 180 120 60 30 10];
ncount = 1; % index for line scan number
i = 1; % index for group
distance_b{i} = [];
distance_br{i} = [];
angle_b{i} = [];
for ncount = 1:length(b)
    if (str2num(b{ncount}.textdata(end-2:end))>=img_num_b(i))
        img_count_b(i) = ncount; % img_count keeps track of the index number in actuall track corresponding to time
        i = i + 1;
        distance_b{i} = [];
        distance_br{i} = [];
        angle_b{i} = [];
    end
    x1 = b{ncount}.data(1,1);
    x2 = b{ncount}.data(end,1);
    y1 = b{ncount}.data(1,2);
    y2 = b{ncount}.data(end,2);
    dist = sqrt((x1-x2)^2+(y1-y2)^2);
    angle_b{i} = [angle_b{i},acos(abs(y1-y2)/dist)];
    dist = b{ncount}.data(:,8);
    distance_b{i} = [distance_b{i},(dist(dist>0))'];
    for iter = 1:iteration
        dist = b{ncount}.data(:,8+iter);
        distance_br{i} = [distance_br{i},(dist(dist>0))'];
    end
end
img_count_b(i) = ncount+1; % img_count keeps track of the index number in actuall track corresponding to time

img_num_c = [11 16 26 36 46 56 65]; % Index number that delimits new group in image itself
time_c = [10 0 30 60 120 180 300];
ncount = 1; % index for line scan number
i = 1; % index for group
distance_c{i} = [];
distance_cr{i} = [];
angle_c{i} = [];
for ncount = 1:length(c)
    if (str2num(c{ncount}.textdata(end-2:end))>=img_num_c(i))
        img_count_c(i) = ncount; % img_count keeps track of the index number in actuall track corresponding to time
        i = i + 1;
        distance_c{i} = [];
        distance_cr{i} = [];
        angle_c{i} = [];
    end
    x1 = c{ncount}.data(1,1);
    x2 = c{ncount}.data(end,1);
    y1 = c{ncount}.data(1,2);
    y2 = c{ncount}.data(end,2);
    dist = sqrt((x1-x2)^2+(y1-y2)^2);
    angle_c{i} = [angle_c{i},acos(abs(y1-y2)/dist)];
    dist = c{ncount}.data(:,8);
    distance_c{i} = [distance_c{i},(dist(dist>0))'];
    for iter = 1:iteration
        dist = c{ncount}.data(:,8+iter);
        distance_cr{i} = [distance_cr{i},(dist(dist>0))'];
    end
end
img_count_c(i) = ncount+1; % img_count keeps track of the index number in actuall track corresponding to time

img_num_d = [52 98 142 195 244 287]; % Index number that delimits new group in image itself
time_d = [300 180 120 60 30 10];
ncount = 1; % index for line scan number
i = 1; % index for group
distance_d{i} = [];
distance_dr{i} = [];
angle_d{i} = [];
for ncount = 1:length(d)
    if (str2num(d{ncount}.textdata(end-2:end))>=img_num_d(i))
        img_count_d(i) = ncount; % img_count keeps track of the index number in actuall track corresponding to time
        i = i + 1;
        distance_d{i} = [];
        distance_dr{i} = [];
        angle_d{i} = [];
    end
    x1 = d{ncount}.data(1,1);
    x2 = d{ncount}.data(end,1);
    y1 = d{ncount}.data(1,2);
    y2 = d{ncount}.data(end,2);
    dist = sqrt((x1-x2)^2+(y1-y2)^2);
    angle_d{i} = [angle_d{i},acos(abs(y1-y2)/dist)];
    dist = d{ncount}.data(:,8);
    distance_d{i} = [distance_d{i},(dist(dist>0))'];
    for iter = 1:iteration
        dist = d{ncount}.data(:,8+iter);
        distance_dr{i} = [distance_dr{i},(dist(dist>0))'];
    end
img_count_d(i) = ncount+1; % img_count keeps track of the index number in actuall track corresponding to time

img_num_e = [8 15 22 29 36 43]; % Index number that delimits new group in image itself
time_e = [10 30 60 120 180 300];
ncount = 1; % index for line scan number
i = 1; % index for group
distance_e{i} = [];
distance_er{i} = [];
angle_e{i} = [];
for ncount = 1:length(e)
    if (str2num(e{ncount}.textdata(end-2:end))>=img_num_e(i))
        img_count_e(i) = ncount; % img_count keeps track of the index number in actuall track corresponding to time
        i = i + 1;
        distance_e{i} = [];
        distance_er{i} = [];
        angle_e{i} = [];
    end
    x1 = e{ncount}.data(1,1);
    x2 = e{ncount}.data(end,1);
    y1 = e{ncount}.data(1,2);
    y2 = e{ncount}.data(end,2);
    dist = sqrt((x1-x2)^2+(y1-y2)^2);
    angle_e{i} = [angle_e{i},acos(abs(y1-y2)/dist)];
    dist = e{ncount}.data(:,8);
    distance_e{i} = [distance_e{i},(dist(dist>0))'];
    for iter = 1:iteration
        dist = e{ncount}.data(:,8+iter);
        distance_er{i} = [distance_er{i},(dist(dist>0))'];
    end
end
img_count_e(i) = ncount+1; % img_count keeps track of the index number in actuall track corresponding to time


% Compare old and new data
load('track_br091604br1_wkspace.mat');
time_old = st(1).Time;
bin_dis = 0:0.4:10;
fun = inline('100*b(1)^2*x.*exp(-b(1).*x)','b','x')
for i=1:6
    h_a{i} = hist(distance_a{i},bin_dis);
    h_a{i} = h_a{i}*100/sum(h_a{i});
    beta_a(i) = nlinfit(bin_dis,h_a{i},fun,0.4); % Fit using Ponomarev modified Poisson fit
    h_b{i} = hist(distance_b{i},bin_dis);
    h_b{i} = h_b{i}*100/sum(h_b{i});
    beta_b(i) = nlinfit(bin_dis,h_b{i},fun,0.4); % Fit using Ponomarev modified Poisson fit
    h_c{i} = hist(distance_c{i},bin_dis);
    h_c{i} = h_c{i}*100/sum(h_c{i});
    beta_c(i) = nlinfit(bin_dis,h_c{i},fun,0.4); % Fit using Ponomarev modified Poisson fit
    h_d{i} = hist(distance_d{i},bin_dis);
    h_d{i} = h_d{i}*100/sum(h_d{i});
    beta_d(i) = nlinfit(bin_dis,h_d{i},fun,0.4); % Fit using Ponomarev modified Poisson fit
    h_e{i} = hist(distance_e{i},bin_dis);
    h_e{i} = h_e{i}*100/sum(h_e{i});
    beta_e(i) = nlinfit(bin_dis,h_e{i},fun,0.4); % Fit using Ponomarev modified Poisson fit
    h_old{i} = hist(st(i).dist_track*0.155,bin_dis);
    h_old{i} = h_old{i}*100/sum(h_old{i});
    beta_old(i) = nlinfit(bin_dis,h_old{i},fun,0.4); % Fit using Ponomarev modified Poisson fit
end
    h_c{7} = hist(distance_c{7},bin_dis);
    h_c{7} = h_c{7}*100/sum(h_c{7});
    beta_c(7) = nlinfit(bin_dis,h_c{7},fun,0.4); % Fit using Ponomarev modified Poisson fit

for i=1:6
    h_ar{i} = hist(distance_ar{i},bin_dis);
    h_ar{i} = h_ar{i}*100/sum(h_ar{i});
    h_br{i} = hist(distance_br{i},bin_dis);
    h_br{i} = h_br{i}*100/sum(h_br{i});
    h_cr{i} = hist(distance_cr{i},bin_dis);
    h_cr{i} = h_cr{i}*100/sum(h_cr{i});
    h_dr{i} = hist(distance_dr{i},bin_dis);
    h_dr{i} = h_dr{i}*100/sum(h_dr{i});
    h_er{i} = hist(distance_er{i},bin_dis);
    h_er{i} = h_er{i}*100/sum(h_er{i});
end
    h_cr{7} = hist(distance_cr{7},bin_dis);
    h_cr{7} = h_cr{7}*100/sum(h_cr{7});


title_str = {'\gammaH2AX1','\gammaH2AX2','53 BP1','ATM1','ATM2'};

% compare old h2ax data from Bjorn and new ones.
subplot(3,1,1)
plot(bin_dis,h_a{1},'r');hold;plot(bin_dis,h_old{2});
legend(int2str(time_a(1)),int2str(time_old(2)));

subplot(3,1,2)
plot(bin_dis,h_a{4},'r');hold;plot(bin_dis,h_old{3});
legend(int2str(time_a(4)),int2str(time_old(3)));

subplot(3,1,3)
plot(bin_dis,h_a{6},'r');hold;plot(bin_dis,h_old{4});
legend(int2str(time_a(6)),int2str(time_old(4)));

% Compare different stain response
a_index = 1:6;
b_index = 6:-1:1;
c_index = [1,3:7];
d_index = b_index;
e_index = a_index;

for i=1:6
    mean_dist_a(i) = mean(distance_a{a_index(i)});
    mean_dist_b(i) = mean(distance_b{b_index(i)});
    mean_dist_c(i) = mean(distance_c{c_index(i)});
    mean_dist_d(i) = mean(distance_d{d_index(i)});
    mean_dist_e(i) = mean(distance_e{e_index(i)});
    mean_dist_old(i) = mean(st(i).dist_track*0.155); % Old H2AX data
end

for i=1:6 % Loop on time
    subplot(6,5,1+(i-1)*5)
    bar(bin_dis,h_a{a_index(i)},'r');
    hold;plot(mean_dist_a(i),0:40,'--k');
    plot(bin_dis,h_ar{a_index(i)},'b');
    plot(bin_dis,fun(beta_a(a_index(i)),bin_dis),'--k');
    xlim([0,8]);ylim([0,40]);
    text(3,30,['N=',num2str(length(distance_a{a_index(i)}))],'FontSize',10);
    text(3,20,['\lambda=',num2str(beta_a(a_index(i)),3)],'FontSize',10);
    ylabel(sprintf('%d mn',time_a(i)));
    if i==1 title(title_str(1));end
    subplot(6,5,2+(i-1)*5)
    bar(bin_dis,h_b{b_index(i)},'r');
    hold;plot(mean_dist_b(i),0:40,'--k');
    plot(bin_dis,h_br{b_index(i)},'b');
    plot(bin_dis,fun(beta_b(b_index(i)),bin_dis),'--k');
    xlim([0,8]);ylim([0,40]);
    text(3,30,['N=',num2str(length(distance_b{b_index(i)}))],'FontSize',10);
    text(3,20,['\lambda=',num2str(beta_b(b_index(i)),3)],'FontSize',10);
    if i==1 title(title_str(2));end
    subplot(6,5,3+(i-1)*5)
    bar(bin_dis,h_c{c_index(i)},'g');
    hold;plot(mean_dist_c(i),0:40,'--k');
    plot(bin_dis,h_cr{c_index(i)},'r');
    plot(bin_dis,fun(beta_c(c_index(i)),bin_dis),'--k');
    xlim([0,8]);ylim([0,40]);
    text(3,30,['N=',num2str(length(distance_c{c_index(i)}))],'FontSize',10);
    text(3,20,['\lambda=',num2str(beta_c(c_index(i)),3)],'FontSize',10);
    if i==1 title(title_str(3));end
    subplot(6,5,4+(i-1)*5)
    bar(bin_dis,h_d{d_index(i)},'b');
    hold;plot(mean_dist_d(i),0:40,'--k');
    plot(bin_dis,h_dr{d_index(i)},'g');
    plot(bin_dis,fun(beta_d(d_index(i)),bin_dis),'--k');
    xlim([0,8]);ylim([0,40]);
    text(3,30,['N=',num2str(length(distance_d{d_index(i)}))],'FontSize',10);
    text(3,20,['\lambda=',num2str(beta_d(d_index(i)),3)],'FontSize',10);
    if i==1 title(title_str(4));end
    subplot(6,5,5+(i-1)*5)
    bar(bin_dis,h_e{e_index(i)},'b');
    hold;plot(mean_dist_e(i),0:40,'--k');
    plot(bin_dis,h_er{e_index(i)},'g');
    plot(bin_dis,fun(beta_e(e_index(i)),bin_dis),'--k');
    xlim([0,8]);ylim([0,40]);
    text(3,30,['N=',num2str(length(distance_e{e_index(i)}))],'FontSize',10);
    text(3,20,['\lambda=',num2str(beta_e(e_index(i)),3)],'FontSize',10);
    if i==1 title(title_str(5));end
end

h2ax = [mean_dist_a;mean_dist_b];
bp1 = mean_dist_c;
atm = [mean_dist_d;mean_dist_e];

figure;
errorbar(time_a,mean(h2ax),std(h2ax),'.-r')
hold
plot(st(1).Time(2:4),mean_dist_old(2:4),'--r');
plot(time_a,mean_dist_c,'--g')
errorbar(time_a,mean(atm),std(atm),'x-b')
legend('gH2AX/NSRL5','gH2AX/NSRL4','53BP1','ATM');

% Save results into excel file
header_str = {'Track #','Time postIR (mn)','X','Y','I','Max','Foci Dist (um)','Random Dist (um)'};
header_str2 = {'Track #','Time postIR (mn)','X (um)','Y (um)','I','Max','Foci Dist (um)','Random Dist (um)'};

clear temp_xl
j_time = 1;
for i=1:length(a)
    temp_data = a{i}.data;
    if i >= img_count_a(j_time)
        j_time = j_time + 1;
    end
    temp_xl{i} = [ones(size(temp_data,1),1)*i,ones(size(temp_data,1),1)*time_a(j_time),temp_data(:,[1:2,5,7:end])];
end
temp_ar = cell2mat(temp_xl');
range = sprintf('A2:H%d',size(temp_ar,1)+1);
xlswrite('sc041605_track_data',header_str,'H2AX_1','A1:H1');
xlswrite('sc041605_track_data',temp_ar,'H2AX_1',range);

clear temp_xl
j_time = 1;
for i=1:length(b)
    temp_data = b{i}.data;
    if i >= img_count_b(j_time)
        j_time = j_time + 1;
    end
    temp_xl{i} = [ones(size(temp_data,1),1)*i,ones(size(temp_data,1),1)*time_b(j_time),temp_data(:,[1:2,5,7:end])];
end
temp_ar = cell2mat(temp_xl');
range = sprintf('A2:H%d',size(temp_ar,1)+1);
xlswrite('sc041605_track_data',header_str,'H2AX_2','A1:H1');
xlswrite('sc041605_track_data',temp_ar,'H2AX_2',range);

clear temp_xl
j_time = 1;
for i=1:length(c)
    temp_data = c{i}.data;
    if i >= img_count_c(j_time)
        j_time = j_time + 1;
    end
    temp_xl{i} = [ones(size(temp_data,1),1)*i,ones(size(temp_data,1),1)*time_c(j_time),temp_data(:,[1:2,4,7:end])];
end
temp_ar = cell2mat(temp_xl');
range = sprintf('A2:H%d',size(temp_ar,1)+1);
xlswrite('sc041605_track_data',header_str2,'53BP1','A1:H1');
xlswrite('sc041605_track_data',temp_ar,'53BP1',range);

clear temp_xl
j_time = 1;
for i=1:length(d)
    temp_data = d{i}.data;
    if i >= img_count_d(j_time)
        j_time = j_time + 1;
    end
    temp_xl{i} = [ones(size(temp_data,1),1)*i,ones(size(temp_data,1),1)*time_d(j_time),temp_data(:,[1:2,5,7:end])];
end
temp_ar = cell2mat(temp_xl');
range = sprintf('A2:H%d',size(temp_ar,1)+1);
xlswrite('sc041605_track_data',header_str,'ATM_1','A1:H1');
xlswrite('sc041605_track_data',temp_ar,'ATM_1',range);

clear temp_xl
j_time = 1;
for i=1:length(e)
    temp_data = e{i}.data;
    if i >= img_count_e(j_time)
        j_time = j_time + 1;
    end
    temp_xl{i} = [ones(size(temp_data,1),1)*i,ones(size(temp_data,1),1)*time_e(j_time),temp_data(:,[1:2,4,7:end])];
end
temp_ar = cell2mat(temp_xl');
range = sprintf('A2:H%d',size(temp_ar,1)+1);
xlswrite('sc041605_track_data',header_str2,'ATM_2','A1:H1');
xlswrite('sc041605_track_data',temp_ar,'ATM_2',range);

