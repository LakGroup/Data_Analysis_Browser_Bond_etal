function voronoi_data = loc_list_voronoi_segmentation(data)
for i=1:length(data)
    counter(1) = i;
    counter(2) = length(data);
    voronoi_data{i}.vor = loc_list_construct_voronoi_structure(data{i}.x_data,data{i}.y_data,counter);
    voronoi_data{i}.name = [data{i}.name,'_vor'];
    voronoi_data{i}.type = 'voronoi_data';
    clear data_adjusted
end
voronoi_data_plot(voronoi_data)
end