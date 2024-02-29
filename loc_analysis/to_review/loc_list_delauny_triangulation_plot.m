function loc_list_delauny_triangulation_plot(data)
answer = inputdlg({'maximum number of localizations for down sampling'},'Input',1,{'1000'});
if isempty(answer)~=1
    num_points = str2double(answer{1});
    m = length(data.x_data);
    data_sample(:,1) = data.x_data;
    data_sample(:,2) = data.y_data;
    if m>num_points
        data_sample = datasample(data_sample,num_points);
    end
    data_sample = unique(data_sample,'rows');
    if size(data_sample,1)>2
        tri_plot(data_sample(:,1),data_sample(:,2),data.name)
    end
end
end

function tri_plot(x,y,name)
figure()
set(gcf,'name','tri-plot','NumberTitle','off','color','w','units','normalized','position',[0.3 0.2 0.4 0.6])

delauny_triangulation = delaunayTriangulation(x,y);
connectivity_list = delauny_triangulation.ConnectivityList;
attached_triangles = vertexAttachments(delauny_triangulation);

disp('calculating delauny areas')
xx = x(connectivity_list)';
yy = y(connectivity_list)';
delauny_area = abs(sum( (xx([2:end 1],:) - xx).*(yy([2:end 1],:) + yy))*0.5);

disp('calculating zeroth rank areas')
voronoi_area_zeroth_rank = cellfun(@(x) delauny_area(x),attached_triangles,'UniformOutput',false);
voronoi_area_zeroth_rank = cellfun(@sum,voronoi_area_zeroth_rank);

% disp('calculating first rank areas')
% neighbors = cellfun(@(x) connectivity_list(x,:),attached_triangles,'UniformOutput',false);
% neighbors = cellfun(@(x) unique(x),neighbors,'uniformoutput',false);
% voronoi_area_first_rank = cellfun(@(x) voronoi_area_zeroth_rank(x),neighbors,'UniformOutput',false);
% voronoi_area_first_rank = cellfun(@sum,voronoi_area_first_rank);

if length(attached_triangles)>1
    slider_step=[1/(length(attached_triangles)-1),1];
    uicontrol('style','slider','units','normalized','position',[0,0,0.03,1],'value',1,'min',1,'max',length(attached_triangles),'sliderstep',slider_step,'Callback',{@sld_callback});
end
slider_value=1;
slider_plot_inside(attached_triangles,slider_value)

    function sld_callback(hobj,~,~)
        slider_value = round(get(hobj,'Value'));
        slider_plot_inside(attached_triangles,slider_value)
    end

    function slider_plot_inside(data_one,slider_value)
        ax = gca; cla(ax);  
        hold on
        triplot(delauny_triangulation)                
        triplot(delauny_triangulation(data_one{slider_value},:),x,y,'Color','r') 
        scatter(x(slider_value),y(slider_value),50,'b','filled')
        set(gca,'TickDir','out','box','on','BoxStyle','full','TickLabelInterpreter','latex','fontsize',12)
        axis equal
        title({'',['File Name: ',regexprep(name,'_',' ')],['Area=',num2str(voronoi_area_zeroth_rank(slider_value))],['Localization: ',num2str(slider_value),'/',num2str(length(data_one))]},'color','k','interpreter','latex','fontsize',14)
        %title({'',['zeroth rank area=',num2str(voronoi_area_zeroth_rank(slider_value))],['first rank area=',num2str(voronoi_area_first_rank(slider_value))],['localization: ',num2str(slider_value),'/',num2str(length(data_one))]},'color','k','interpreter','latex','fontsize',14)
    end
end