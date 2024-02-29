function data_simulated = loc_list_random_point_pattern_simulation()
input_values = inputdlg({'x_i,x_f','number of localizations:'},'',1,{'-3 3','100'});
if isempty(input_values)==1
    data_simulated = [];
else
    x = str2num(input_values{1});
    N = str2num(input_values{2});
    if N<1
        N=1;
    end
    data = (max(x)-min(x))*rand(N,2);
    data = data+min(x);
    data_simulated{1}.x_data = data(:,1);
    data_simulated{1}.y_data = data(:,2);
    data_simulated{1}.area = 0.7+zeros(length(data(:,1)),1);
    data_simulated{1}.name = 'rand_loc_list';
    data_simulated{1}.type = 'loc_list'; 
end