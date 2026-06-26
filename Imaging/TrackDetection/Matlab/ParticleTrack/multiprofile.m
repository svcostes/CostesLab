%DIPPROFILE   Interactive extraction of 1D function from image
%   B = DIPPROFILE(H) returns a 1D image extracted from the image in
%   the figure window with handle H, which defaults to the current
%   figure. The user is allowed to define a line over the image
%   composed of multiple straight segments. The image is interpolated
%   along this line to obtain the 1D image (using cubic interpolation).
%
%   [B,X] = DIPPROFILE(H) also returns the coordinates of the samples
%   in X. X is a N-by-2 array, where N is the size of B.
%
%   DIPPROFILE is only available for 2D figure windows.
%
%   To create the line, use the left mouse button to add points.
%   A double-click adds a last point. 'Enter' terminates the line without
%   adding a point. To remove points, use the 'Backspace' or 'Delete'
%   keys, or the right mouse button. 'Esc' aborts the operation.
%   Shift-click will add a point constrained to a horizontal or vertical
%   location with respect to the previous vertex.
%
%   Note that you need to select at least two points. If you don't, an
%   error will be generated.
%
%   It is still possible to use all the menus in the victim figure
%   window, but you won't be able to access any of the tools (like
%   zooming and testing). The regular key-binding is also disabled.
%
%   Note: If you feel the need to interrupt this function with Ctrl-C,
%   you will need to refresh the display (by re-displaying the image
%   or changing the 'Actions' state).
%
%   See also DIPSHOW, DIPGETCOORDS, DIPCROP, DIPROI.

% (C) Copyright 1999-2003               Pattern Recognition Group
%     All rights reserved               Faculty of Applied Physics
%                                       Delft University of Technology
%                                       Lorentzweg 1
%                                       2628 CJ Delft
%                                       The Netherlands
%
% Cris Luengo, December 2003
% Adapted from DIPROI

function [output,track_coords] = multiprofile(arg1)

% default width line
width_line = 3;

% Parse input
vertices = 0;
if nargin == 0
   fig = [];
else
   if ischar(arg1)
      if strcmp(arg1,'DIP_GetParamList')
         output = struct('menu','Display',...
                         'display','Extract profile along line',...
                         'inparams',struct('name',       {'handle'},...
                                           'description',{'Figure window'},...
                                           'type',       {'handle'},...
                                           'dim_check',  {0},...
                                           'range_check',{'2D'},...
                                           'required',   {0},...
                                           'default',    {[]}...
                                          ),...
                         'outparams',struct('name',{'output', 'coords'},...
                                            'description',{'Output 1D image','Output coordinates'},...
                                            'type',{'image','array'}...
                                           )...
                        );
         return
      elseif strcmp(arg1,'motion')
         dipprofMotionFcn;
         return
      else
         fig = arg1;
      end
   else
       fig = arg1;
   end
end
if isempty(fig)
    fig = get(0,'CurrentFigure');
    if isempty(fig)
        error('No figure window open to do operation on.')
    end
else
    try
        fig = getfigh(fig);
    catch
        error('Argument must be a valid figure handle.')
    end
end

output{1} = [];
track_coords{1} = [];

tag = get(fig,'Tag');
% if ~strncmp(tag,'DIP_Image_2D',12)
%    error('DIPPROFILE only works on 2D images displayed using DIPSHOW.')
% end
ax = findobj(fig,'Type','axes');
% if length(ax)~=1
%    error('DIPPROFILE only works on 2D images displayed using DIPSHOW.')
% end

% Store old settings
au = get(ax,'Units');
wbdF = get(fig,'WindowButtonDownFcn');
wbuP = get(fig,'WindowButtonUpFcn');
wbmF = get(fig,'WindowButtonMotionFcn');
bdF = get(fig,'ButtonDownFcn');
kpF = get(fig,'KeyPressFcn');
pscd = get(fig,'PointerShapeCData');
pshs = get(fig,'PointerShapeHotSpot');
ptr = get(fig,'pointer');
nt = get(fig,'NumberTitle');

% Set new settings
figure(fig);
dipfig_setpointer(fig,'cross');
set(ax,'Units','pixels');

% Do your stuff
udata = get(fig,'UserData');
udata.ax = ax;
map_mode = udata.mappingmode;
set(fig,'UserData',[]);
set(fig,'UserData',udata);
done = 0;
escape = 0;
max_depth = 50;
max_size = 20;
cnt = 1;
set(fig,'WindowButtonDownFcn','set(gcbf,''KeyPressFcn'',''Click!'')');
while ~done
    set(fig,'KeyPressFcn','set(gcbf,''KeyPressFcn'',''Key!'')');

    waitfor(fig,'KeyPressFcn'); % The ButtonDown callback changes the callback.
    % This way, we also detect a change in state!
    if ~ishandle(fig)
        error('You closed the window! That wasn''t the deal!')
    end
    fcn_called = get(fig,'KeyPressFcn');
    if or(strcmp(fcn_called,'Key!'),strcmp(fcn_called,'Click!'))
        ch = double(get(fig,'CurrentCharacter'));
        if strcmp(fcn_called,'Click!')
            ch = 13;
        end
        if ~isempty(ch)
            switch ch
                case 13 % Enter: enter a new line
                    [output{cnt},track_coords{cnt}] = dipprofile_syl(fig);
                    if length(output{cnt})>1 % Only get a profile if something was entered.
                        check_max = 0;
                        output{cnt}(:,4) = zeros(size(output{cnt}(:,2)));
                        output{cnt}(:,5) = zeros(size(output{cnt}(:,1)));
                        while (check_max>0)
                            temp_max1 = double(dip_localminima(-dip_image(output{cnt}(:,2)),[],1,max_depth,max_size,1)); % Green channel is first
                            temp_max2 = double(dip_localminima(-dip_image(output{cnt}(:,1)),[],1,max_depth,max_size,1)); % Red channel is second
                            % Get center of consecutive max and set them as
                            % the only maximum
                            ms1 = measure(label(dip_image(temp_max1),1,1,max_size),[],'center',[]);
                            temp_max1(:)=0;
                            try % if ms1 is empty will not escape
                                temp_max1(round(ms1.center+1))=1;
                            end
                            ms2 = measure(label(dip_image(temp_max2),1,1,max_size),[],'center',[]);
                            temp_max2(:)=0;
                            try % if ms1 is empty will not escape
                                temp_max2(round(ms2.center+1))=1;
                            end
%                             figure(90);
%                             set(90,'Position',[20 200 400 300]);
%                             pos1 = find(temp_max1>0);
%                             pos2 = find(temp_max2>0);
%                             subplot(3,1,1)
%                             plot(output{cnt}(:,3)./repmat(max(output{cnt}(:,3)),[length(output{cnt}(:,1)),1]),'b');
%                             hold;plot(pos1,temp_max1(pos1).*output{cnt}(pos1,3)'./max(output{cnt}(pos1,3)'),'og');
%                             plot(pos2,temp_max2(pos2).*output{cnt}(pos2,3)'./max(output{cnt}(pos2,3)'),'xr');hold;
%                             ylim([0,1.2]);
%                             subplot(3,1,2)
%                             plot(output{cnt}(:,2)./repmat(max(output{cnt}(:,2)),[length(output{cnt}(:,1)),1]),'g');
%                             hold;plot(pos1,temp_max1(pos1).*output{cnt}(pos1,2)'./max(output{cnt}(pos1,2)'),'og');hold;
%                             ylim([0,1.2]);
%                             subplot(3,1,3)
%                             plot(output{cnt}(:,1)./repmat(max(output{cnt}(:,1)),[length(output{cnt}(:,1)),1]),'r');
%                             hold;plot(pos2,temp_max2(pos2).*output{cnt}(pos2,1)'./max(output{cnt}(pos2,1)'),'xr');hold;
%                             ylim([0,1.2]);
                            % comment out verification, will be done later
                            %max_ok = questdlg('Is this OK','Confirm max','OK','Bad','OK');
                            max_ok = 'OK';
                            if (strcmp(max_ok,'OK'))
                                output{cnt}(:,4) = temp_max1';
                                output{cnt}(:,5) = temp_max2';
                                check_max = 0;
                                figure(99); % Once approved, go back to image.
                            else
                                adj_p = inputdlg({'Max I depth','Max size'},'Adjust ranges for max',1,{num2str(max_depth),num2str(max_size)});
                                if length(adj_p)>0
                                    max_depth = str2num(adj_p{1});
                                    max_size = str2num(adj_p{2});
                                else
                                    check_max = -1; % This means you are canceling the line. So, must not increment count
                                end
                            end
                        end
                        udata.selected{cnt} = line([track_coords{cnt}(:,1)],[track_coords{cnt}(:,2)],...
                            'EraseMode','xor','Color',[0.8*mod(cnt,2),0.8*mod(cnt+1,2),0.4*mod(cnt,3)],'LineWidth',width_line);
                        set(fig,'UserData',udata);
                        dipmapping(fig,map_mode);
                        if check_max ~= -1
                            cnt = cnt + 1;
                        end
                    end
                case {127,8} % Delete/Backsp: remove last line
                    if isfield(udata,'lineh')
                        delete(udata.lineh);
                        udata = rmfield(udata,'lineh');
                        cnt = cnt - 1;
                    end
                case 27 % Escape: quit
                    done = 1;
                    escape = 1;
                case {81,113} % 'q' or 'Q' - Quit
                    done = 1;
                case {78,110} % 'n' or 'N' - Go to next plane (3D)
                    udata = get(fig,'UserData');
                    temp_img = udata.slices;
                    cur_step = udata.curslice;
                    if cur_step < udata.imsize(3)-1
                        cur_step = cur_step + 1;
                    end
                    if strcmp(udata.colspace,'RGB') % In case of colorimage, update 3 channels
                        udata.imagedata(:,:,0) = temp_img{1}(:,:,cur_step);
                        udata.imagedata(:,:,1) = temp_img{2}(:,:,cur_step);
                        udata.imagedata(:,:,2) = temp_img{3}(:,:,cur_step);
                        udata.colordata = temp_img(:,:,cur_step);
                    else
                        udata.imagedata = temp_img(:,:,cur_step);
                    end
                    udata.curslice = cur_step;
                    set(fig,'UserData',udata);
                    dipmapping(fig,map_mode);
                case {80,112} % 'p' or 'P' - Go to previous plane (3D)
                    udata = get(fig,'UserData');
                    temp_img = udata.slices;
                    cur_step = udata.curslice;
                    if cur_step > 0
                        cur_step = cur_step - 1;
                    end
                    map_mode = udata.mappingmode;
                    if strcmp(udata.colspace,'RGB') % In case of colorimage, update 3 channels
                        udata.imagedata(:,:,0) = temp_img{1}(:,:,cur_step);
                        udata.imagedata(:,:,1) = temp_img{2}(:,:,cur_step);
                        udata.imagedata(:,:,2) = temp_img{3}(:,:,cur_step);
                        udata.colordata = temp_img(:,:,cur_step);
                    else
                        udata.imagedata = temp_img(:,:,cur_step);
                    end
                    udata.curslice = cur_step;
                    set(fig,'UserData',udata);
                    dipmapping(fig,map_mode);
            end
        end
    else
        % The user just changed the state. Store the new settings and revert to our own...
        wbdF = get(fig,'WindowButtonDownFcn');
        wbuP = get(fig,'WindowButtonUpFcn');
        wbmF = get(fig,'WindowButtonMotionFcn');
        bdF = get(fig,'ButtonDownFcn');
        pscd = get(fig,'PointerShapeCData');
        pshs = get(fig,'PointerShapeHotSpot');
        ptr = get(fig,'pointer');
        set(fig,'WindowButtonDownFcn','',...
            'WindowButtonUpFcn','',...
            'WindowButtonMotionFcn','dipprofile(''motion'')',...
            'ButtonDownFcn','',...
            'KeyPressFcn','set(gcbf,''WindowButtonDownFcn'',''Key!'')');
        dipfig_setpointer(fig,'cross');
        set(ax,'Units','pixels');
    end
end

% Restore old settings
if isfield(udata,'selected')
    try
        for i=1:length(udata.selected)
            delete(udata.selected{i});
        end
        udata = rmfield(udata,'selected');
    end
end
try
    delete(90);
end
try
    udata = rmfield(udata,'ax');
end
try
    set(ax,'Units',au);
end
set(fig,'WindowButtonDownFcn',wbdF,...
    'WindowButtonUpFcn',wbuP,...
    'WindowButtonMotionFcn',wbmF,...
    'ButtonDownFcn',bdF,...
    'KeyPressFcn',kpF,...
    'PointerShapeCData',pscd,...
    'PointerShapeHotSpot',pshs,...
    'pointer',ptr,...
    'NumberTitle',nt,...
    'UserData',[]);
set(fig,'UserData',udata);
dipfig_titlebar(fig,udata);

