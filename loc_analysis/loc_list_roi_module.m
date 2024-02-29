function loc_list_roi_module(data,scatter_num,scatter_size,map)
figure();
set(gcf,'name','ROI Selection Module','NumberTitle','off','color',[0.1 0.1 0.1],'units','normalized','position',[0.25 0.15 0.5 0.7],'menubar','none','toolbar','none');
data = data{1};

data_down_sampled = loc_list_down_sample(data,scatter_num);

if scatter_size>10
    scatter_size = 10;
end
if scatter_size<1
    scatter_size = 1;
end

roi_coordinates = {};
plot_roi_coordinates()
uicontrol('style','pushbutton','units','normalized','position',[0,0.95,0.13,0.05],'string','Select ROI','ForegroundColor','b','Callback',@select_roi_callback,'FontSize',12);
uicontrol('style','pushbutton','units','normalized','position',[0,0.9,0.13,0.05],'string','Send ROI','ForegroundColor','b','Callback',@send_roi_callback,'FontSize',12);
 
    function select_roi_callback(~,~,~)        
        try
            roi_coordinates{end+1} = getline();         
        end           
        plot_roi_coordinates()
    end

    function plot_roi_coordinates()
        ax = gca; cla(ax);   
        hold on
        if ~isempty(roi_coordinates)
            for i = 1:length(roi_coordinates)
                plot(roi_coordinates{i}(:,1),roi_coordinates{i}(:,2),'r','linewidth',2)                
            end
        end        
        scatter(data_down_sampled.x_data,data_down_sampled.y_data,scatter_size,data_down_sampled.area,'filled','MarkerFaceAlpha',0.2);
        set(gca,'colormap',map,'color',[0.1 0.1 0.1],'TickDir', 'out','box','on','BoxStyle','full','XColor',[0.5,0.5,0.5],'YColor',[0.5,0.5,0.5],'fontsize',14,'ticklabelinterpreter','latex','ColorScale','log');
        pbaspect([1 1 1])
        axis equal
        xlim([min(data.x_data) max(data.x_data)])
        ylim([min(data.y_data) max(data.y_data)])        
    end

    function send_roi_callback(~,~,~)
        if ~isempty(roi_coordinates)
            for i = 1:length(roi_coordinates)
                data_crop{i} = loc_list_roi_inside(data,roi_coordinates{i});
            end
            loc_list_plot(data_crop)
        end
    end
end

function data_crop = loc_list_roi_inside(data,coordinates)
I = inpolygon(data.x_data,data.y_data,coordinates(:,1),coordinates(:,2));
if ~isempty(data.x_data(I))
    data_crop.x_data = data.x_data(I);
    data_crop.y_data = data.y_data(I);
    data_crop.area = data.area(I);
    data_crop.name = [data.name,'_roi'];
    data_crop.type = 'loc_list';
else
    data_crop = [];
end
end