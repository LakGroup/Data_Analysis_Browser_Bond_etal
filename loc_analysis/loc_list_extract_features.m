function data_to_send = loc_list_extract_features(data)
counter = 0;
for i = 1:length(data)
    data_to = unique(data{i}.area);
    if length(data_to)>1
        counter = counter+1;
        data_to_send{counter} = data{i};
    end
end
if exist('data_to_send','var')
    f = waitbar(0,'Please Wait...');
    for i = 1:length(data_to_send)
        clusters = loc_list_extract_clusters_from_data(data_to_send{i}); 
        I = cellfun(@size ,clusters,'UniformOutput',false);
        I = cellfun(@(x) x(1), I);
        I = I>2;
        clusters = clusters(I);
        for k = 1:length(clusters)            
            parameters(k,:) = loc_list_extract_parameters(clusters{k});            
        end
        classes = make_classes(parameters,clusters);
        data_shape.classes = classes;
        data_shape.name = [data{i}.name,'_shape_classes'];
        data_shape.type = 'shape_class';
        send_data_to_workspace(data_shape)
        clear clusters parameters data_shape
        waitbar(i/length(data_to_send),f,'Please Wait...');
    end 
    close(f)
else
    msgbox('there is only one cluster')
end
end

function classes = make_classes(parameters,clusters)
for i=1:size(parameters,1)
    classes{i,1}{1} = clusters{i}(:,1:2);
    classes{i,2} = parameters(i,:);
    if size(classes{i,2},1)>1
        classes{i,3} = mean(classes{i,2},1);
    else
        classes{i,3} = classes{i,2};
    end
    classes{i,4}{1} = 1;
end
end

% function parameters = extract_parameter_from_cluster(cluster)
% no_of_locs = size(cluster,1);
% [~,cluster] = pca(cluster);
% 
% k = boundary(cluster(:,1),cluster(:,2),1);
% boundary_points = cluster(k,:);
% 
% polygon = polyshape(boundary_points);
% 
% parameters(1,1) = no_of_locs;
% parameters(1,2) = area(polygon);
% max_r = 1.1*max(pdist2([0 0],boundary_points));
% [distance,~] = find_radius(max_r,boundary_points,10);
% parameters(1,3:12) = distance;
% end
% 
% function [distance,intersection] = find_radius(max_r,boundary_points,N)
% angles = linspace(0,2*pi,N);
% for i = 1:length(angles)
%     [xi,yi] = polyxpoly([0 max_r*cos(angles(i))],[0 max_r*sin(angles(i))],boundary_points(:,1),boundary_points(:,2));
%     if isempty(xi) || isempty(yi) ==1
%         [xi,yi] = polyxpoly([0 -max_r*cos(angles(i))],[0 -max_r*sin(angles(i))],boundary_points(:,1),boundary_points(:,2));
%         intersection(i,1) = xi(1);
%         intersection(i,2) = yi(1);
%         distance(i) = -sqrt(intersection(i,1)^2+intersection(i,2)^2);
%     else
%         intersection(i,1) = xi(end);
%         intersection(i,2) = yi(end);
%         distance(i) = sqrt(intersection(i,1)^2+intersection(i,2)^2);
%     end
%     clear xi yi
% end
% end

% function parameters = extract_parameter_from_cluster(cluster)
% no_of_locs = size(cluster,1);
% 
% [~,cluster] = pca(cluster);
% 
% major_axis_length = max(cluster(:,1))-min(cluster(:,1));
% minor_axis_length = max(cluster(:,2))-min(cluster(:,2));
% cov_xy = cov(cluster);
% aspect_1 = cov_xy(1,1);
% aspect_2 = cov_xy(2,2);
% circularity = aspect_2/aspect_1;
% 
% dist = pdist2([0 0],cluster);
% moment_of_inertia = sum(dist.^2)/no_of_locs;
% k = boundary(cluster(:,1),cluster(:,2),1);
% boundary_points = cluster(k,:);
% polygon = polyshape(boundary_points);
% poly_area = area(polygon);
% poly_perimeter = perimeter(polygon);
% 
% x_r = cluster(cluster(:,1)>=0,:);
% x_l = cluster(cluster(:,1)<=0,:);
% u_r = x_r(x_r(:,2)>=0,:);
% l_r = x_r(x_r(:,2)<=0,:);
% u_l = x_l(x_l(:,2)>=0,:);
% l_l = x_l(x_l(:,2)<=0,:);
% 
% n_u_r = size(u_r,1);
% n_u_l = size(u_l,1);
% n_l_r = size(l_r,1);
% n_l_l = size(l_l,1);
% 
% cm_u_r(1) = mean(u_r(:,1));
% cm_u_r(2) = mean(u_r(:,2));
% dist = pdist2([0 0],u_r);
% moment_of_inertia_u_r = sum(dist.^2)/n_u_r;
% k = boundary(u_r(:,1),u_r(:,2),1);
% boundary_points = u_r(k,:);
% u_r_area = polyarea(boundary_points(:,1),boundary_points(:,2));
% clear boundary_points k dist
% 
% cm_u_l(1) = mean(u_l(:,1));
% cm_u_l(2) = mean(u_l(:,2));
% dist = pdist2([0 0],u_l);
% moment_of_inertia_u_l = sum(dist.^2)/n_u_l;
% k = boundary(u_l(:,1),u_l(:,2),1);
% boundary_points = u_l(k,:);
% u_l_area = polyarea(boundary_points(:,1),boundary_points(:,2));
% clear boundary_points k dist
% 
% cm_l_r(1) = mean(l_r(:,1));
% cm_l_r(2) = mean(l_r(:,2));
% dist = pdist2([0 0],l_r);
% moment_of_inertia_l_r = sum(dist.^2)/n_l_r;
% k = boundary(l_r(:,1),l_r(:,2),1);
% boundary_points = l_r(k,:);
% l_r_area = polyarea(boundary_points(:,1),boundary_points(:,2));
% clear boundary_points k dist
% 
% cm_l_l(1) = mean(l_l(:,1));
% cm_l_l(2) = mean(l_l(:,2));
% dist = pdist2([0 0],l_l);
% moment_of_inertia_l_l = sum(dist.^2)/n_l_l;
% k = boundary(l_l(:,1),l_l(:,2),1);
% boundary_points = l_l(k,:);
% l_l_area = polyarea(boundary_points(:,1),boundary_points(:,2));
% clear boundary_points k dist
% 
% l = [u_l;l_l];
% r = [u_r;l_r];
% u = [u_l;u_r];
% d = [l_l;l_r];
% n_l = size(l,1);
% n_r = size(r,1);
% n_u = size(u,1);
% n_d = size(d,1);
% 
% cm_l(1) = mean(l(:,1));
% cm_l(2) = mean(l(:,2));
% dist = pdist2([0 0],l);
% moment_of_inertia_l = sum(dist.^2)/n_l;
% k = boundary(l(:,1),l(:,2),1);
% boundary_points = l(k,:);
% l_area = polyarea(boundary_points(:,1),boundary_points(:,2));
% clear boundary_points k dist
% 
% cm_r(1) = mean(r(:,1));
% cm_r(2) = mean(r(:,2));
% dist = pdist2([0 0],r);
% moment_of_inertia_r = sum(dist.^2)/n_r;
% k = boundary(r(:,1),r(:,2),1);
% boundary_points = r(k,:);
% r_area = polyarea(boundary_points(:,1),boundary_points(:,2));
% clear boundary_points k dist
% 
% cm_u(1) = mean(u(:,1));
% cm_u(2) = mean(u(:,2));
% dist = pdist2([0 0],u);
% moment_of_inertia_u = sum(dist.^2)/n_u;
% k = boundary(u(:,1),u(:,2),1);
% boundary_points = u(k,:);
% u_area = polyarea(boundary_points(:,1),boundary_points(:,2));
% clear boundary_points k dist
% 
% cm_d(1) = mean(d(:,1));
% cm_d(2) = mean(d(:,2));
% dist = pdist2([0 0],d);
% moment_of_inertia_d = sum(dist.^2)/n_d;
% k = boundary(d(:,1),d(:,2),1);
% boundary_points = d(k,:);
% d_area = polyarea(boundary_points(:,1),boundary_points(:,2));
% clear boundary_points k dist
% 
% parameters(1,1) = no_of_locs;
% parameters(1,2) = poly_area;
% parameters(1,3) = poly_perimeter;
% parameters(1,4) = moment_of_inertia;
% parameters(1,5) = no_of_locs/poly_area;
% 
% parameters(1,6) = n_u_r;
% parameters(1,7) = u_r_area;
% parameters(1,8) = moment_of_inertia_u_r;
% parameters(1,9) = n_u_r/u_r_area;
% parameters(1,10) = cm_u_r(1);
% parameters(1,11) = cm_u_r(2);
% 
% parameters(1,12) = n_u_l;
% parameters(1,13) = u_l_area;
% parameters(1,14) = moment_of_inertia_u_l;
% parameters(1,15) = n_u_l/u_l_area;
% parameters(1,16) = cm_u_l(1);
% parameters(1,17) = cm_u_l(2);
% 
% parameters(1,18) = n_l_r;
% parameters(1,19) = l_r_area;
% parameters(1,20) = moment_of_inertia_l_r;
% parameters(1,21) = n_l_r/l_r_area;
% parameters(1,22) = cm_l_r(1);
% parameters(1,23) = cm_l_r(2);
% 
% parameters(1,24) = n_l_l;
% parameters(1,25) = l_l_area;
% parameters(1,26) = moment_of_inertia_l_l;
% parameters(1,27) = n_l_l/l_l_area;
% parameters(1,28) = cm_l_l(1);
% parameters(1,29) = cm_l_l(2);
% 
% parameters(1,30) = major_axis_length;
% parameters(1,31) = minor_axis_length;
% parameters(1,32) = aspect_1;
% parameters(1,33) = aspect_2;
% parameters(1,34) = circularity;
% 
% parameters(1,35) = n_l;
% parameters(1,36) = l_area;
% parameters(1,37) = moment_of_inertia_l;
% parameters(1,38) = n_l/l_area;
% parameters(1,39) = cm_l(1);
% parameters(1,40) = cm_l(2);
% 
% parameters(1,41) = n_r;
% parameters(1,42) = r_area;
% parameters(1,43) = moment_of_inertia_r;
% parameters(1,44) = n_r/r_area;
% parameters(1,45) = cm_r(1);
% parameters(1,46) = cm_r(2);
% 
% parameters(1,47) = n_u;
% parameters(1,48) = u_area;
% parameters(1,49) = moment_of_inertia_u;
% parameters(1,50) = n_u/u_area;
% parameters(1,51) = cm_u(1);
% parameters(1,52) = cm_u(2);
% 
% parameters(1,53) = n_d;
% parameters(1,54) = d_area;
% parameters(1,55) = moment_of_inertia_d;
% parameters(1,56) = n_d/d_area;
% parameters(1,57) = cm_d(1);
% parameters(1,58) = cm_d(2);
% end