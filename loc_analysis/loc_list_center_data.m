function data_center = loc_list_center_data(data)
data_center = cell(1,length(data));
for i = 1:length(data)
    data_center{i} = loc_list_center_data_inside(data{i});
end
loc_list_plot(data_center)
end

function data = loc_list_center_data_inside(data)
data.x_data = data.x_data - (max(data.x_data)+min(data.x_data))/2;
data.y_data = data.y_data - (max(data.y_data)+min(data.y_data))/2;
end