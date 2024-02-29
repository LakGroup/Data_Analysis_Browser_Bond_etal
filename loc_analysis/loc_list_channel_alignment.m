function loc_list_channel_alignment(data,scatter_num)

global Int

hex = ['#1f77b4';'#aec7e8';'#ff7f0e';'#ffbb78';'#2ca02c';'#98df8a';'#d62728';'#ff9896';'#9467bd';'#c5b0d5';'#8c564b';'#c49c94';'#e377c2';'#f7b6d2';'#7f7f7f';'#c7c7c7';'#bcbd22';'#dbdb8d';'#17becf';'#9edae5'];
raw = sscanf(hex.','#%2x%2x%2x',[3,Inf]).';
num = size(raw,1);
Colors = raw(1+mod(0:numel(data)-1,num),:) / 255;

figure('Units','Pixels','Position',[300 200 1350 650])
set(gcf,'name','Montage Plot','NumberTitle','off','color',[0,0,0],'menubar','none','toolbar','figure');

subplot = @(m,n,p) subtightplot (m, n, p, [0 0], [0 0.025], [0 0]);

uimenu('Text','Save Image High Quality','ForegroundColor','b','CallBack',@save_image);
uimenu('Text','Add Scale Bar','ForegroundColor','b','CallBack',@add_scale_bar);
uimenu('Text','ROI Crop','ForegroundColor','b','CallBack',@ROI_Crop);
uimenu('Text','Send Data to Workspace','ForegroundColor','b','CallBack',@send_Data);
uimenu('Text','Do channel alignment','ForegroundColor','b','CallBack',@channel_alignment);
uimenu('Text','Load channel alignment','ForegroundColor','b','CallBack',@preselected_channel_alignment);

subplot(1,1,1)
hold on

% data_down_sampled = cell(length(data),1);
% for i = 1:length(data)-1
%     data_down_sampled{i} = loc_list_down_sample(data{i},scatter_num);
% end
% data_down_sampled{i+1} = data{i+1};

for i = 1:numel(data)
%     scatter(data_down_sampled{i}.x_data,data_down_sampled{i}.y_data,10,Colors(i,:),'filled');
    scatter(data{i}.x_data,data{i}.y_data,10,Colors(i,:),'filled');
end

set(gca,'color',[0,0,0],'TickDir', 'out','box','on','BoxStyle','full','XTick',[],'YTick',[]);
% set(gca,'color',[0,0,0],'TickDir', 'out','box','on','BoxStyle','full','XColor',[1 1 1],'YColor',[1 1 1],'XAxisLocation','top');
pbaspect([1 1 1])
axis off

Legend = cell(numel(data),1);
for i = 1:numel(data)
    Legend{i} = ['Channel ' num2str(i)];
end
legend(Legend,'Color','w')

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

    function channel_alignment(~,~,~)
        data_aligned = do_alignment_channels(data);
        close
        send_data_to_workspace(data_aligned)
        loc_list_channel_alignment(data_aligned,scatter_num);
    end

    function preselected_channel_alignment(~,~,~)
        data_aligned = load_alignment_channels(data);
        close
        send_data_to_workspace(data_aligned)
        loc_list_channel_alignment(data_aligned,scatter_num);
    end

end