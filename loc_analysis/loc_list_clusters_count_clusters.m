function loc_list_clusters_count_clusters(data)
for i = 1:length(data)
    number_of_clusters(i,1) = length(unique(data{i}.area));
    names{i} = data{i}.name;
end
number_of_clusters(end+1,1) = sum(number_of_clusters);
names{end+1} = 'Total Number of Clusters';
table_data_plot(number_of_clusters,names,{'Total Number of Clusters'},'Total Number of Clusters')
end