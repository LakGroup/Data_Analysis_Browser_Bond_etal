function data_flip = loc_list_flip_lr(data)
data_flip = cell(1,length(data));
for i = 1:length(data)
    data_flip{i} = loc_list_flip_inside(data{i});
end
loc_list_plot(data_flip)
end

function data_flip = loc_list_flip_inside(data)
max_x = max(data.x_data);
data_flip.x_data = max_x-data.x_data;
data_flip.y_data = data.y_data;
data_flip.area = data.area;
data_flip.name = [data.name,'_flipped_lr'];
data_flip.type = 'loc_list';
end