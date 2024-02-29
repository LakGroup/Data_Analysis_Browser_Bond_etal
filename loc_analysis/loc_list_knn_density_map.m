function knn_data = loc_list_knn_density_map(data)
answer = inputdlg({'KNN k value:','Maximum Number of Localizations for Down Sampling:'},'Input',[1 50],{'10','10000'});
if isempty(answer)~=1
    k = str2double(answer{1});
    num_points = str2double(answer{2});    
    knn_data = cell(1,length(data));
    for i=1:length(data)
        counter(1) = i;
        counter(2) = length(data);
        knn_data{i} = loc_list_density_plot_knn_search_inside(data{i},k,num_points,counter);        
    end    
    loc_list_plot(knn_data)
end
end

function knn_data = loc_list_density_plot_knn_search_inside(data,k,num_points,counter)
f = waitbar(0,['KNN Density Plot Downsampling...',num2str(counter(1)),'/',num2str(counter(2))]);
data_adjusted = loc_list_down_sample(data,num_points);
data_knn(:,1) = data_adjusted.x_data;
data_knn(:,2) = data_adjusted.y_data;

waitbar(0.5,f,['KNN Density Plot k-search...',num2str(counter(1)),'/',num2str(counter(2))]);
[~,d] = knnsearch(data_knn,data_knn,'K',k);
d = mean(d,2);
d = 1./d;
knn_data.x_data = data_knn(:,1);
knn_data.y_data = data_knn(:,2);
knn_data.area = d;
knn_data.name = [data.name,'_knn_density_plot_k_',num2str(k)];
knn_data.type = 'loc_list';
close(f)
end