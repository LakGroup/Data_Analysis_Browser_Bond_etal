function clusters = loc_list_find_clusters(data,idx)
idx_unique = unique(idx);
clusters = cell(length(idx_unique),1);
%boundary = cell(length(idx_unique),1);
for i = 1:length(idx_unique)
    I = idx == idx_unique(i);
    x = data(I,1);
    y = data(I,2);    
    clusters{i}(:,1) = x;
    clusters{i}(:,2) = y;
    [area,~] = loc_list_calculate_boundary_area(x,y);
    clusters{i}(:,3) = area;
    %boundary{i} = boundary_points;
    clear I x y area 
end
end