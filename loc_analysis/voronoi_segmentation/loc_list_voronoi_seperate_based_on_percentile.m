function [data_above,data_below] = loc_list_voronoi_seperate_based_on_percentile(data)
answer = inputdlg({'Voronoi Area Percentile Value (%):'},'Input',[1 50],{'40'});
if isempty(answer)~=1
    percentile = str2double(answer{1});
    for i = 1:length(data)        
        threshold_val = prctile(data{i}.vor.voronoi_areas,percentile);
        I_below = data{i}.vor.voronoi_areas<threshold_val;
        I_above = data{i}.vor.voronoi_areas>=threshold_val;
        data_below{i}.x_data = data{i}.vor.points(I_below,1);        
        data_below{i}.y_data = data{i}.vor.points(I_below,2);
        data_below{i}.area = 0.7*ones(length(data_below{i}.x_data),1);
        data_below{i}.name = [data{i}.name,'_seperate_locs_based_on_vor_area_percentile_below_',num2str(percentile)];
        data_below{i}.type = 'loc_list';
        
        data_above{i}.x_data = data{i}.vor.points(I_above,1);        
        data_above{i}.y_data = data{i}.vor.points(I_above,2); 
        data_above{i}.area = 0.7*ones(length(data_above{i}.x_data),1);
        data_above{i}.name = [data{i}.name,'_seperate_locs_based_on_vor_area_percentile_above_',num2str(percentile)];
        data_above{i}.type = 'loc_list';
        clear I_below I_above percentile_val
    end
    loc_list_plot(data_below)
    loc_list_plot(data_above)
end
end