function send_data_to_workspace(data_to_send)
global data listbox

if ~isrow(data_to_send)
    data_to_send = data_to_send';
end
if ~isrow(data)
    data = data';
end

if isempty(data)==1
    data=data_to_send;    
else
    data = horzcat(data,data_to_send);
end

if isempty(data)==1
    listbox.String = 'NaN';
else
    for i=1:length(data)
        names{i} = data{i}.name;
    end
    listbox.String = names;
end
end