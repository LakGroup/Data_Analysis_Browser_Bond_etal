function loc_list_filter_no_of_locs(data)
answer = inputdlg({'Enter minimum number of localizations:'},'Input',[1 50],{'1000'});
if isempty(answer)~=1
    min_loc = str2double(answer{1});
    for i = 1:length(data)
        if length(data{i}.x_data)>=min_loc
            data_above(i) = i;
        else
            data_below(i) = i;
        end
    end
    if exist('data_above','var')
        data_above(data_above==0) = [];
        data_above = data(data_above);
        loc_list_plot(data_above)
    end
    if exist('data_below','var')
        data_below(data_below==0) = [];
        data_below = data(data_below);
        loc_list_plot(data_below)
    end
end
end