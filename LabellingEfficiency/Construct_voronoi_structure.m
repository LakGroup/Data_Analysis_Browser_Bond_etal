function vor = Construct_voronoi_structure(data)

% Check for double entries and remove them when needed.
[~,Idx] = unique(data(:,2:3),'rows','legacy');
data = data(Idx,:);

% Do the Delaunay triangulation.
wb = waitbar(0,'Constructing Delauny Triangles...');
dt = delaunayTriangulation(data(:,2),data(:,3));

% Construct the Voronoi diagram.
waitbar(0.2,wb,'Finding Vertices and Connections...');
[vertices,connections] = voronoiDiagram(dt);

% Construct each Voronoi polygon
waitbar(0.4,wb,'Finding Voronoi polygons...');
voronoi_polygon = cellfun(@(x) vertices(x,:),connections,'UniformOutput',false);

% Calculate the area of each Voronoi polygon.
waitbar(0.6,wb,'Calculating Voronoi Areas...');
voronoi_areas = cellfun(@(x) polyarea(x(:,1),x(:,2)),voronoi_polygon);
voronoi_areas(isinf(voronoi_areas)) = NaN;

% Finding the indices of the neighboring Voronoi polygons and their
% connectivity.
waitbar(0.8,wb,'Finding Voronoi Neighbors...');
connectivity_list = dt.ConnectivityList;
attached_triangles = vertexAttachments(dt);
neighbors = cellfun(@(x) connectivity_list(x,:),attached_triangles,'UniformOutput',false);
neighbors = cellfun(@(x) unique(x),neighbors,'uniformoutput',false);

% Remove their own connections.
for i = 1:length(neighbors)
    neighbors{i}(neighbors{i}==i) = [];
end

% Saving the needed variables in the output.
waitbar(1,wb,'Assigning data to output...');
vor.neighbors = neighbors;
vor.area = voronoi_areas;
vor.points = data;

% Close the waitbar.
close(wb)

end