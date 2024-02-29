function parameters = loc_list_extract_parameters(data)
area = unique(data(:,3));
[~,data] = pca(data(:,1:2));
major_axis_length = max(data(:,1))-min(data(:,1));
minor_axis_length = max(data(:,2))-min(data(:,2));

x_r = data(data(:,1)>=0,:);
x_l = data(data(:,1)<=0,:);
u_r = x_r(x_r(:,2)>=0,:);
l_r = x_r(x_r(:,2)<=0,:);
u_l = x_l(x_l(:,2)>=0,:);
l_l = x_l(x_l(:,2)<=0,:);
n_u_r = size(u_r,1);
n_u_l = size(u_l,1);
n_l_r = size(l_r,1);
n_l_l = size(l_l,1);

parameters(1,1) = size(data,1);
parameters(1,2) = area;
parameters(1,3) = n_u_r;
parameters(1,4) = n_u_l;
parameters(1,5) = n_l_r;
parameters(1,6) = n_l_l;
parameters(1,7) = max([major_axis_length,minor_axis_length]);
parameters(1,8) = min([major_axis_length,minor_axis_length]);
end