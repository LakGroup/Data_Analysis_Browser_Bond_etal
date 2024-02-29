function data_k_means = loc_list_k_means(data)
answer = inputdlg({'k-Value:'},'Input',[1 50],{'5'});
if isempty(answer)~=1
    k = str2double(answer{1});
    for i=1:length(data)
        counter(1) = i;
        counter(2) = length(data);
        data_k_means{i} = loc_list_k_means_inside(data{i},k,counter);        
    end 
    loc_list_plot(data_k_means)
end
end

function data_clustered = loc_list_k_means_inside(data,k,counter)
f = waitbar(0,['k-means...',num2str(counter(1)),'/',num2str(counter(2))]);
xy(:,1) = data.x_data;
xy(:,2) = data.y_data;

waitbar(0.2,f,['k-means Finding k Clusters...',num2str(counter(1)),'/',num2str(counter(2))]);
idx = kmeans(xy,k,'Distance','sqeuclidean');

waitbar(0.5,f,['k-means Reporting Clustered Data...',num2str(counter(1)),'/',num2str(counter(2))]);
clusters = loc_list_find_clusters(xy,idx);
clusters = vertcat(clusters{:});

waitbar(0.9,f,['k-means Reporting Clustered Data...',num2str(counter(1)),'/',num2str(counter(2))]);
data_clustered.x_data = clusters(:,1);
data_clustered.y_data = clusters(:,2);
data_clustered.area = clusters(:,3);
data_clustered.name = [data.name,'_dbscan_clusters'];
data_clustered.type = data.type;

close(f)
end