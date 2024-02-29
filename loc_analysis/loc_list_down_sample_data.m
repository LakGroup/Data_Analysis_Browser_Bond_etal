function data_down_sample = loc_list_down_sample_data(data)
answer = inputdlg({'Number of Localizations:'},'Input',[1 50],{'50000'});
if isempty(answer)~=1
    scatter_num = str2double(answer{1});
    data_down_sample = cell(1,length(data));
    for i = 1:length(data)
        if length(data{i}.x_data)>scatter_num
            vec = 1:length(data{i}.x_data);
            vec = vec(randperm(length(vec)));
            I = vec(1:scatter_num);                             
            data_down_sample{i}.x_data = data{i}.x_data(I);
            data_down_sample{i}.y_data = data{i}.y_data(I);
            data_down_sample{i}.area = data{i}.area(I);
            data_down_sample{i}.name = [data{i}.name,'_down_sampled_',num2str(scatter_num)];
            data_down_sample{i}.type = data{i}.type;
            clear vec
        else
            data_down_sample{i} = data{i};
        end
    end
    loc_list_plot(data_down_sample)
end
end