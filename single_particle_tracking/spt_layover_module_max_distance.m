function spt_layover_module_max_distance()
figure();
set(gcf,'name','Single Particle Tracks Max Distance','NumberTitle','off','color','w','units','normalized','position',[0.2 0.2 0.4 0.7],'menubar','none','toolbar','none','WindowButtonMotionFcn',@mouse_move,'WindowButtonDownFcn',@mouse_down,'windowkeypressfcn',@key_press,'windowscrollWheelFcn',@mouse_scroll)
global data listbox
uicontrol('style','pushbutton','units','normalized','position',[0,0.95,0.13,0.05],'string','Select Image','ForegroundColor','b','Callback',{@select_image_callback},'FontSize',12);
uicontrol('style','pushbutton','units','normalized','position',[0,0.9,0.13,0.05],'string','Setect Tracks','ForegroundColor','b','Callback',{@select_tracks_callback},'FontSize',12);
uicontrol('style','pushbutton','units','normalized','position',[0,0.8,0.13,0.05],'string','Max Distance','ForegroundColor','b','Callback',{@max_distace_callback},'FontSize',12);

uicontrol('style','pushbutton','units','normalized','position',[0,0.65,0.13,0.05],'string','Rec Select','ForegroundColor','b','Callback',{@rectangle_select},'FontSize',12);
uicontrol('style','pushbutton','units','normalized','position',[0,0.60,0.13,0.05],'string','Rec Deselect','ForegroundColor','b','Callback',{@rectangle_deselect},'FontSize',12);

uicontrol('style','pushbutton','units','normalized','position',[0,0.50,0.13,0.05],'string','Delete Red','ForegroundColor','b','Callback',{@delete_red_tracks},'FontSize',12);
uicontrol('style','pushbutton','units','normalized','position',[0,0.45,0.13,0.05],'string','Delete Blue','ForegroundColor','b','Callback',{@delete_blue_tracks},'FontSize',12);

uicontrol('style','pushbutton','units','normalized','position',[0,0.35,0.13,0.05],'string','Calculate Dist','ForegroundColor','b','Callback',{@calculate_dist_callback},'FontSize',12);


uicontrol('style','text','units','normalized','position',[0,0.25,0.13,0.05],'string','Image Pixel Size','ForegroundColor','b','FontSize',12);
pixel_size_eidt = uicontrol('style','edit','units','normalized','position',[0,0.2,0.13,0.05],'string','0.117','ForegroundColor','b','Callback',{@pixel_size_edit_callback},'FontSize',12);
pixel_size = str2double(pixel_size_eidt.String);

uicontrol('style','pushbutton','units','normalized','position',[0,0.1,0.13,0.05],'string','Send Data','ForegroundColor','b','Callback',{@send_selected_data},'FontSize',12);


current_point = [];
tracks = [];
tracks_selected_red_idx = [];
line_plots = [];
image = [];
name = [];
tracks_plot = [];
c_lim = [0 1];
slider_step = 0.01;
axis off

    function send_selected_data(~,~,~)
        if ~isempty(tracks)
            data_to_send.tracks = tracks;
            data_to_send.name = name;
            data_to_send.type = 'spt';
            send_selected_data_to_workspace(data_to_send)
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
                caxis('auto')
                plot_all()
                plot_line_plots()
                ax = gca;
                c_lim = ax.CLim;
                slider_step = (c_lim(2)-c_lim(1))/100;
                low_slider.Min = c_lim(1);
                low_slider.Max = c_lim(2)-slider_step;
                low_slider.Value = c_lim(1);
                high_slider.Min = c_lim(1)+slider_step;
                high_slider.Max = c_lim(2);
                high_slider.Value = c_lim(2);
            catch
                msgbox('Wrong Image Selection')
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
            h = pcolor(x,y,image);
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
        if ~isempty(line_plots)
            to_plot = setdiff(1:length(tracks),tracks_selected_red_idx);
            cellfun(@(x) plot(x(:,1),x(:,2),'g'),line_plots(to_plot));
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
               
                plot_line_plots() 
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
        if isempty(tracks_selected_red_idx)~=1
            tracks(tracks_selected_red_idx) = [];
            if isempty(line_plots)~=1
                line_plots(tracks_selected_red_idx) = [];
            end
            tracks_selected_red_idx = [];
        end
        plot_all()
        %plot_line_plots()  
    end

    function delete_blue_tracks(~,~,~)
        if isempty(tracks)~=1
            y = setdiff(1:length(tracks),tracks_selected_red_idx);
            tracks(y) = [];
        end
        if isempty(line_plots)~=1
            line_plots(y) = [];
        end
        tracks_selected_red_idx = [];        
        plot_all()
        %plot_line_plots()  
    end

    function max_distace_callback(~,~,~)        
        if ~isempty(tracks)
            [line_plots,selected] = spt_layover_module_max_distance_inside(tracks,image,pixel_size);
            for i = 1:length(selected)
                tracks_plot(selected(i)).Color = 'r';
            end  
            tracks_selected_red_idx = unique([tracks_selected_red_idx;selected]);
            plot_line_plots()
            title({['Number of Tracks = ',num2str(length(tracks))],['Number of Red Tracks = ',num2str(length(tracks_selected_red_idx))]},'interpreter','latex','fontsize',14)
        end        
    end

    function plot_line_plots()
        if ~isempty(line_plots)
            to_plot = setdiff(1:length(tracks),tracks_selected_red_idx);
            cellfun(@(x) plot(x(:,1),x(:,2),'g'),line_plots(to_plot));
        end
    end

    function calculate_dist_callback(~,~,~)
        to_plot = setdiff(1:length(tracks),tracks_selected_red_idx);
        wanted = line_plots(to_plot);
        for i = 1:length(wanted)
            dat = wanted{i};            
            dist_table(i,1) = sqrt((dat(2,1)-dat(1,1)).^2+(dat(2,2)-dat(1,2)).^2);
            clear dat
        end 
        table_data_plot(dist_table,cellstr(string(1:length(wanted))),{'Distance'},'distance table');
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

function [line_plots,idx] = spt_layover_module_max_distance_inside(tracks,image,pixel_size)
[~,tracks_interp] = spt_convert_tracks_to_image(tracks,image,pixel_size);

line_plots = cell(length(tracks),1);
for i = 1:length(tracks)
    on_image = logical(size(tracks{i},1));
    for k = 1:size(tracks_interp{i},1)
        if image(tracks_interp{i}(k,2),tracks_interp{i}(k,1))==255
            on_image(k) = true;
        else
            on_image(k) = false;
        end
    end
    tracks_on_image = tracks_interp{i}(on_image,:);
    tracks_on_image = tracks_on_image*pixel_size;
    if ~isempty(tracks_on_image) && size(tracks_on_image,1)>1
        temp = pdist2(tracks_on_image,tracks_on_image);
        maximum = max(temp(:));
        [~,y] = find(round(temp,4)==round(maximum,4));
        line_plots{i} = tracks_on_image(y(1:2),:);        
    end
    clear on_image tracks_on_image temp maximum y
end
idx = cellfun('isempty',line_plots);
idx = find(idx ==1);
end