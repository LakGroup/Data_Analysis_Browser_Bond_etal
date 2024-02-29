function loc_list_voronoi_plot(data)
answer = inputdlg({'Maximum Number of Localizations for Down Sampling'},'Input',1,{'1000'});
if isempty(answer)~=1
    num_points = str2double(answer{1});
    m = length(data.x_data);
    xy(:,1) = data.x_data;
    xy(:,2) = data.y_data;
    if m>num_points
        xy = datasample(xy,num_points);
    end
    xy = unique(xy,'rows');
    if size(xy,1)>2
        vor = loc_list_construct_voronoi_structure(xy(:,1),xy(:,2));
        plot_voronoi(vor,data.name)
    end
end
end

function plot_voronoi(vor,name)
voronoi_cells = vor.voronoi_cells;
voronoi_areas = vor.voronoi_areas;
figure()
set(gcf,'name','Voronoi Cells and Areas','NumberTitle','off','color','w','units','normalized','position',[0.3 0.2 0.4 0.6])
hold on
for i = 1:length(voronoi_cells)
    fill(voronoi_cells{i}(:,1),voronoi_cells{i}(:,2),log10(voronoi_areas(i)))
end
x = vor.points(:,1);
y = vor.points(:,2);
scatter(x,y,1,'b','filled')
colormap(hot)
x_lim = [min(x) max(x)];
y_lim = [min(y) max(y)];
xlim(x_lim)
ylim(y_lim)
axis off
colorbar
pbaspect([1,1,1])
title({'',['File Name: ',regexprep(name,'_',' ')]},'color','k','interpreter','latex','fontsize',14)
end