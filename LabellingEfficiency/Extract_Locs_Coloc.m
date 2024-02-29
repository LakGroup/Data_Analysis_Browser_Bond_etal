function data_coloc_inside = Extract_Locs_Coloc(RefData,ColocData)

% Create a waitbar.
wb = waitbar(0,'Transforming the reference clusters into polyshapes...                   ');

% Make polygons of the reference clusters.
IdxBoundary = cellfun(@(x) boundary(x(:,2:3),1),RefData,'UniformOutput',false);
BoundaryCoords = cellfun(@(x,y) x(y,2:3),RefData,IdxBoundary,'UniformOutput',false);
warning('off','all')
PolygonsRefs = cellfun(@(x) polyshape(x),BoundaryCoords,'UniformOutput',false);
warning('on','all')

% Update the waitbar.
waitbar(0.5,wb,'Extracting the data of the coloc channel within the reference clusters...');

% Check which coloc data points are inside the reference clusters.
IsInsideCluster = cellfun(@(x) inpolygon(ColocData(:,2),ColocData(:,3),x.Vertices(:,1),x.Vertices(:,2)),PolygonsRefs,'UniformOutput',false);
data_coloc_inside = cellfun(@(x) ColocData(x,:),IsInsideCluster,'UniformOutput',false);

% Update the waitbar.
waitbar(1,wb,'Data extraction done...');
close(wb)

end