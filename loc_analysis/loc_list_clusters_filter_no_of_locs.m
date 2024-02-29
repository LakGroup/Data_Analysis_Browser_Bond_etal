function [data_filter_above,data_filter_below] = loc_list_clusters_filter_no_of_locs(data)
answer = inputdlg({'Enter Minimum Number of Points per Cluster:'},'Input',[1 50],{'5'});
if isempty(answer)~=1
    min_N = str2double(answer{1});
    f = waitbar(0,'Filtering Based on Number of Locs...');
    for i=1:length(data)
        [data_filter_above{i},data_filter_below{i}] = filter_no_of_locs(data{i},min_N);
        waitbar(i/length(data),f,['Filtering Based On Minimum Number of Locs...',num2str(i),'/',num2str(length(data))]);
    end
    close(f)
    data_filter_above = data_filter_above(~cellfun(@(x) isempty(x),data_filter_above));
    data_filter_below = data_filter_below(~cellfun(@(x) isempty(x),data_filter_below));
end    
end

function [data_to_send_above,data_to_send_below] = filter_no_of_locs(data,min_N)
clusters = loc_list_extract_clusters_from_data(data);
for i = 1:length(clusters)
    no_of_locs(i) = size(clusters{i},1);
end

I = no_of_locs>=min_N;
clusters_above = clusters(I);
if isempty(clusters_above)~=1
    clusters_above = vertcat(clusters_above{:});
    data_to_send_above.x_data = clusters_above(:,1);
    data_to_send_above.y_data = clusters_above(:,2);
    data_to_send_above.area = clusters_above(:,3);
    if isfield(data,'coordinates')
        data_to_send_above.coordinates = data.coordinates;
    end
    if isfield(data,'identifier')
        data_to_send_above.identifier = clusters_above(:,4);
    end
    data_to_send_above.name = [data.name,'_no_of_locs_filter_above_',num2str(min_N)];
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
    if isfield(data,'coordinates')
        data_to_send_below.coordinates = data.coordinates;
    end
    if isfield(data,'identifier')
        data_to_send_below.identifier = clusters_below(:,4);
    end
    data_to_send_below.name = [data.name,'_no_of_locs_filter_below_',num2str(min_N)];
    data_to_send_below.type = 'loc_list';
else
    data_to_send_below = [];
end
end