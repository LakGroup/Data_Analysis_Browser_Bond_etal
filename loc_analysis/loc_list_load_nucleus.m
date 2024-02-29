function loc_list_load_nucleus(data)

[file,path] = uigetfile('*.xlsx','Please select the file in which the coordinates are saved'); % Extract the name of the file given.
name = fullfile(path,file); % Make it a full name to save it as later.

coords = readtable(name);

Idx = find(isnan(table2array(coords(:,1))));

if numel(Idx) ~= size(data,2)-1
    msgbox('The number of saved coordinates is not the same as the number of data sets you visualized.')
else
    Idx = vertcat(0,Idx,size(coords,1));
    for i = 1:numel(Idx)-1
        coords_file{i} = table2array(coords(Idx(i)+1:Idx(i+1)-1,2:3));
    end
    
    for i = 1:size(data,2)
        data{i}.coordinates = {coords_file{i}};
        data{i}.name = [data{i}.name '_nuc'];
    end
    
    loc_list_plot(data);
end
end