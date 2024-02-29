function [data_filter,data_filter_below] = loc_list_clusters_filter_random_selection(data)
answer = inputdlg({'Enter Number of Clusters to Randomly Select:'},'Input',[1 50],{'1000'});
if isempty(answer)~=1
    N = str2double(answer{1});
    f = waitbar(0,'Filtering Based on Number of Locs...');
    for i=1:length(data)
        data_filter{i} = filter_random_selection(data{i},N);
        waitbar(i/length(data),f,['Filtering Based On Minimum Number of Locs...',num2str(i),'/',num2str(length(data))]);
    end
    close(f)
    data_filter = data_filter(~cellfun(@(x) isempty(x),data_filter)); 
    loc_list_plot(data_filter)    
end    
end

function data_to_send = filter_random_selection(data,N)
clusters = loc_list_extract_clusters_from_data(data);

if length(clusters)>N
    vec = 1:length(clusters);
    vec = vec(randperm(length(vec)));
    I = vec(1:N);
else
    I = 1:length(clusters);
end

clusters_filtered = clusters(I);
if isempty(clusters_filtered)~=1
    clusters_filtered = vertcat(clusters_filtered{:});
    data_to_send.x_data = clusters_filtered(:,1);
    data_to_send.y_data = clusters_filtered(:,2);
    data_to_send.area = clusters_filtered(:,3);
    data_to_send.name = [data.name,'_clusters_random_selection_',num2str(N)];
    data_to_send.type = 'loc_list';
else
    data_to_send = [];
end
% 
% clusters_below = clusters(~I);
% if isempty(clusters_below)~=1
%     clusters_below = vertcat(clusters_below{:});
%     data_to_send_below.x_data = clusters_below(:,1);
%     data_to_send_below.y_data = clusters_below(:,2);
%     data_to_send_below.area = clusters_below(:,3);
%     data_to_send_below.name = [data.name,'_no_of_locs_filter_below_',num2str(N)];
%     data_to_send_below.type = 'loc_list';
% else
%     data_to_send_below = [];
% end
end