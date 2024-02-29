function [data_clustered,data_not_clustered] = voronoi_data_get_voronoi_cluster(data,type)
if type ==1
    answer = inputdlg({'Area Threshold:','Minimum Number of Localizations per Cluster:'},'Input',[1 50],{'0.013','5'});
else
   answer = inputdlg({'Area Threshold:','Minimum Number of Localizations per Cluster:'},'Input',[1 50],{'30','5'}); 
end
if isempty(answer)~=1
    area_threshold = str2double(answer{1});
    min_number_of_localizations = str2double(answer{2});
    for i = 1:length(data)    
        counter(1) = i;
        counter(2) = length(data);
        [data_clustered{i},data_not_clustered{i},area_threshold_table(i,1)] = construct_clusters(data{i},area_threshold,min_number_of_localizations,type,counter);
        row_names{i} = data{i}.name;
    end
    column_names = {'Area Threshold'};
    title = 'Voronoi Area Threshold';
    table_data_plot(area_threshold_table,row_names,column_names,title)
else
    data_clustered = [];
    data_not_clustered = [];
end
end