function piled_data = loc_list_pile_data(data)
f = waitbar(0,'Piling Data');
for i = 1:length(data)
    waitbar(i/length(data),f,'Piling Data');
    x{i} = data{i}.x_data;
    y{i} = data{i}.y_data;
    area{i} = data{i}.area;
end
close(f)

x = vertcat(x{:});
y = vertcat(y{:});
area = vertcat(area{:});

data_to_unique(:,1) = x;
data_to_unique(:,2) = y;
data_to_unique(:,3) = area;
data_to_unique = unique(data_to_unique,'rows'); 

piled_data{1}.x_data = data_to_unique(:,1);
piled_data{1}.y_data = data_to_unique(:,2);
piled_data{1}.area = data_to_unique(:,3);
piled_data{1}.name = [data{1}.name,'_piled'];
piled_data{1}.type = 'loc_list';

loc_list_plot(piled_data)
end