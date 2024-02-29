function data_flip = loc_list_flip_ud(data)
data_flip = cell(1,length(data));
for i = 1:length(data)
    data_flip{i} = loc_list_flip_inside(data{i});
end
loc_list_plot(data_flip)
end

function data_flip = loc_list_flip_inside(data)
max_y = max(data.y_data);
data_flip.x_data = data.x_data;
data_flip.y_data = max_y-data.y_data;
data_flip.area = data.area;
data_flip.name = [data.name,'_flipped_ud'];
data_flip.type = 'loc_list';
end