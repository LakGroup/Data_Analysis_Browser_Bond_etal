function loc_list_density_plot_voronoi_areas(data)
answer = inputdlg({'Maximum Number of Localizations for Down Sampling:'},'Input',[1 50],{'1000'});
if isempty(answer)~=1
    num_points = str2double(answer{1});
    f=waitbar(0,'Please wait...');
    voronoi_data = cell(1,length(data));
    for i=1:length(data)
        voronoi_data{i} = loc_list_density_plot_voronoi_areas_inside(data{i},num_points);
        waitbar(i/length(data),f,'Please wait...');
    end
    close(f)
    loc_list_plot(voronoi_data)
end
end

function voronoi_data = loc_list_density_plot_voronoi_areas_inside(data,num_points)
m = length(data.x_data);
xy(:,1) = data.x_data;
xy(:,2) = data.y_data;
if m>num_points
    xy = datasample(xy,num_points);
end
xy = unique(xy,'rows');
voronoi_data.x_data = xy(:,1);
voronoi_data.y_data = xy(:,2);
voronoi_data.name = [data.name,'_density_plot_voronoi_areas'];
voronoi_data.color = calculate_voronoi_area(xy);
voronoi_data.area = zeros(length(voronoi_data.color),1);
voronoi_data.type = 'loc_list';
end

function voronoi_areas = calculate_voronoi_area(xy)
[vertices,connections] = voronoin([xy(:,1),xy(:,2)]);
cells =  cellfun(@(x) vertices(x,:),connections,'UniformOutput',false);
voronoi_areas = cell2mat(cellfun(@(x) abs(sum( (x([2:end 1],1) - x(:,1)).*(x([2:end 2],2) + x(:,2)))*0.5),cells,'UniformOutput',false));
voronoi_areas(isnan(voronoi_areas)) = Inf;
voronoi_areas = voronoi_areas./(voronoi_areas+1);
voronoi_areas(isnan(voronoi_areas)) = 1;
end