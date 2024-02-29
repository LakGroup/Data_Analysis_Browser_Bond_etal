function loc_list_voronoi_plot(data)
answer = inputdlg({'Down Sample Size:'},'Input',[1 50],{'100000'});
if isempty(answer)~=1
    down_sample_size = str2double(answer{1});
    x = data.x_data;
    y = data.y_data;
    
    data_to_unique(:,1) = x;
    data_to_unique(:,2) = y;
    data_to_unique = unique(data_to_unique,'rows');
    x = data_to_unique(:,1);
    y = data_to_unique(:,2); 
    
    if length(x)>down_sample_size
        vec = 1:length(x);
        vec = vec(randperm(length(vec)));
        I = vec(1:down_sample_size);
        x = x(I);
        y = y(I);
    end
    
    f = waitbar(0,'Constructing Delauny Tirangle');
    dt = delaunayTriangulation(x,y);
    
    waitbar(0.2,f,'Finding Vertices and Connections');
    [vertices,connections] = voronoiDiagram(dt);    
    
    waitbar(0.4,f,'Finding Faces');
    max_connections = max(cellfun(@(x) length(x), connections));
    faces = NaN(length(connections),max_connections);
    for i = 1:length(connections)
        faces(i,1:length(connections{i})) = connections{i};
    end
    
    waitbar(0.8,f,'Plotting Voronoi Polygons');
    figure()
    set(gcf,'name','Voronoi Plot','NumberTitle','off','color','k','units','normalized','position',[0.25 0.15 0.5 0.7]);
    
    subplot = @(m,n,p) subtightplot (m, n, p, [0 0], [0 0], [0 0]);  
    subplot(1,1,1)
    uimenu('Text','Save Image High Quality','ForegroundColor','b','CallBack',@save_image);
    
    hold on
    patch('Vertices',vertices,'Faces',faces,'FaceColor','b','edgecolor','k')
    set(gca,'color','k','box','on','BoxStyle','full');
    xlim([min(x) max(x)])
    ylim([min(y) max(y)])
    pbaspect([1 1 1])   
    axis off
    waitbar(1,f,'Plotting Voronoi Polygons');
    close(f)
end

    function save_image(~,~,~)
        get_capture_from_figure()
    end
end