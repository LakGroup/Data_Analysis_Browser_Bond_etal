function spt_filter_tracks(data)
input_values = inputdlg({'minimum number of frames','maximum number of frames'},'',1,{'5','20'});
if isempty(input_values)==1
    return
else
    cutoff_min = str2double(input_values{1});
    cutoff_max = str2double(input_values{2});
    for i = 1:length(data)        
        for j=1:length(data{i}.tracks)
            if length(data{i}.tracks{j})<cutoff_min || length(data{i}.tracks{j})>cutoff_max
                data{i}.tracks{j} = [];
                data{i}.msd{j} = [];
            end
        end
        data{i}.tracks = data{i}.tracks(~cellfun('isempty',data{i}.tracks));
        data{i}.msd = data{i}.msd(~cellfun('isempty',data{i}.msd));        
        data{i}.name = [data{i}.name '_filtered'];
    end    
    spt_plot(data);
end
end