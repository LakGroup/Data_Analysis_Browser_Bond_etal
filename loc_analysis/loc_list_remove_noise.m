function [data_filtered,data_noise] = loc_list_remove_noise(data)
answer = inputdlg({'Enter k-value for KNN Search (Including the point itself):','Cutoff Percentile:'},'Enter k-value for KNN Search (Including the point itself):',[1 50],{'5','95'});
if isempty(answer)~=1    
    k = str2double(answer{1});
    cutoff = str2double(answer{2}); 
    for i=1:length(data)
        counter(1) = i;
        counter(2) = length(data);
        [data_filtered{i},data_noise{i}] = loc_list_remove_noise_inside(data{i},k,cutoff,counter);        
    end
end
end

function [data_filtered,data_noise] = loc_list_remove_noise_inside(data,knn_k_value_fitler_noise,cutoff,counter)
f = waitbar(0,['Removing Noise...',num2str(counter(1)),'/',num2str(counter(2))]);
data_to_remove(:,1) = data.x_data;
data_to_remove(:,2) = data.y_data;
data_to_remove(:,3) = data.area;

waitbar(0.5,f,['Removing Noise KNN...',num2str(counter(1)),'/',num2str(counter(2))]);

[data_removed,data_background] = remove_noise(data_to_remove,knn_k_value_fitler_noise,cutoff);
data_filtered.x_data = data_removed(:,1);
data_filtered.y_data = data_removed(:,2);
data_filtered.area = data_removed(:,3);
data_filtered.name = [data.name,'_filter_data_knn_',num2str(knn_k_value_fitler_noise)];
data_filtered.type = 'loc_list';

data_noise.x_data = data_background(:,1);
data_noise.y_data = data_background(:,2);
data_noise.area = data_background(:,3);
data_noise.name = [data.name,'_noise_data_knn_',num2str(knn_k_value_fitler_noise)];
data_noise.type = 'loc_list';
close(f)
end

function [data_removed,data_noise] = remove_noise(data,n,cutoff)
[~,knn_d] = knnsearch(data(:,1:2),data(:,1:2),'K',n);
knn_d = knn_d(:,end);
knn_d_sorted = (sort(knn_d))';
epsilon = prctile(knn_d_sorted,cutoff);
I = knn_d<epsilon;
% [~,I] = min(abs(knn_d-epsilon));
data_removed = data(I,:);
I = knn_d>=epsilon;
data_noise = data(I,:);
end