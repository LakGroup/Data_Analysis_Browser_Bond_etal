function data_scaled = loc_list_multiply_by_number(data)
answer = inputdlg({'Number:'},'Input',[1 50],{'116'});
if isempty(answer)~=1
    number = str2double(answer{1});
    data_scaled = cell(1,length(data));
    for i = 1:length(data)
        data_scaled{i} = loc_list_scale_data_inside(data{i},number);
    end
    loc_list_plot(data_scaled)
end
end

function data = loc_list_scale_data_inside(data,number)
data.x_data = data.x_data*number;
data.y_data = data.y_data*number;
end