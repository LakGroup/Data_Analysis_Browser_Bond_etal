function loc_list_two_channel_b(data,scatter_num)

global Int

answer = inputdlg({'Scatter 1st channel: ','Scatter 2nd channel: ','Color 1: ','Color 2: '},'Input',[1 50],{'5','5','m','y'});
scatter_size_b(1) = str2double(answer{1});
scatter_size_b(2) = str2double(answer{2});
Color1 = answer{3};
Color2 = answer{4};

figure('Units','Pixels','Position',[300 200 1350 650])
set(gcf,'name','Montage Plot','NumberTitle','off','color',[0,0,0],'menubar','none','toolbar','figure');

subplot = @(m,n,p) subtightplot (m, n, p, [0 0], [0 0], [0 0]);

uimenu('Text','Save Image High Quality','ForegroundColor','b','CallBack',@save_image);
uimenu('Text','Add Scale Bar','ForegroundColor','b','CallBack',@add_scale_bar);
uimenu('Text','ROI Crop','ForegroundColor','b','CallBack',@ROI_Crop);
uimenu('Text','Send Data to Workspace','ForegroundColor','b','CallBack',@send_Data);

Color = {Color1,Color2};

data_down_sampled = cell(length(data),1);
for i = 1:length(data)
    data_down_sampled{i} = loc_list_down_sample(data{i},scatter_num);

    x = [data_down_sampled{i}.x_data];
    y = [data_down_sampled{i}.y_data];

    subplot(1,1,1)
    hold on
    %     scatter(x(color==1),y(color==1),scatter_size1,'m','filled','MarkerFaceAlpha',0.2);
    %     scatter(x(color==2),y(color==2),scatter_size2,'y','filled','MarkerFaceAlpha',0.2);
    scatter(x,y,scatter_size_b(i),Color{i},'filled');
    set(gca,'color',[0,0,0],'TickDir', 'out','box','on','BoxStyle','full','XTick',[],'YTick',[]);
    pbaspect([1 1 1])
    axis equal
    axis off
end
Axis = axis;
set(gcf,'paperunits','inches','paperposition',[0 0 [(Axis(2)-Axis(1))*117 (Axis(4)-Axis(3))*117]/300]);

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
        loc_list_two_channel(data_outofcrop,scatter_size,scatter_num)
    end

    function send_Data(~,~,~)
        send_data_to_workspace(data)
    end

end