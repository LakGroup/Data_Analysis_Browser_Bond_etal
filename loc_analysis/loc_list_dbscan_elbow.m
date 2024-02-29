function [data_clustered,data_not_clustered] = loc_list_dbscan_elbow(data)
answer = inputdlg({'Enter Minimum Number of Points:'},'Input',[1 50],{'5'});
if isempty(answer)~=1
    db_points = str2double(answer{1});
    for i=1:length(data)
        counter(1) = i;
        counter(2) = length(data);
        [data_clustered{i},data_not_clustered{i},epsilon(i,1),data_elbow{i}] = loc_list_dbscan_elbow_inside(data{i},db_points,counter);
        row_names{i} = data{i}.name;
    end
    %spectrum_1d_plot(data_elbow)
    table_data_plot(epsilon,row_names,'Epsilon','Epsilon Values Elbow Method')
    loc_list_plot(data_clustered)
    loc_list_plot(data_not_clustered)
end
end

function [data_clustered,data_not_clustered,epsilon,data_elbow] = loc_list_dbscan_elbow_inside(data,db_points,counter)
f = waitbar(0,['DBSCAN...',num2str(counter(1)),'/',num2str(counter(2))]);
data_db(:,1) = data.x_data;
data_db(:,2) = data.y_data;

waitbar(0.1,f,['DBSCAN Finding Search Radius...',num2str(counter(1)),'/',num2str(counter(2))]);
[epsilon,elbow_graph] = dbscan_elbow_method_epsilon_value(data_db,db_points-1);
data_elbow.epsilon = epsilon;
data_elbow.x_data = (1:length(elbow_graph))';
data_elbow.y_data = elbow_graph';
data_elbow.name = [data.name,'_knn_plot'];
data_elbow.type = 'spectrum_1d';
data_elbow.info = 'NaN';

waitbar(0.4,f,['DBSCAN Starting DB...',num2str(counter(1)),'/',num2str(counter(2))]);

save('temp_file.mat','data_db','epsilon','db_points');
system('python dbscan_python.py');
load('idx')
delete temp_file.mat
delete idx.mat
%idx = dbscan(data_db,epsilon,db_points);
I = idx == -1;

waitbar(0.7,f,['DBSCAN Reporting Not-clustered Data...',num2str(counter(1)),'/',num2str(counter(2))]);
data_not_clustered.x_data = data_db(I,1);
data_not_clustered.y_data = data_db(I,2);
data_not_clustered.area = zeros(length(data_not_clustered.x_data),1);
data_not_clustered.name = [data.name,'_dbscan_not_clustered_min_points_',num2str(db_points),'_epsilon_',num2str(epsilon)];
data_not_clustered.type = data.type;

waitbar(0.9,f,['DBSCAN Reporting Clustered Data...',num2str(counter(1)),'/',num2str(counter(2))]);
idx(I) = [];
data_db(I,:) = [];
clusters = loc_list_find_clusters(data_db,idx);
I = cellfun(@(x) size(x,1),clusters);
I = I>=db_points;
clusters = clusters(I);
clusters = vertcat(clusters{:});

data_clustered.x_data = clusters(:,1);
data_clustered.y_data = clusters(:,2);
data_clustered.area = clusters(:,3);
data_clustered.name = [data.name,'_dbscan_clusters_min_points_',num2str(db_points),'_epsilon_',num2str(epsilon)];
data_clustered.type = data.type;

close(f)
end

function [epsilon,knn_d] = dbscan_elbow_method_epsilon_value(data,n)
[~,knn_d] = knnsearch(data,data,'K',n);
knn_d = (sort(knn_d(:,end)))';
epsilon = prctile(knn_d,95);
end