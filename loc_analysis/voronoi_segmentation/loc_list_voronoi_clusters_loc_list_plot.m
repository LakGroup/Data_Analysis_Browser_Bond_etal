function loc_list_voronoi_clusters_loc_list_plot(data)
f=waitbar(0,'Please wait...');
for i=1:length(data)
    color = linspace(0,1,length(data{i}.clusters_points));
    color = color(randperm(length(color)));
    for j = 1:length(data{i}.clusters_points)
        points{j} = data{i}.clusters_points{j};
        colors{j} = ones(size(points{j},1),1)*color(j);
    end
    points = vertcat(points{:});
    colors = vertcat(colors{:});    
    data_to_send{i}.x_data = points(:,1);
    data_to_send{i}.y_data = points(:,2);
    data_to_send{i}.name = data{i}.name;
    data_to_send{i}.color = colors;
    data_to_send{i}.type = 'loc_list';
    clear points colors
    waitbar(i/length(data),f,'Please wait...');
end
close(f)
loc_list_plot(data_to_send)
end