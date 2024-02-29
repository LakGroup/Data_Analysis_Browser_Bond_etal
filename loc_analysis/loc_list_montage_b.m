function loc_list_montage_b(data,map,scatter_num,scatter_size,c_lim)

global Int

hex = ['#1f77b4';'#aec7e8';'#00ffff';'#ffbb78';'#2ca02c';'#98df8a';'#d62728';'#ff9896';'#9467bd';'#c5b0d5';'#ff7f0e';'#8c564b';'#c49c94';'#e377c2';'#f7b6d2';'#7f7f7f';'#c7c7c7';'#bcbd22';'#dbdb8d';'#17becf';'#9edae5'];
raw = sscanf(hex.','#%2x%2x%2x',[3,Inf]).';
num = size(raw,1);
maxClusters = 20;
Color2 = raw(1+mod(0:maxClusters-1,num),:) / 255;


if length(data)>3
    msgbox('Number of files selected should be less than or equal to 3')
else
    figure()
    set(gcf,'name','Montage Plot','NumberTitle','off','color',[0.1 0.1 0.1],'units','normalized','position',[0.15 0.2 0.7 0.6]);

    subplot = @(m,n,p) subtightplot (m, n, p, [0 0], [0 0], [0 0]);
    data_down_sampled = cell(length(data),1);
    for i = 1:length(data)
        if i == 1
            data_down_sampled{i} = loc_list_down_sample(data{i},scatter_num);
            IdxBoundary = boundary(data{i}.x_data,data{i}.y_data,0.8);
            BoundaryCoords = horzcat(data{i}.x_data(IdxBoundary),data{i}.y_data(IdxBoundary));
            shpRef = polyshape(BoundaryCoords);

            ax(i) = subplot(1,length(data)+1,i);
            scatter(data_down_sampled{i}.x_data,data_down_sampled{i}.y_data,scatter_size,'m','filled');
            set(gca,'color',[0.1 0.1 0.],'colormap',map,'ColorScale','log')
            pbaspect([1 1 1])
            axis equal
            box on
            axis off
        elseif i == 2
            data_down_sampled{i} = loc_list_down_sample(data{i},scatter_num);
            Colors = 'y';
            ax(i) = subplot(1,length(data)+1,i);
            scatter(data_down_sampled{i}.x_data,data_down_sampled{i}.y_data,scatter_size,Colors,'filled');
            set(gca,'color',[0.1 0.1 0.],'colormap',map,'ColorScale','log')
            pbaspect([1 1 1])
            axis equal
            box on
            axis off
        elseif i == 3
            data_down_sampled{i} = loc_list_down_sample(data{i},scatter_num);
            Groups = findgroups(data_down_sampled{i}.area); % Find unique groups and their number
            ColocClustersByRef = splitapply(@(x){(x)},horzcat(data_down_sampled{i}.x_data,data_down_sampled{i}.y_data,data_down_sampled{i}.area),Groups);

            for j = 1:numel(ColocClustersByRef)
                ax(i) = subplot(1,length(data)+1,i);
                scatter(ColocClustersByRef{j}(:,1),ColocClustersByRef{j}(:,2),scatter_size,Color2(j,:),'filled');
                hold on;
            end
            set(gca,'color',[0.1 0.1 0.],'colormap',map,'ColorScale','log')
            pbaspect([1 1 1])
            axis equal
            box on
            axis off
        end
    end
    ax(i) = subplot(1,length(data)+1,4);
    plot(shpRef,"FaceColor",'m','FaceAlpha',1,'EdgeColor','m','EdgeAlpha',1);
    hold on
    for j = 1:numel(ColocClustersByRef)
        scatter(ColocClustersByRef{j}(:,1),ColocClustersByRef{j}(:,2),scatter_size,Color2(j,:),'filled');
        hold on;
    end
    set(gca,'color',[0.1 0.1 0.],'colormap',map,'ColorScale','log')
    pbaspect([1 1 1])
    axis equal
    box on
    axis off

    ax1 = axis;

    for i = 1:4
        subplot(1,length(data)+1,i);
        axis(ax1)
    end

end
linkaxes(ax,'xy')

uimenu('Text','Save Image High Quality','ForegroundColor','b','CallBack',@save_image);
uimenu('Text','Add Scale Bar','ForegroundColor','b','CallBack',@add_scale_bar);
uimenu('Text','Show ColorBar','ForegroundColor','b','CallBack',@show_colorbar);
uimenu('Text','ROI Selection','ForegroundColor','b','CallBack',@ROI_Selection);
uimenu('Text','Send Data to Workspace','ForegroundColor','b','CallBack',@send_Data);

function save_image(~,~,~)
get_capture_from_figure()
end

function add_scale_bar(~,~,~) 
answer = inputdlg({'Pixel Size (nm per pixel):','Scale Bar Size (x-axis um):','Scale Bar Size (y axis um):'},'Input',[1 50],{'117','2','0.5'});
if isempty(answer)~=1
    pixel_size = str2double(answer{1});
    scale_bar_size_x = str2double(answer{2});
    scale_bar_size_y = str2double(answer{3});
    allData_x = [];
    allData_y = [];
    for k = 1:length(data_down_sampled)
        allData_x = vertcat(allData_x,data_down_sampled{k}.x_data);
        allData_y = vertcat(allData_y,data_down_sampled{k}.y_data);
    end
    min_x = min(allData_x);
    max_y = max(allData_y);
    
    for k = 1:length(data)+1
        subplot(1,length(data)+1,k)
        pixels_um_x = scale_bar_size_x/(pixel_size/1000);
        pixels_um_y = scale_bar_size_y/(pixel_size/1000);
        rectangle('Position',[min_x max_y pixels_um_x pixels_um_y],'facecolor','w')
    end
end
end

function show_colorbar(~,~,~)
subplot = @(m,n,p) subtightplot (m, n, p, [0 0], [0 0], [0 0]);
for k = 1:length(data)
    subplot(1,length(data_down_sampled),k)
    h = colorbar;
    h.TickLabelInterpreter = 'latex';
    h.FontSize = 14;
    h.Color = 'w';
end
end

function ROI_Selection(~,~,~)
[data_cropped,data_outofcrop,Int] = loc_list_roi_DualChannel(data,Int);
close
send_data_to_workspace(data_cropped)
loc_list_montage(data_outofcrop,map,scatter_num,scatter_size,c_lim)
end

function send_Data(~,~,~)
send_data_to_workspace(data)
end

end