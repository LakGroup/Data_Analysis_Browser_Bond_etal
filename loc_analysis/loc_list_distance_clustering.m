function loc_list_distance_clustering(data)
answer = inputdlg({'Minimum Number of Points to Cluster:','Epsilon:'},'Input',[1 50],{'5','0.5'});
if isempty(answer)~=1
    N = str2double(answer{1});
    epsilon = str2double(answer{2});
    for i=1:length(data)
        counter(1) = i;
        counter(2) = length(data);
        [data_clustered{i},data_not_clustered{i}] = loc_list_distance_clusterin_inside(data{i},N,epsilon,counter);
        loc_list_plot(data_clustered)
        loc_list_plot(data_not_clustered)
    end
end
end

function [data_clustered,data_not_clustered] = loc_list_distance_clusterin_inside(data,N,epsilon,counter)
f = waitbar(0,['Distance Clustering...',num2str(counter(1)),'/',num2str(counter(2))]);

r = [data.x_data,data.y_data];

% waitbar(0.1,f,['Distance Clustering Finding Minimum Distance...',num2str(counter(1)),'/',num2str(counter(2))]);
% if N<3
%     N = 4;
% end
% epsilon = distance_clustering_elbow_method_epsilon_value(r,N-1);

waitbar(0.3,f,['Distance Clustering Finding Neighbors...',num2str(counter(1)),'/',num2str(counter(2))]);
idx = find_nearest_points(r,epsilon,N);

waitbar(0.5,f,['Distance Clustering Finding Clusters...',num2str(counter(1)),'/',num2str(counter(2))]);
idx_all = horzcat(idx{:});
idx_not_clustered = setdiff(1:size(r,1),idx_all);

[clusters,~] = loc_list_clusters(r,idx);
clusters = vertcat(clusters{:});
data_clustered.x_data = clusters(:,1);
data_clustered.y_data = clusters(:,2);
data_clustered.area = clusters(:,3);
data_clustered.name = data.name;
data_clustered.type = data.type;

waitbar(0.7,f,['Distance Clustering Finding Not-Clustered Data...',num2str(counter(1)),'/',num2str(counter(2))]);
data_not_clustered.x_data = r(idx_not_clustered,1);
data_not_clustered.y_data = r(idx_not_clustered,2);
data_not_clustered.area = zeros(length(data_not_clustered.x_data),1);
data_not_clustered.name = [data.name,'_distance_clustering_not_clustered_min_points_',num2str(N),'_epsilon_',num2str(epsilon)];
data_not_clustered.type = data.type;
waitbar(1,f,['Distance Clustering Finding Not-Clustered Data...',num2str(counter(1)),'/',num2str(counter(2))]);
close(f)
end

function index = find_nearest_points(r,epsilon,N)
neighbors = rangesearch(r,r,epsilon);
for i = 1:length(neighbors)
    if length(neighbors{i})==1
        neighbors{i}(1) = [];
    end
end

index =[];
counter = 0;
used_points = zeros(length(neighbors),1);
if isempty(neighbors)~=1    
    for i =1:length(neighbors)
        if ~used_points(i)
            seed = neighbors{i};
            if ~isempty(seed)
                size_one = 0;
                size_two = length(seed);
                while size_two~=size_one
                    size_one = length(seed);
                    idx = neighbors(seed);
                    idx = horzcat(idx{:});
                    idx = unique(idx);
                    if ~any(intersect(idx,seed))
                        seed = sort([idx;seed]);
                    else
                        seed = idx;
                    end
                    size_two = length(seed);
                end
                used_points(seed) = 1;
                counter = counter+1;
                index{counter,1} = seed;
            end
        end
    end
end
idx = cellfun(@(x) length(x),index);
idx = idx>=N;
index = index(idx);
end

function [clusters,boundary] = loc_list_clusters(r,idx)
for i = 1:length(idx)    
    x = r(idx{i},1);
    y = r(idx{i},2);    
    clusters{i}(:,1) = x;
    clusters{i}(:,2) = y;
    [area,boundary_points] = loc_list_calculate_boundary_area(x,y);
    clusters{i}(:,3) = area;
    boundary{i} = boundary_points;
    clear x y area boundary_points
end
end

function epsilon = distance_clustering_elbow_method_epsilon_value(data,n)
[~,knn_d] = knnsearch(data,data,'K',n);
knn_d = (sort(knn_d(:,end)))';
epsilon = prctile(knn_d,95);
end