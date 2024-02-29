function loc_list_voronoi_clusters_boundary_points_plot(data)
figure()
set(gcf,'name','Voronoi Segmentation Clusters','NumberTitle','off','color','w','units','normalized','position',[0.3 0.2 0.4 0.55],'menubar','none')
set(1,'defaultfiguretoolbar','figure');

if length(data)>1
    slider_step=[1/(length(data)-1),1];
    slider = uicontrol('style','slider','units','normalized','position',[0,0,1,0.05],'value',1,'min',1,'max',length(data),'sliderstep',slider_step,'Callback',{@sld_callback});
end
slider_value=1;
voronoi_segmentation_clusters_plot_inside(data{slider_value})

    function sld_callback(~,~,~)
        slider_value =  round(slider.Value);
        voronoi_segmentation_clusters_plot_inside(data{slider_value})
    end

    function voronoi_segmentation_clusters_plot_inside(data)
        ax = gca; cla(ax);
        boundary_points = data.clusters_boundary_points;
        x = data.points(:,1);
        y = data.points(:,2);
        scatter(x,y,1,'b','filled')
        hold on
        for i = 1:length(boundary_points)
            plot(boundary_points{i}(:,1),boundary_points{i}(:,2),'color','r');            
        end
        title({'',['Total Number of Clusters = ',num2str(length(boundary_points))],['File Name: ',regexprep(data.name,'_',' ')]},'interpreter','latex','fontsize',18)
        axis equal
        axis off
        x_lim = [min(x) max(x)];
        y_lim = [min(y) max(y)];
        xlim(x_lim)
        ylim(y_lim)        
    end
end