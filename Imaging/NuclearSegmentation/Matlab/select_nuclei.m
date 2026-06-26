function [list_label] = select_nuclei(color_img)
% [list_label] = select_nuclei(color_img)
% Will assume blue image is the nuclear labeled image that will be used for
% selection. If nuclei is clicked, it will be selected and a value of 2
% will be returned for its center. Otherwise a value of 1 is left.

mask_label = color_img{3}(0:2:end,0:2:end,:); % Assumr labeled image
red = color_img{1}(0:2:end,0:2:end,:);
green = color_img{2}(0:2:end,0:2:end,:);
max_display = 100;

%mask = bdilation(blue>150,2); % Value for deconvolved image.
mask = mask_label>0;
edge = mask-berosion(mask,2);
edge_display = edge*max_display;
%mask_label = label(mask,3,400,100000); % Mask_label and edge_label have the same index per nucleus
edge_label = edge*mask_label;
ms = measure(mask_label>0,[],'Center');
list_label = ms.Center';
list_label = [list_label,ones(size(list_label,1),1)];

% Display image
fig = 99;
display_img=colorspace(newimar(1.2*stretch(red),1.2*stretch(green),edge_display),'rgb');
dipshow(fig,display_img,'lin');
set(99,'Position',[20 70 870 670]);
diptruesize('off');
dipmapping('global');
ax = findobj(fig,'Type','axes');

% Start displaying image
done = 0;
escape = 0;
while ~done
    set(fig,'WindowButtonDownFcn','set(gcbf,''WindowButtonDownFcn'',''Click!'')');
    waitfor(fig,'WindowButtonDownFcn'); % The ButtonDown callback changes the callback.
    % This way, we also detect a change in state!
    if ~ishandle(fig)
        error('You closed the window! That wasn''t the deal!')
    end
    switch get(fig,'WindowButtonDownFcn')
        case 'Click!'
            udata = get(fig,'UserData');
            switch get(fig,'SelectionType')
                case 'normal' % Selected coordinates will label nucleus with a value of 2
                    pt = dipfig_getcurpos(ax);
                    % Get nuclear label number from point
                    if isfield(udata,'curslice') % 3D image
                        temp_lab = uint16(mask_label(pt(1),pt(2),udata.curslice));
                    else
                        temp_lab = uint16(mask_label(pt(1),pt(2),0));
                    end
                    % Set center of selected nucleus to 2
                    if (temp_lab>0)
                        list_label(temp_lab,4) = min(list_label(temp_lab,4)+1,2); % Cannot go above 2
                        edge_display(find(edge_label==temp_lab)) = max_display*list_label(temp_lab,4);
                        if isfield(udata,'curslice') % 3D image
                            udata.slices{3} = edge_display;
                            udata.imagedata(:,:,2) = edge_display(:,:,udata.curslice);
                            list_label(temp_lab,3) = udata.curslice;
                        else
                            udata.imagedata(:,:,2) = edge_display;
                        end
                        set(fig,'UserData',udata);
                        dipmapping(fig,'lin');
                    end
                case 'open' % second click of double-click: end
                    done = 1;
                case 'alt' % right-click: remove point
                    if exist('temp_lab')
                        list_label(temp_lab,4) = max(list_label(temp_lab,4)-1,0); % Cannot go under 0;
                        edge_display(find(edge_label==temp_lab)) = max_display*list_label(temp_lab,4);
                        if isfield(udata,'curslice') % 3D image
                            udata.slices{3} = edge_display;
                            udata.imagedata(:,:,2) = edge_display(:,:,udata.curslice);
                        else
                            udata.imagedata(:,:,2) = edge_display;
                        end
                        set(fig,'UserData',udata);
                        dipmapping(fig,'lin');
                    end
            end
    end
end

delete(99)
