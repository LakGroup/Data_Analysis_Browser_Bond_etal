function loc_list_two_channel_clusters(data)

global Int

if length(data) ~= 2
    msgbox('Number of files selected should be equal to 2')
else

    answer = inputdlg({'Scatter 1st channel: ','Scatter 2nd channel: ','Color 1: '},'Input',[1 50],{'20','20','c'});
    scatter_size_b(1) = str2double(answer{1});
    scatter_size_b(2) = str2double(answer{2});
    Color1 = answer{3};

    figure('Units','Pixels','Position',[300 200 1350 650])
    set(gcf,'name','Montage Plot','NumberTitle','off','color',[0,0,0],'menubar','none','toolbar','figure');

    subplot = @(m,n,p) subtightplot (m, n, p, [0 0], [0 0], [0 0]);

    uimenu('Text','Save Image High Quality','ForegroundColor','b','CallBack',@save_image);
    uimenu('Text','Add Scale Bar','ForegroundColor','b','CallBack',@add_scale_bar);
    uimenu('Text','ROI Crop','ForegroundColor','b','CallBack',@ROI_Crop);
    uimenu('Text','Send Data to Workspace','ForegroundColor','b','CallBack',@send_Data);

    subplot(1,1,1)
    hold on
    a = scatter(data{1}.x_data,data{1}.y_data,scatter_size_b(1),Color1,'filled');

    Groups = findgroups(data{2}.identifier);
    ClustersByRef = splitapply(@(x){(x)},[data{2}.x_data data{2}.y_data data{2}.area data{2}.identifier],Groups);
    maxClusters = max(cellfun(@(x) numel(unique(x)),ClustersByRef));
    
    hex = ['#1f77b4';'#aec7e8';'#00ffff';'#ffbb78';'#2ca02c';'#98df8a';'#d62728';'#ff9896';'#9467bd';'#c5b0d5';'#ff7f0e';'#8c564b';'#c49c94';'#e377c2';'#f7b6d2';'#7f7f7f';'#c7c7c7';'#bcbd22';'#dbdb8d';'#17becf';'#9edae5'];
    raw = sscanf(hex.','#%2x%2x%2x',[3,Inf]).';
    num = size(raw,1);
    Color2 = raw(1+mod(0:maxClusters-1,num),:) / 255;
    if any(ismember(Color2,a.CData,'rows'))
        Color2(ismember(Color2,a.CData,'rows'),:) = [0.4 0.5 0.6];
    end

    for i = 1:numel(ClustersByRef)

        Groups = findgroups(ClustersByRef{i}(:,3)); % Find unique groups and their number
        ColocClustersByRef = splitapply(@(x){(x)},[ClustersByRef{i}(:,1:2)],Groups);

        for j = 1:numel(ColocClustersByRef)
            scatter(ColocClustersByRef{j}(:,1),ColocClustersByRef{j}(:,2),scatter_size_b(2),Color2(j,:),'filled');
        end

    end
    set(gca,'color',[0,0,0],'TickDir', 'out','box','on','BoxStyle','full','XTick',[],'YTick',[]);
    pbaspect([1 1 1])
    axis equal
    axis off
    Axis = axis;
    set(gcf,'paperunits','inches','paperposition',[0 0 [(Axis(2)-Axis(1))*117 (Axis(4)-Axis(3))*117]/300]);

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
        loc_list_two_channel(data_outofcrop,scatter_size,scatter_num)
    end

    function send_Data(~,~,~)
        send_data_to_workspace(data)
    end

end