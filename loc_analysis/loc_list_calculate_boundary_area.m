function [poly_area,boundary_points] = loc_list_calculate_boundary_area(x,y)
try
    k = boundary(x,y);
    boundary_points(:,1) = x(k);
    boundary_points(:,2) = y(k);
    poly_area = polyarea(boundary_points(:,1),boundary_points(:,2));
catch
    poly_area = 0;
    boundary_points = [];
end
end