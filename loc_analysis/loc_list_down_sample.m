function data_down_sampled = loc_list_down_sample(data,scatter_num)
if length(data.x_data)>scatter_num
    vec = 1:length(data.x_data);
    vec = vec(randperm(length(vec)));
    I = vec(1:scatter_num);    
    data_down_sampled.x_data = data.x_data(I);
    data_down_sampled.y_data = data.y_data(I);
    data_down_sampled.area = data.area(I);
    data_down_sampled.name = data.name;
    data_down_sampled.type = data.type;
    clear vec
else
    data_down_sampled = data;
end
end