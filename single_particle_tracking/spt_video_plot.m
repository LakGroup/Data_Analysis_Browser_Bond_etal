function spt_video_plot(data)
if isempty(data)~=1    
    for j = 1:length(data)
        input_data = data{j}.tracks;
        video_slider_figure(input_data)
    end
end
end

function video_slider_figure(input_data)
for i=1:length(input_data)
    time{i} = input_data{i}(:,1);
end
time = vertcat(time{:});
time = sort(time);
time = unique(time);

for i=1:length(input_data)
    data{i}(:,1:2) = input_data{i}(:,2:3);
    data{i}(:,3) = input_data{i}(:,1);
    data{i}(:,4) = i;
end
data = vertcat(data{:});
data = sortrows(data,3);
min_x = min(data(:,1));
max_x = max(data(:,1));
min_y = min(data(:,2));
max_y = max(data(:,2));

figure()
set(gcf,'name','Tracks Video','NumberTitle','off','color','w','menubar','none','toolbar','none')
slider_step=[1/(length(time)-1),0.25];
slider = uicontrol('style','slider','units','normalized','position',[0,0,0.8,0.1],'value',1,'min',1,'max',length(time),'sliderstep',slider_step,'Callback',{@sld_callback});
slider_value = 1;
scatter_plot_inside(data,time,slider_value)

play_button = uicontrol('style','pushbutton','units','normalized','position',[0.8,0,0.1,0.1],'string','play','Callback',{@play_callback});
pause_button = uicontrol('style','pushbutton','units','normalized','position',[0.8,-0.1,0.1,0.1],'string','pause','Callback',{@pause_callback});
uicontrol('style','pushbutton','units','normalized','position',[0.9,0,0.1,0.1],'string','save video','Callback',{@save_video_callback});

    function sld_callback(hobj,~,~)
        slider_value = round(get(hobj,'Value'));
        ax = gca; cla(ax);
        scatter_plot_inside(data,time,slider_value)
    end
    
    function play_callback(~,~,~)
        global pause_call
        pause_call = 0;
        slider_value = round(slider.Value);       
        play_button.Position = [0.8,-0.1,0.1,0.1];
        pause_button.Position = [0.8,0,0.1,0.1];
        for k = slider_value:length(time)
            if pause_call == 0
                slider.Value = k;
                slider_value = round(slider.Value);
                scatter_plot_inside(data,time,slider_value)
                drawnow
            end
        end
        if slider.Value == length(time)
            play_button.Position = [0.8,0,0.1,0.1];
            pause_button.Position = [0.8,-0.1,0.1,0.1];
            slider_value = 1;
            slider.Value = slider_value;
            scatter_plot_inside(data,time,slider_value)
        end     
    end

    function pause_callback(~,~,~)
        global pause_call
        pause_call = 1;
        slider_value = round(slider.Value);        
        scatter_plot_inside(data,time,slider_value)
        play_button.Position = [0.8,0,0.1,0.1];
        pause_button.Position = [0.8,-0.1,0.1,0.1];
    end

    function save_video_callback(~,~,~)
        [file,path] = uiputfile('*.avi');
        if file~=0
            v = VideoWriter([path,file]);
            v.Quality = 100;
            v.FrameRate = 30;
            open(v);
            slider_value = 1;
            for k = 1:length(time)
                slider.Value = k;
                slider_value = round(slider.Value);
                scatter_plot_inside(data,time,slider_value)
                drawnow
                frame = getframe(gcf);
                writeVideo(v,frame);
            end
            close (v)
        end
    end

    function scatter_plot_inside(data,time,slider_value)
        I = data(:,3) == time(slider_value);        
        scatter(data(I,1),data(I,2),15,'r','filled')
        xlim([min_x max_x])
        ylim([min_y max_y])
        set(gca,'box','on','BoxStyle','full','XColor','r','YColor','r','XTick',[],'YTick',[]);
        title({'time = ',num2str(round(time(slider_value),2))},'interpreter','latex','fontsize',12,'color','k')        
    end
end