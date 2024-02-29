function loc_list_voronoi_density_map(data)
answer = inputdlg({'Color Percentile Value:','Down Sample Size:','Pixel Size (nm per pixel):','Scale Bar Size [x-axis (um)]:','Scale Bar Size [y-axis (um)]:'},'Input',[1 50],{'1 99','100000','116','2','0.5'});
if isempty(answer)~=1
    pecentile_vals = str2num(answer{1});
    down_sample_size = str2double(answer{2});
    pixel_size = str2double(answer{3});
    scale_bar_size_x = str2double(answer{4});
    scale_bar_size_y = str2double(answer{5});
    
    x = data{1}.x_data;
    y = data{1}.y_data;
    
    data_to_unique(:,1) = x;
    data_to_unique(:,2) = y;
    data_to_unique = unique(data_to_unique,'rows');
    x = data_to_unique(:,1);
    y = data_to_unique(:,2);
    
    x = x*pixel_size;
    y = y*pixel_size;
    
    if length(x)>down_sample_size
        vec = 1:length(x);
        vec = vec(randperm(length(vec)));
        I = vec(1:down_sample_size);
        x = x(I);
        y = y(I);
    end   
    
    
    f = waitbar(0,'Calculating Voronoi Areas');
    dt = delaunayTriangulation(x,y);
    [vertices,connections] = voronoiDiagram(dt);
    voronoi_cells = cellfun(@(x) vertices(x,:),connections,'UniformOutput',false);
    voronoi_areas = cellfun(@(x) polyarea(x(:,1),x(:,2)),voronoi_cells,'UniformOutput',false);
    voronoi_areas = vertcat(voronoi_areas{:});
%     points(:,1) = x;
%     points(:,2) = y;
%     [voronoi_areas,vertices,connections] = run_python_va(points);
%     voronoi_areas = voronoi_areas';
%     connections = connections';
%     voronoi_areas(voronoi_areas==Inf) = NaN;
%     voronoi_areas(isnan(voronoi_areas)) = 1.2*max(voronoi_areas);    
    waitbar(0.5,f,'Calculating Voronoi Areas'); 
    
    voronoi_areas_log = log10(voronoi_areas);
    min_val = prctile(voronoi_areas_log,pecentile_vals(1));
    max_val = prctile(voronoi_areas_log,pecentile_vals(2));        
    idx = voronoi_areas_log>=min_val & voronoi_areas_log<=max_val;    
    connections = connections(idx);    
    voronoi_areas_log = voronoi_areas_log(idx);    
    
    max_connections = max(cellfun(@(x) length(x), connections));
    faces = NaN(length(connections),max_connections);
    for i = 1:length(connections)
        faces(i,1:length(connections{i})) = connections{i};
    end
    
    waitbar(0.8,f,'Plotting Voronoi Polygons');
    figure()
    set(gcf,'name','Voronoi Area Density Plot','NumberTitle','off','color','k','units','normalized','position',[0.25 0.15 0.5 0.7]);
   
    subplot = @(m,n,p) subtightplot (m, n, p, [0 0], [0 0], [0 0]);    
    subplot(1,1,1)
    
    uimenu('Text','Save Image High Quality','ForegroundColor','b','CallBack',@save_image);
    uimenu('Text','Change Colormap Limits','ForegroundColor','b','CallBack',@change_colormap_limits);    
    
    hold on
    patch('Vertices',vertices,'Faces',faces,'FaceVertexCData',voronoi_areas_log,'FaceColor','flat','edgecolor','none')    
    h = colorbar();    
    pbaspect([1 1 1])
    h.Position = [0.9 0.1 0.02 0.8];
    h.TickLabelInterpreter = 'latex';
    h.FontSize = 14;
    h.Color = 'w';
    ylabel(h, '$Log10(Voronoi Area-nm^{2})$','FontSize',14,'interpreter','latex');
    caxis([min_val max_val])
    pixels_um_x = scale_bar_size_x*1000;
    pixels_um_y = scale_bar_size_y*1000;
    rectangle('Position',[min(x) min(y) pixels_um_x pixels_um_y],'facecolor','w')
    map = flipud(colormap(jet));
    set(gca,'colormap',map,'color','k','box','on','BoxStyle','full','XColor','k','YColor','k');
    axis equal
    xlim([min(x) max(x)])
    ylim([min(y) max(y)])    
    waitbar(1,f,'Plotting Voronoi Polygons');
    close(f)
    
    table_data_plot([x,y,voronoi_areas],[],{'x','y','voronoi areas'},'Voronoi Areas Values')
end

    function save_image(~,~,~)
        get_capture_from_figure()
    end

   function change_colormap_limits(~,~,~)
        loc_list_change_colormap_limits()
    end
end

function loc_list_change_colormap_limits()
ax = gca;
c_lim = ax.CLim;
input_values = inputdlg({'c-min:','c-max:'},'',1,{num2str(c_lim(1)),num2str(c_lim(2))});
if isempty(input_values)==1
    return
else
    clim(1)=str2double(input_values{1});
    clim(2)=str2double(input_values{2});
    caxis(clim);
end
end

function table_data_plot(data,row_names,column_names,title)
figure('name',title,'NumberTitle','off','units','normalized','position',[0 0.1 1 0.4],'ToolBar','none','MenuBar', 'none');
column_width = {200};
uitable('Data',data,'units','normalized','position',[0 0 1 1],'FontSize',12,'RowName',row_names,'ColumnName',column_names,'columnwidth',column_width);

uimenu('Text','Save Data (.mat file)','ForegroundColor','b','CallBack',@save_data);
    function save_data(~,~,~)
        [file,path] = uiputfile('*.mat');
        if path~=0            
            voronoi_data = data;          
            f = waitbar(0,'Saving...');
            save(fullfile(path,file),'voronoi_data')
            waitbar(1,f,'Saving...')
            close(f)
        end
    end
end

function [voronoi_areas,vertices,connections] = run_python_va(points)
save('temp_file.mat','points');
system('python voronoi_areas_python.py');
load('va.mat')
delete temp_file.mat
delete va.mat
end