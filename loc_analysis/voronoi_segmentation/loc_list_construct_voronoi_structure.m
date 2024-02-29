function vor = loc_list_construct_voronoi_structure(x,y,counter)
data_to_unique(:,1) = x;
data_to_unique(:,2) = y;
data_to_unique = unique(data_to_unique,'rows');
x = data_to_unique(:,1);
y = data_to_unique(:,2);

f = waitbar(0,['Constructing Delauny Tirangle...',num2str(counter(1)),'/',num2str(counter(2))]);
dt = delaunayTriangulation(x,y);

waitbar(0.2,f,['Finding Vertices and Connections...',num2str(counter(1)),'/',num2str(counter(2))]);
[vertices,connections] = voronoiDiagram(dt);

waitbar(0.4,f,['Finding Voronoi Cells...',num2str(counter(1)),'/',num2str(counter(2))]);
voronoi_cells = cellfun(@(x) vertices(x,:),connections,'UniformOutput',false);

waitbar(0.6,f,['Calculating Voronoi Areas...',num2str(counter(1)),'/',num2str(counter(2))]);
voronoi_areas = cellfun(@(x) polyarea(x(:,1),x(:,2)),voronoi_cells,'UniformOutput',false);
%voronoi_areas = cellfun(@(x) abs(sum( (x([2:end 1],1) - x(:,1)).*(x([2:end 2],2) + x(:,2)))*0.5),voronoi_cells,'UniformOutput',false);
idx = cell2mat(cellfun(@(x) isnan(x) | x == Inf,voronoi_areas,'UniformOutput',false));
voronoi_areas(idx) = {nan};

waitbar(0.8,f,['Finding Voronoi Neighbors...',num2str(counter(1)),'/',num2str(counter(2))]);
connectivity_list = dt.ConnectivityList;
attached_triangles = vertexAttachments(dt);
neighbors = cellfun(@(x) connectivity_list(x,:),attached_triangles,'UniformOutput',false);
neighbors = cellfun(@(x) unique(x),neighbors,'uniformoutput',false);

for i = 1:length(neighbors)
    neighbors{i}(neighbors{i}==i) = [];
end

waitbar(0.9,f,['Finding Voronoi Neighbors...',num2str(counter(1)),'/',num2str(counter(2))]);
vor.neighbors = neighbors;
%vor.voronoi_cells = voronoi_cells;
vor.voronoi_areas = cell2mat(voronoi_areas);
vor.points = [x,y];
close(f)
end