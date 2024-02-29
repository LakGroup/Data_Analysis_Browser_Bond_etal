function spt_layover_module_colocalization()
figure();
set(gcf,'name','Single Particle Tracks Colocalization','NumberTitle','off','color','w','units','normalized','position',[0.2 0.2 0.4 0.7],'menubar','none','toolbar','none','WindowButtonMotionFcn',@mouse_move,'WindowButtonDownFcn',@mouse_down,'windowkeypressfcn',@key_press,'windowscrollWheelFcn',@mouse_scroll)
global data listbox counts
uicontrol('style','pushbutton','units','normalized','position',[0,0.2,0.13,0.05],'string','Send Data','ForegroundColor','b','Callback',{@send_selected_data},'FontSize',12);
uicontrol('style','pushbutton','units','normalized','position',[0,0.15,0.13,0.05],'string','Export Ref Coverage','ForegroundColor','b','Callback',{@export_ref_coverage},'FontSize',12);

uicontrol('style','pushbutton','units','normalized','position',[0,0.95,0.13,0.05],'string','Select Image','ForegroundColor','b','Callback',{@select_image_callback},'FontSize',12);
uicontrol('style','pushbutton','units','normalized','position',[0,0.9,0.13,0.05],'string','Setect Tracks','ForegroundColor','b','Callback',{@select_tracks_callback},'FontSize',12);
uicontrol('style','pushbutton','units','normalized','position',[0,0.8,0.13,0.05],'string','Colocalization','ForegroundColor','b','Callback',{@colocalization_callback},'FontSize',12);

uicontrol('style','pushbutton','units','normalized','position',[0,0.65,0.13,0.05],'string','Rec Select','ForegroundColor','b','Callback',{@rectangle_select},'FontSize',12);
uicontrol('style','pushbutton','units','normalized','position',[0,0.60,0.13,0.05],'string','Rec Deselect','ForegroundColor','b','Callback',{@rectangle_deselect},'FontSize',12);

uicontrol('style','pushbutton','units','normalized','position',[0,0.50,0.13,0.05],'string','Delete Red','ForegroundColor','b','Callback',{@delete_red_tracks},'FontSize',12);
uicontrol('style','pushbutton','units','normalized','position',[0,0.45,0.13,0.05],'string','Delete Blue','ForegroundColor','b','Callback',{@delete_blue_tracks},'FontSize',12);

uicontrol('style','text','units','normalized','position',[0,0.35,0.13,0.05],'string','Image Pixel Size','ForegroundColor','b','FontSize',12);
pixel_size_eidt = uicontrol('style','edit','units','normalized','position',[0,0.3,0.13,0.05],'string','0.117','ForegroundColor','b','Callback',{@pixel_size_edit_callback},'FontSize',12);
pixel_size = str2double(pixel_size_eidt.String);

current_point = [];
tracks = [];
tracks_selected_red_idx = [];
image = [];
name = [];
tracks_plot = [];
c_lim = [0 1];
slider_step = 0.01;
counts = [];
ImageSelected = 0;
ImagePosition = [];
axis off

    function send_selected_data(~,~,~)
        if ~isempty(tracks)
            data_to_send.tracks = tracks;
            data_to_send.name = name;
            data_to_send.type = 'spt';
            data_to_send.AreaOnReference = counts;
            send_selected_data_to_workspace(data_to_send)
        end
    end

    function export_ref_coverage(~,~,~)
        if ~isempty(counts)
            counts(:,3:4) = counts(:,1:2)*pixel_size;
            CountTable = array2table(counts,'VariableNames',{'Ref_pixels_covered','Ref_pixels_not_covered','Ref_length_covered_in_micron','Ref_length_not_covered_in_micron'});
            
            [file,path] = uiputfile('*.xlsx','Please specify a name to save the reference coverage information as'); % Extract the name of the file given.
            filename = fullfile(path,file);
            if exist(filename, 'file') == 2
                delete(filename)
            end
            writetable(CountTable,filename);
        end
    end

    function send_selected_data_to_workspace(data_to_send)
        if isempty(data)==1
            data=data_to_send;
        else
            data= horzcat(data,data_to_send);
        end
        if isempty(data)==1
            listbox.String = 'NaN';
        else
            for i=1:length(data)
                names{i} = data{i}.name;
            end
            listbox.String = names;
        end
    end

    function mouse_scroll(~,event)
        scroll_value = event.VerticalScrollCount;
        if scroll_value == -1
            zoom(1.1)
        elseif scroll_value == 1
            zoom(0.9)
        end
    end

    function key_press(~,event)
        key_pressed = event.Key;  
        xx = xlim;
        yy = ylim;
        if isequal(key_pressed,'rightarrow')            
            xlim(xx+diff(xx)/5)
        elseif isequal(key_pressed,'leftarrow')            
            xlim(xx-diff(xx)/5)
        elseif isequal(key_pressed,'uparrow')            
            ylim(yy+diff(yy)/5)
        elseif isequal(key_pressed,'downarrow')            
            ylim(yy-diff(yy)/5)
        end
    end

    function pixel_size_edit_callback(~,~,~)
        pixel_size = str2double(pixel_size_eidt.String);
        plot_all()
    end

    function select_tracks_callback(~,~,~)
        listbox_value = listbox.Value;
        if isempty(data)~=1
            try
                tracks = [];
                tracks_selected_red_idx = [];                
                tracks = data(listbox_value);
                name = tracks{1}.name;
                tracks = tracks{1}.tracks;    
                plot_all()
                counts = [];
            catch
                msgbox('Wrong Track Selection')
            end
        end
    end

    function select_image_callback(~,~,~)
        listbox_value = listbox.Value;
        if isempty(data)~=1
            try                               
                image = data(listbox_value);
                image = image{1}.image{1}; 
                x_data = linspace(0,size(image,2)*pixel_size-pixel_size,size(image,2));
                y_data = linspace(0,size(image,1)*pixel_size-pixel_size,size(image,1));                
                xlim([min(x_data) max(x_data)])
                ylim([min(y_data) max(y_data)])                
                plot_all()
                ax = gca;
                c_lim = ax.CLim;
                slider_step = (c_lim(2)-c_lim(1))/100;
                low_slider.Min = c_lim(1);
                low_slider.Max = c_lim(2)-slider_step;
                low_slider.Value = c_lim(1);
                high_slider.Min = c_lim(1)+slider_step;
                high_slider.Max = c_lim(2);
                high_slider.Value = c_lim(2);   
                colormap(gray)
                ImageSelected = 1;
                ImagePosition = [min(x_data) min(y_data); min(x_data) max(y_data); max(x_data) min(y_data); max(x_data) max(y_data)];
            catch
                msgbox('Wrong Image Selection')
                ImageSelected = 0;
            end
        end
    end

    function plot_all()
        pixel_size = str2double(pixel_size_eidt.String);              
        xx = xlim;
        yy = ylim;
        ax = gca; cla(ax); 
        hold on
        if isempty(image)~=1
            [x,y] = meshgrid(linspace(0,size(image,2)*pixel_size-pixel_size,size(image,2)),linspace(0,size(image,1)*pixel_size-pixel_size,size(image,1)));
            h = pcolor(ax,x,y,image);
            h.EdgeColor = 'None';
            caxis([min(image(:)) max(image(:))])   
        end
        if isempty(tracks)~=1
            tracks_plot = cellfun(@(x) plot(x(:,2),x(:,3),'b'),tracks);
            if isempty(tracks_selected_red_idx)~=1
                for i = 1:length(tracks_selected_red_idx)
                    tracks_plot(tracks_selected_red_idx(i)).Color = 'r';
                end
            end
        end
        set(gca,'xlim',xx,'ylim',yy);
        colormap(gray)
        axis off
        title({['Number of Tracks = ',num2str(length(tracks))],['Number of Red Tracks = ',num2str(length(tracks_selected_red_idx))]},'interpreter','latex','fontsize',14)
    end

    function mouse_move(~,~)
        current_point=get(gca,'CurrentPoint');
    end

    function mouse_down(~,~)
        
        Inside = inpolygon(current_point(1,1),current_point(1,2),ImagePosition(:,1),ImagePosition(:,2));
        
        if ImageSelected == 1 && Inside
            if isequal(get(gcf,'SelectionType'),'normal')
                x = current_point(1,1);
                y = current_point(1,2);
                try
                    to_find = tracks(:,1);                
                    index = cell(length(to_find),1);               
                    for k = 1:length(to_find)
                        index{k} = k*ones(size(tracks{k,1},1),1);
                    end
                    to_find = vertcat(to_find{:});
                    index = vertcat(index{:});

                    idx = knnsearch(to_find(:,2:3),[x,y],'K',2);
                    selected = index(idx(2));

                    tracks_selected_red_idx = unique([tracks_selected_red_idx;selected]);                
                    tracks_plot(selected).Color = 'r';  
                    title({['Number of Tracks = ',num2str(length(tracks))],['Number of Red Tracks = ',num2str(length(tracks_selected_red_idx))]},'interpreter','latex','fontsize',14)
                end            
            elseif isequal(get(gcf,'SelectionType'),'alt')
                x = current_point(1,1);
                y = current_point(1,2);
                try
                    to_find = tracks(:,1);
                    index = cell(length(to_find),1);
                    for k = 1:length(to_find)
                        index{k} = k*ones(size(tracks{k,1},1),1);
                    end
                    to_find = vertcat(to_find{:});
                    index = vertcat(index{:});                

                    idx = knnsearch(to_find(:,2:3),[x,y],'K',2);
                    selected = index(idx(2));

                    tracks_selected_red_idx = setdiff(tracks_selected_red_idx,selected);
                    tracks_plot(selected).Color = 'b';
                    title({['Number of Tracks = ',num2str(length(tracks))],['Number of Red Tracks = ',num2str(length(tracks_selected_red_idx))]},'interpreter','latex','fontsize',14)
                end
            end
        end
    end

    function rectangle_select(~,~,~)
        coordinates = getrect();
        x1 = coordinates(1);
        x2 = x1+coordinates(3);
        y1 = coordinates(2);
        y2 = y1+coordinates(4);
        I1 = min(x1,x2);
        I2 = max(x1,x2);
        I3 = min(y1,y2);
        I4 = max(y1,y2);
        if I1~=I2 && I3~=I4
            try
                to_find = tracks(:,1);
                index = cell(length(to_find),1);
                for k = 1:length(to_find)
                    index{k} = k*ones(size(tracks{k,1},1),1);
                end
                to_find = vertcat(to_find{:});
                index = vertcat(index{:});                
                x_find = find(to_find(:,2)>=I1 & to_find(:,2)<=I2);
                y_find = find(to_find(:,3)>=I3 & to_find(:,3)<=I4);
                I = intersect(x_find,y_find);
                selected = index(I);
                selected = unique(selected);                
                tracks_selected_red_idx = unique([tracks_selected_red_idx;selected]);                
                for i = 1:length(selected)
                    tracks_plot(selected(i)).Color = 'r';
                end
                title({['Number of Tracks = ',num2str(length(tracks))],['Number of Red Tracks = ',num2str(length(tracks_selected_red_idx))]},'interpreter','latex','fontsize',14)
            end
        end
    end

    function rectangle_deselect(~,~,~)
        coordinates = getrect();
        x1 = coordinates(1);
        x2 = x1+coordinates(3);
        y1 = coordinates(2);
        y2 = y1+coordinates(4);
        I1 = min(x1,x2);
        I2 = max(x1,x2);
        I3 = min(y1,y2);
        I4 = max(y1,y2);
        if I1~=I2 && I3~=I4            
            try
                to_find = tracks(:,1);
                index = cell(length(to_find),1);
                for k = 1:length(to_find)
                    index{k} = k*ones(size(tracks{k,1},1),1);
                end
                to_find = vertcat(to_find{:});
                index = vertcat(index{:});
                
                
                x_find = find(to_find(:,2)>=I1 & to_find(:,2)<=I2);
                y_find = find(to_find(:,3)>=I3 & to_find(:,3)<=I4);
                I = intersect(x_find,y_find);
                selected = index(I);
                selected = unique(selected);
                
                tracks_selected_red_idx = setdiff(tracks_selected_red_idx,selected);
                for i = 1:length(selected)
                    tracks_plot(selected(i)).Color = 'b';
                end
                title({['Number of Tracks = ',num2str(length(tracks))],['Number of Red Tracks = ',num2str(length(tracks_selected_red_idx))]},'interpreter','latex','fontsize',14)
            end
        end
    end

    function delete_red_tracks(~,~,~)
        tracks(tracks_selected_red_idx) = [];
        counts(tracks_selected_red_idx,:) = [];
        tracks_selected_red_idx = [];
        plot_all()
    end

    function delete_blue_tracks(~,~,~)
        x = 1:length(tracks);
        y = setdiff(x,tracks_selected_red_idx);
        tracks(y) = [];        
        counts(y,:) = [];
        tracks_selected_red_idx = [];
        plot_all()
    end

    function colocalization_callback(~,~,~)
        input_values = inputdlg({'Colocalization Percentage:'},'',1,{'40'});
        if isempty(input_values)==1
            return
        else
            percentage_value = str2double(input_values{1});
            if ~isempty(tracks)
                [selected,to_plot,counts] = spt_layover_module_colocalization_inside(tracks,image,pixel_size,percentage_value);
                plot_all()
                selected = setdiff(1:length(tracks),selected);
                selected = selected';
                tracks_selected_red_idx = unique([tracks_selected_red_idx;selected]);
                title({['Number of Tracks = ',num2str(length(tracks))],['Number of Red Tracks = ',num2str(length(tracks_selected_red_idx))]},'interpreter','latex','fontsize',14)
                colocalization_plot(to_plot)
                for i = 1:length(selected)
                    tracks_plot(selected(i)).Color = 'r';
                end
                title({['Number of Tracks = ',num2str(length(tracks))],['Number of Red Tracks = ',num2str(length(tracks_selected_red_idx))]},'interpreter','latex','fontsize',14)
            end
        end
    end

low_slider = uicontrol('style','slider','units','normalized','position',[0,0,0.2,0.05],'value',c_lim(1),'min',c_lim(1),'max',c_lim(2)-slider_step,'sliderstep',[1/99 1/99],'Callback',{@low_in_slider_callback});
high_slider = uicontrol('style','slider','units','normalized','position',[0.2,0,0.2,0.05],'value',c_lim(2),'min',c_lim(1)+slider_step,'max',c_lim(2),'sliderstep',[1/99 1/99],'Callback',{@high_in_slider_callback});

uicontrol('style','pushbutton','units','normalized','position',[0.8,0,0.2,0.05],'string','Free Click','ForegroundColor','b','FontSize',12);

    function low_in_slider_callback(~,~,~)
        low_slider_value = low_slider.Value;        
        
        high_slider_value = high_slider.Value;
        if low_slider_value>high_slider_value
            high_slider_value = low_slider_value+slider_step;            
            high_slider.Value = high_slider_value;
        end
        caxis([low_slider_value high_slider_value])
    end

    function high_in_slider_callback(~,~,~)
        high_in_slider_value = high_slider.Value;       
        
        low_in_slider_value = low_slider.Value;
        if high_in_slider_value<low_in_slider_value
            low_in_slider_value = high_in_slider_value-slider_step;            
            low_slider.Value = low_in_slider_value;
        end
        caxis([low_in_slider_value high_in_slider_value])        
    end
end

function [localized_tracks,to_plot,counts] = spt_layover_module_colocalization_inside(tracks,image,pixel_size,percentage_value)
[tracks_image,track_intp] = spt_convert_tracks_to_image(tracks,image,pixel_size);

counts = zeros(length(tracks),2);
tracks_overlap_image = NaN(size(image,1),size(image,2));
for i = 1:length(tracks)
    for k = 1:size(track_intp{i},1)
        if image(track_intp{i}(k,2),track_intp{i}(k,1))==255            
            tracks_overlap_image(track_intp{i}(k,2),track_intp{i}(k,1)) = 255;
            counts(i,1) = counts(i,1)+1;
        else
            counts(i,2) = counts(i,2)+1;
        end        
    end
    
end

localized_tracks = [];
countCoord = zeros(size(counts,1),1);
for m = 1:size(counts,1)
    if counts(m,1)>=(sum(counts(m,:))*percentage_value/100)
        localized_tracks = [localized_tracks,m];
    end
end

tracks_colocalized = tracks(localized_tracks);
tracks_not_colocalized = tracks(setdiff(1:length(tracks),localized_tracks));

to_plot.image = image;
to_plot.tracks_image = tracks_image;
to_plot.tracks_overlap_image = tracks_overlap_image;
to_plot.tracks_colocalized = tracks_colocalized;
to_plot.tracks_not_colocalized = tracks_not_colocalized;
to_plot.pixel_size = pixel_size;
end

% function colocalization_plot(data)
% pixel_size = data.pixel_size;
% image = data.image;
% tracks_image = data.tracks_image;
% tracks_overlap_image = data.tracks_overlap_image;
% tracks_colocalized = data.tracks_colocalized;
% tracks_not_colocalized = data.tracks_not_colocalized;
% figure()
% set(gcf,'name','Tracks Colocalization Result','NumberTitle','off','color','w','units','normalized','position',[0.5 0.2 0.4 0.6])
% [x,y] = meshgrid(linspace(0,size(image,2)*pixel_size-pixel_size,size(image,2)),linspace(0,size(image,1)*pixel_size-pixel_size,size(image,1)));
% hold on
% h = pcolor(x,y,image);
% h.EdgeColor = 'none';
% h.FaceAlpha = 0.4;
% h = pcolor(x,y,tracks_image);
% h.EdgeColor = 'none';
% h.FaceAlpha = 0.5;
% h = pcolor(x,y,tracks_overlap_image);
% h.EdgeColor = 'none';
% h.FaceAlpha = 0.6;
% for i = 1:length(tracks_colocalized)
%     line(tracks_colocalized{i}(:,2),tracks_colocalized{i}(:,3),'color','b')
% end
% for i = 1:length(tracks_not_colocalized)
%     line(tracks_not_colocalized{i}(:,2),tracks_not_colocalized{i}(:,3),'color','r')
% end
% axis equal
% axis off
% end

function colocalization_plot(data)
pixel_size = data.pixel_size;

image = double(data.image);
image(image==255) = 1;
tracks_image = data.tracks_image;
tracks_image(isnan(tracks_image)) = 0;
tracks_image(tracks_image==255) = 2;

tracks_colocalized = data.tracks_colocalized;
tracks_not_colocalized = data.tracks_not_colocalized;
figure()
set(gcf,'name','Tracks Colocalization Result','NumberTitle','off','color','w','units','normalized','position',[0.5 0.2 0.4 0.6])
imagesc(image+tracks_image);
hold on;
for i = 1:length(tracks_colocalized)
    plot(tracks_colocalized{i}(:,2)/pixel_size,tracks_colocalized{i}(:,3)/pixel_size,'b')
end
for i = 1:length(tracks_not_colocalized)
    plot(tracks_not_colocalized{i}(:,2)/pixel_size,tracks_not_colocalized{i}(:,3)/pixel_size,'r')
end
set(gca,'YDir','normal')
axis equal
axis off
end