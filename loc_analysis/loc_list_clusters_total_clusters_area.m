function loc_list_clusters_total_clusters_area(data)
counter = 0;
for i = 1:length(data)
    data_to = unique(data{i}.area);
    if length(data_to)>1
        counter = counter+1;
        data_to_send{counter} = data{i};
    end
end
if exist('data_to_send','var')
    f = waitbar(0,'Finding Total Cluster Area');
    for i = 1:length(data_to_send)
        data_table(i,1) = clusters_extract_statistics(data_to_send{i});
        names{i} = data_to_send{i}.name;
        waitbar(i/length(data_to_send),f,'Finding Total Cluster Area');
    end
    data_table(end+1,1) = sum(data_table(:,1));
    names{end+1} = 'Total Sum';
    close(f);
    table_data_plot(data_table,names,{'Total Cluster Area'},'Total Cluster Area Table')
else
    msgbox('there is only one cluster')
end
end

function data_table = clusters_extract_statistics(data)
clusters = loc_list_extract_clusters_from_data(data);
for i = 1:length(clusters)
    data_table(i) = clusters{i}(1,3);    
end
data_table = sum(data_table);
end