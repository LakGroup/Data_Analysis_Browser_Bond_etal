function [data_filter_above,data_filter_below] = loc_list_clusters_filter_aspect_ratio(data)
answer = inputdlg({'Major Axis to Minor Axis Aspect Ratio Threshold:'},'Input',[1 50],{'1.5'});
if isempty(answer)~=1
    min_aspect_ratio = str2double(answer{1});   
    f = waitbar(0,'Filtering Based On Aspect Ratio...');
    for i=1:length(data)
        [data_filter_above{i},data_filter_below{i}] = filter_aspect_ratio(data{i},min_aspect_ratio);
        waitbar(i/length(data),f,['Filtering Based On Aspect Ratio...',num2str(i),'/',num2str(length(data))]);
    end 
    close(f)
    data_filter_above = data_filter_above(~cellfun(@(x) isempty(x),data_filter_above));
    data_filter_below = data_filter_below(~cellfun(@(x) isempty(x),data_filter_below));
end
end

function [data_to_send_above,data_to_send_below] = filter_aspect_ratio(data,min_aspect_ratio)
clusters = loc_list_extract_clusters_from_data(data);

for i = 1:length(clusters)
    [~,cluster] = pca(clusters{i}(:,1:2));
    major_axis_length = max(cluster(:,1))-min(cluster(:,1));
    minor_axis_length = max(cluster(:,2))-min(cluster(:,2));
    max_val = max(major_axis_length,minor_axis_length);
    min_val = min(major_axis_length,minor_axis_length);
    aspect_ratio(i) = max_val/min_val;    
end

I = aspect_ratio>min_aspect_ratio;
clusters_above = clusters(I);
if isempty(clusters_above)~=1
    clusters_above = vertcat(clusters_above{:});
    data_to_send_above.x_data = clusters_above(:,1);
    data_to_send_above.y_data = clusters_above(:,2);
    data_to_send_above.area = clusters_above(:,3);
    data_to_send_above.name = [data.name,'_aspect_ratio_filter_above_',num2str(min_aspect_ratio)];
    data_to_send_above.type = 'loc_list';
else
    data_to_send_above = [];
end

clusters_below = clusters(~I);
if isempty(clusters_below)~=1
    clusters_below = vertcat(clusters_below{:});
    data_to_send_below.x_data = clusters_below(:,1);
    data_to_send_below.y_data = clusters_below(:,2);
    data_to_send_below.area = clusters_below(:,3);
    data_to_send_below.name = [data.name,'_aspect_ratio_filter_below_',num2str(min_aspect_ratio)];
    data_to_send_below.type = 'loc_list';
else
    data_to_send_below = [];
end
end