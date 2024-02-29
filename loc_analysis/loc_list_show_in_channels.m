function channel_data = loc_list_show_in_channels(data)
areas = logspace(0,1,length(data));
for i = 1:length(data)
    x{i} = data{i}.x_data;
    y{i} = data{i}.y_data;
    area{i} = areas(i)*ones(length(data{i}.x_data),1);    
end
x = vertcat(x{:});
y = vertcat(y{:});
area = vertcat(area{:});

channel_data{1}.x_data = x;
channel_data{1}.y_data = y;
channel_data{1}.area = area;
channel_data{1}.name = data{1}.name;
channel_data{1}.type = 'loc_list';
loc_list_plot(channel_data)
end