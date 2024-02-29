function Clusters = Get_voronoi_cluster(data,Params)

% Declare the Voronoi parameters.
minArea = Params(1);
minLocs = Params(2);

% Initialize the cluster building.
keep_points = data.area <= minArea;
number_of_points = size(data.area,1);
used_points = zeros(number_of_points,1);

wb = waitbar(0,'Finding Voronoi clusters...');
idx_clustered = cell(number_of_points,1);
for i = 1:number_of_points

    % Only consider the points that are close enough to other points and
    % that haven't been included in a cluster yet.
    if keep_points(i) && ~used_points(i)

        % Update the waitbar to track progress.
        waitbar(i/number_of_points,wb,'Finding Voronoi clusters...');

        % Find the neighboring points that are close enough to the seed 
        % point (i.e. their Voronoi area is below the threshold).
        seed_neighbors = data.neighbors{i}(keep_points(data.neighbors{i}));

        % Continue to build the cluster until no new points are added
        % anymore.
        if ~isempty(seed_neighbors)

            % Initialize the starting conditions for building clusters.
            size_one = 0;
            size_two = length(seed_neighbors);

            % Find all connected neighboring points with a Voronoi area
            % above the area threshold.
            while size_two ~= size_one

                % Re-assign the cluster size.
                size_one = length(seed_neighbors);

                % Look at all neighboring points of the neighbors, and
                % select only the unique ones.
                idx_all = unique(cell2mat(data.neighbors(seed_neighbors)));

                % Check if there is any overlap and then only select the
                % ones that are above the area threshold.
                if ~any(intersect(idx_all,seed_neighbors))
                    seed_neighbors = sort([idx_all;seed_neighbors]);
                else
                    seed_neighbors = idx_all;
                end
                seed_neighbors = seed_neighbors(keep_points(seed_neighbors));
                size_two = length(seed_neighbors);
            end

        % If the seed point has no neighbours, make a 'cluster' of a single
        % point.
        else
            seed_neighbors = i;
        end

        % Keep track of which points have been used already so they do not
        % have to be checked again.
        used_points(seed_neighbors) = 1;

        % Only keep the clusters that are larger than the minimum number of
        % points included.
        if length(seed_neighbors) >= minLocs
            idx_clustered{i} = seed_neighbors;
        end
    end
end

% Remove the empty cells, and only keep the clusters that fullfil the two
% filters.
idx_clustered = idx_clustered(~cellfun(@isempty, idx_clustered));

% Assign all data to the clusters
waitbar(0,wb,'Extracting data points for each cluster...');
Clusters = cell(length(idx_clustered),1);
for i = 1:length(idx_clustered)
    waitbar(i/length(idx_clustered),wb,'Extracting data points for each cluster...');
    Clusters{i} = [data.points(idx_clustered{i},:) repmat(sum(data.area(idx_clustered{i})),[numel(idx_clustered{i}) 1])];
end

% Close the waitbar
close(wb)
end