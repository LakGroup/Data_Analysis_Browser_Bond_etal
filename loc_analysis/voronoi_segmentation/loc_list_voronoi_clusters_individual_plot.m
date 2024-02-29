function loc_list_voronoi_clusters_individual_plot(data)
figure()
set(gcf,'name','Voronoi Segmentation Clusters','NumberTitle','off','color','w','units','normalized','position',[0.3 0.2 0.4 0.55],'menubar','none')
set(1,'defaultfiguretoolbar','figure');

if length(data)>1
    slider_step=[1/(length(data)-1),1];
    slider_one = uicontrol('style','slider','units','normalized','position',[0,0,0.04,1],'value',1,'min',1,'max',length(data),'sliderstep',slider_step,'Callback',{@sld_one_callback});
end
slider_one_value=1;

if length(data{slider_one_value}.clusters_voronoi_cells)>1
    slider_step_two=[1/(length(data{slider_one_value}.clusters_voronoi_cells)-1),1];
    slider_two = uicontrol('style','slider','units','normalized','position',[0.04,0,0.96,0.06],'value',1,'min',1,'max',length(data{slider_one_value}.clusters_voronoi_cells),'sliderstep',slider_step_two,'Callback',{@sld_two_callback});
end
slider_two_value=1;
plot_inside(data{slider_one_value}.clusters_voronoi_cells{slider_two_value},data{slider_one_value}.clusters_voronoi_areas{slider_two_value},data{slider_one_value}.clusters_no_of_locs(slider_two_value),data{slider_one_value}.clusters_areas(slider_two_value),slider_two_value,length(data{slider_one_value}.clusters_voronoi_cells),data{slider_one_value}.name)

    function sld_one_callback(~,~,~)
        slider_one_value = round(slider_one.Value);
        if length(data{slider_one_value}.clusters_voronoi_cells)>1
            slider_two.SliderStep = [1/(length(data{slider_one_value}.clusters_voronoi_cells)-1),1];
            slider_two.Max = length(data{slider_one_value}.clusters_voronoi_cells);
            slider_two.Min = 1;
            slider_two.Value = 1;
        end
        slider_two_value = 1;
        plot_inside(data{slider_one_value}.clusters_voronoi_cells{slider_two_value},data{slider_one_value}.clusters_voronoi_areas{slider_two_value},data{slider_one_value}.clusters_no_of_locs(slider_two_value),data{slider_one_value}.clusters_areas(slider_two_value),slider_two_value,length(data{slider_one_value}.clusters_voronoi_cells),data{slider_one_value}.name)
    end

    function sld_two_callback(~,~,~)
        slider_two_value = round(slider_two.Value);
        plot_inside(data{slider_one_value}.clusters_voronoi_cells{slider_two_value},data{slider_one_value}.clusters_voronoi_areas{slider_two_value},data{slider_one_value}.clusters_no_of_locs(slider_two_value),data{slider_one_value}.clusters_areas(slider_two_value),slider_two_value,length(data{slider_one_value}.clusters_voronoi_cells),data{slider_one_value}.name)
    end


    function plot_inside(voronoi_cells,voronoi_cells_areas,no_of_locs,areas,slider_two_value,number_of_clusters,name)
        ax = gca; cla(ax);
        hold on
        for i = 1:length(voronoi_cells)
            fill(voronoi_cells{i}(:,1),voronoi_cells{i}(:,2),voronoi_cells_areas(i));
        end        
        colorbar
        pbaspect([1,1,1])
        axis off
        title({'',['File Name: ',regexprep(name,'_',' ')],['Cluster ',num2str(slider_two_value),'/',num2str(number_of_clusters)],['Total Area = ',num2str(areas)],['Number of Cells =',num2str(no_of_locs)]},'interpreter','latex','fontsize',18)
    end
end