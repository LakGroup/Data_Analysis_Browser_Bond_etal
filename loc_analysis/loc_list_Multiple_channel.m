function loc_list_Multiple_channel(data,scatter_size,scatter_num)

global Int
Colours = {'m','c','g','y','w',[1 0 0],'y','g','w','b',[1 0 0], [1 0.55 0]};

if length(data)<=3
    msgbox('Number of files selected should be more than 3')
else
    figure()
    set(gcf,'name','Montage Plot','NumberTitle','off','color',[0.1,0.1,0.1],'units','normalized','position',[0.15 0.2 0.7 0.6],'menubar','none','toolbar','figure');
        
    subplot = @(m,n,p) subtightplot (m, n, p, [0 0], [0 0], [0 0]);
    
    uimenu('Text','Save Image High Quality','ForegroundColor','b','CallBack',@save_image);    
    uimenu('Text','Add Scale Bar','ForegroundColor','b','CallBack',@add_scale_bar);   
    uimenu('Text','ROI Crop','ForegroundColor','b','CallBack',@ROI_Crop);
    
    subplot(1,1,1)
    data_down_sampled = cell(length(data),1);
    x = [];
    y = [];
    color = [];
    for i = 1:length(data)        
        data_down_sampled{i} = loc_list_down_sample(data{i},scatter_num);
        x = [x;data_down_sampled{i}.x_data];
        y = [y;data_down_sampled{i}.y_data];
        color = [color;i*ones(length(data_down_sampled{i}.x_data),1)];
    end 
  
    subplot(1,1,1)
    hold on
    for i = 1:length(data)
        scatter(x(color==i),y(color==i),scatter_size,Colours{i},'filled','MarkerFaceAlpha',0.2);
    end
    set(gca,'color',[0.1,0.1,0.1],'TickDir', 'out','box','on','BoxStyle','full','XTick',[],'YTick',[]);
    pbaspect([1 1 1])
    axis equal
    axis off
end

    function save_image(~,~,~)
        get_capture_from_figure()
    end

    function add_scale_bar(~,~,~)
        data_to{1}.x_data = x;
        data_to{1}.y_data = y;
        loc_list_add_scale_bar(data_to)
    end

    function ROI_Crop(~,~,~)
        [data_cropped,data_outofcrop,Int] = loc_list_roi_DualChannel(data,Int);
        close
        send_data_to_workspace(data_cropped)
        loc_list_Multiple_channel(data_outofcrop,scatter_size,scatter_num)
    end
end