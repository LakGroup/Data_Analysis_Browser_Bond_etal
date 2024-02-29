function image_plot(data)
figure()
set(gcf,'name','Image Toolbox','NumberTitle','off','color','w','units','normalized','position',[0.35 0.25 0.4 0.6],'menubar','none','toolbar','figure')

if length(data)>1
    slider_step=[1/(length(data)-1),1/(length(data)-1)];    
    slider_one = uicontrol('style','slider','units','normalized','position',[0,0,0.05,1],'value',1,'min',1,'max',length(data),'sliderstep',slider_step,'Callback',{@sld_one_callback});
end
slider_one_value=1;

if length(data{slider_one_value}.image)>1
    slider_step_two=[1/(length(data{slider_one_value}.image)-1),1/(length(data{slider_one_value}.image)-1)];
    slider_two = uicontrol('style','slider','units','normalized','position',[0.05,0,0.75,0.05],'value',1,'min',1,'max',length(data{slider_one_value}.image),'sliderstep',slider_step_two,'Callback',{@sld_two_callback});
    play_button = uicontrol('style','pushbutton','units','normalized','position',[0.8,0,0.1,0.05],'string','play','Callback',{@play_callback});
    pause_button = uicontrol('style','pushbutton','units','normalized','position',[0.8,-0.1,0.1,0.05],'string','pause','Callback',{@pause_callback});
    save_video = uicontrol('style','pushbutton','units','normalized','position',[0.9,0,0.1,0.05],'string','save video','Callback',{@save_video_callback});
else
    slider_two = uicontrol('style','slider','units','normalized','position',[0.05,-0.05,0.75,0.05],'value',1,'min',1,'max',1,'sliderstep',[0 0],'Callback',{@sld_two_callback});
    play_button = uicontrol('style','pushbutton','units','normalized','position',[0.8,-0.1,0.1,0.05],'string','play','Callback',{@play_callback});
    pause_button = uicontrol('style','pushbutton','units','normalized','position',[0.8,-0.1,0.1,0.05],'string','pause','Callback',{@pause_callback});
    save_video = uicontrol('style','pushbutton','units','normalized','position',[0.9,-0.1,0.1,0.05],'string','save video','Callback',{@save_video_callback});
end
slider_two_value=1;

image_plot_inside(data{slider_one_value}.image{slider_two_value},data{slider_one_value}.name)

    function sld_one_callback(~,~,~)
        slider_one_value = round(slider_one.Value);
        if length(data{slider_one_value}.image)>1
            slider_two_value = 1;
            slider_two.SliderStep = [1/(length(data{slider_one_value}.image)-1),1/(length(data{slider_one_value}.image)-1)];
            slider_two.Max = length(data{slider_one_value}.image);
            slider_two.Min = 1;
            slider_two.Value = 1;
            slider_two.Position = [0.05,0,0.75,0.05];            
            play_button.Position = [0.8,0,0.1,0.05];
            pause_button.Position = [0.8,-0.1,0.1,0.05];
            save_video.Position = [0.9,0,0.1,0.05];
        else
            slider_two.Position = [0.05,-0.5,0.75,0.05];
            play_button.Position = [0.8,-0.1,0.1,0.05];
            pause_button.Position = [0.8,-0.1,0.1,0.05];
            save_video.Position = [0.9,-0.1,0.1,0.05];
        end
                
        image_plot_inside(data{slider_one_value}.image{slider_two_value},data{slider_one_value}.name)
    end

    function sld_two_callback(~,~,~)
        slider_two_value = round(slider_two.Value);        
        image_plot_inside(data{slider_one_value}.image{slider_two_value},data{slider_one_value}.name)
    end

    function play_callback(~,~,~)
        global pause_call
        pause_call = 0;
        slider_two_value = round(slider_two.Value);        
        play_button.Position = [0.8,-0.1,0.1,0.05];
        pause_button.Position = [0.8,0,0.1,0.05];
        for k = slider_two_value:length(data{slider_one_value}.image)
            if pause_call == 0
                slider_two.Value = k;
                slider_two_value = round(slider_two.Value);
                image_plot_inside(data{slider_one_value}.image{slider_two_value},data{slider_one_value}.name)
                drawnow
            end
        end
        if slider_two.Value == length(data{slider_one_value}.image)
            play_button.Position = [0.8,0,0.1,0.05];
            pause_button.Position = [0.8,-0.1,0.1,0.05];
            slider_one_value = 1;
            slider_one.Value = slider_one_value;
            image_plot_inside(data{slider_one_value}.image{slider_two_value},data{slider_one_value}.name)
        end        
    end

    function pause_callback(~,~,~)
        global pause_call
        pause_call = 1;
        slider_two_value = round(slider_two.Value);        
        image_plot_inside(data{slider_one_value}.image{slider_two_value},data{slider_one_value}.name)
        play_button.Position = [0.8,0,0.1,0.05];
        pause_button.Position = [0.8,-0.1,0.1,0.05];
    end

    function save_video_callback(~,~,~)
        [file,path] = uiputfile('*.avi');
        if file~=0
            f = waitbar(0,'Please Wait...');
            v = VideoWriter([path,file]);
            v.Quality = 100;
            v.FrameRate = 10;
            open(v);            
            for k = 1:length(data{slider_one_value}.image)               
                writeVideo(v,data{slider_one_value}.image{k});
                waitbar(k/length(data{slider_one_value}),f,'Please Wait...')
            end
            close(v)
            close(f)
        end
    end

file_menu=uimenu('Text','File');
uimenu(file_menu,'Text','Send data to work space','ForegroundColor','k','CallBack',@send_data_to_workspace_callback);

    function send_data_to_workspace_callback(~,~)
        send_data_to_workspace(data)
    end

data_analysis=uimenu('Text','Data Analysis');
uimenu(data_analysis,'Text','transpose','ForegroundColor','k','CallBack',@transpose);
uimenu(data_analysis,'Text','flip left-right','ForegroundColor','k','CallBack',@flip_lr);
uimenu(data_analysis,'Text','flip up-down','ForegroundColor','k','CallBack',@flip_ud);
uimenu(data_analysis,'Text','crop by dragging','ForegroundColor','k','CallBack',@crop);
uimenu(data_analysis,'Text','crop by entering values','ForegroundColor','k','CallBack',@crop_enter_values)
uimenu(data_analysis,'Text','flip color','ForegroundColor','k','CallBack',@flip_color)

    function transpose(~,~)
        image_transpose(data)
    end

    function flip_lr(~,~)
        image_flip_lr(data)
    end

    function flip_ud(~,~)
        image_flip_ud(data)
    end

    function crop(~,~)
        image_crop(data)
    end

    function crop_enter_values(~,~)
        image_crop_enter_values(data)
    end

    function flip_color(~,~)
        image_flip_color(data)
    end

image_filtering_menu=uimenu('Text','Image Filtering');
uimenu(image_filtering_menu,'Text','average filter','ForegroundColor','k','CallBack',@average_filter)
uimenu(image_filtering_menu,'Text','disk filter','ForegroundColor','k','CallBack',@disk_filter)
uimenu(image_filtering_menu,'Text','gaussian filter','ForegroundColor','k','CallBack',@gaussian_filter)
uimenu(image_filtering_menu,'Text','laplacian filter','ForegroundColor','k','CallBack',@laplacian_filter)
uimenu(image_filtering_menu,'Text','log filter','ForegroundColor','k','CallBack',@log_filter)
uimenu(image_filtering_menu,'Text','motion filter','ForegroundColor','k','CallBack',@motion_filter)
uimenu(image_filtering_menu,'Text','prewitt filter','ForegroundColor','k','CallBack',@prewitt_filter)
uimenu(image_filtering_menu,'Text','sobel filter','ForegroundColor','k','CallBack',@sobel_filter)
uimenu(image_filtering_menu,'Text','sharpen image','ForegroundColor','k','CallBack',@sharpen)

    function average_filter(~,~)
        image_average_filter(data)
    end 

    function disk_filter(~,~)
        image_disk_filter(data)
    end 

    function gaussian_filter(~,~)
        image_gaussian_filter(data)
    end

    function laplacian_filter(~,~)
        image_laplacian_filter(data)
    end

    function log_filter(~,~)
        image_log_filter(data)
    end

    function motion_filter(~,~)
        image_motion_filter(data)
    end

    function prewitt_filter(~,~)
        image_prewitt_filter(data)
    end

    function sobel_filter(~,~)
        image_sobel_filter(data)
    end

    function sharpen(~,~)
        image_sharpen(data)
    end

    function bpass_filter(~,~)
        image_bpass_filter(data)
    end

colormap_menu = uimenu('Text','Colormap');
uimenu(colormap_menu,'Text','Gray','ForegroundColor','b','CallBack',@gray_map);
uimenu(colormap_menu,'Text','Jet','ForegroundColor','b','CallBack',@jet_map);
uimenu(colormap_menu,'Text','HSV','ForegroundColor','b','CallBack',@hsv_map);
uimenu(colormap_menu,'Text','Hot','ForegroundColor','b','CallBack',@hot_map);
uimenu(colormap_menu,'Text','Parula','ForegroundColor','b','CallBack',@parula_map);

    function gray_map(~,~,~)     
        global color_map
        color_map = colormap(gray);        
        image_plot_inside(data{slider_one_value}.image{slider_two_value},data{slider_one_value}.name)
    end

    function jet_map(~,~,~)     
        global color_map
        color_map = colormap(jet);        
        image_plot_inside(data{slider_one_value}.image{slider_two_value},data{slider_one_value}.name)
    end

    function hsv_map(~,~,~)   
        global color_map
        color_map = colormap(hsv);   
        image_plot_inside(data{slider_one_value}.image{slider_two_value},data{slider_one_value}.name)
    end

    function hot_map(~,~,~)  
        global color_map
        color_map = colormap(hot);   
        image_plot_inside(data{slider_one_value}.image{slider_two_value},data{slider_one_value}.name)
    end

    function parula_map(~,~,~)    
        global color_map
        color_map = colormap(parula);  
        image_plot_inside(data{slider_one_value}.image{slider_two_value},data{slider_one_value}.name)
    end

video_menu = uimenu('Text','Video');
uimenu(video_menu,'Text','Save as Video','ForegroundColor','b','CallBack',@video_callback);

    function video_callback(~,~,~)
        image_save_video(data)
    end
end

function image_plot_inside(data,name)
global color_map
imshow(data)
title({regexprep(name,'_',' ')},'Interpreter','latex','fontsize',14)
set(gca,'colormap',color_map,'TickDir','out','TickLength',[0.01 0.01],'FontName','TimesNewRoman','FontSize',12,'TickLabelInterpreter','latex','box','on')
axis equal
xlim([1 size(data,2)])
ylim([1 size(data,1)])
end