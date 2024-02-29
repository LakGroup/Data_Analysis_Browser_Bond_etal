function clusters = NND_cluster(clusters)
number_of_clusters = length(clusters.clusters_areas);
clusters_center = clusters.clusters_centers;
if number_of_clusters>2
    dt = delaunayTriangulation(clusters_center(:,1),clusters_center(:,2));
    connectivity_list = dt.ConnectivityList;
    attached_triangles = vertexAttachments(dt);
    neighbors = cellfun(@(x) connectivity_list(x,:),attached_triangles,'UniformOutput',false);
    neighbors = cellfun(@(x) unique(x),neighbors,'uniformoutput',false);
    for i = 1:length(neighbors)
        neighbors{i}(neighbors{i}==i) = [];
    end
end
switch number_of_clusters
    case num2cell(0:1)
        clusters.NND = [-1, -1, -1, -1];
    case 2
        for c = 1:number_of_clusters
            % set the NND as the nearest centroid-to-centroid distance
            r = sqrt((clusters_center(c,1)-clusters_center(:,1)).^2+(clusters_center(c,2)-clusters_center(:,2)).^2);
            [minNND,idx_r] = min( r(r>0) );
            clusters.NND(c,:) = [minNND, idx_r, -1, -1];
        end
    otherwise
        for c = 1:number_of_clusters
            % alternative: performa  delaunay Triangulation, then find the neighbors
            % and take an average NND over them
            r_neighbors = sqrt((clusters_center(c,1)-clusters_center(neighbors{c,1},1)).^2+(clusters_center(c,2)-clusters_center(neighbors{c,1},2)).^2);
            [minNND,idx_r] = min( r_neighbors );
            % note, this minimum result gives a double-counting since each pair of
            % closest clusters will have the same NND
            % [minimum NND, index of closest cluster, mean & median distance  to neighbors]
            clusters.NND(c,:) = [minNND, neighbors{c,1}(idx_r), mean(r_neighbors), median(r_neighbors)];
        end
end
end