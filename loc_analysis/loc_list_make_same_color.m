function data = loc_list_make_same_color(data)
f=waitbar(0,'Changing Coloe Value');
for i=1:length(data)
    data{i}.area = 0.7*ones(length(data{i}.x_data),1);
    waitbar(i/length(data),f,'Changing Coloe Value');
end
close(f)
loc_list_plot(data)
end