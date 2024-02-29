function data_simulated = loc_list_storm_image_simulation()
input_values = inputdlg({'clusters density (um^-2):','clusters radius (nm):','clusters localizations density (um^-2):','background density (um^-2):','connections density (um^-2):','connections distance (um):','connections probability [0 1]:','image size (um):'},'',1,{'10','40','1000','100','100','1','0.3','10'});
if isempty(input_values)==1
    data_simulated = [];
else
    p_clusters = str2double(input_values{1});
    R_clusters = str2double(input_values{2});
    p_clusters_localizations = str2double(input_values{3});
    p_noise = str2double(input_values{4});
    p_connenctions = str2double(input_values{5});   
    distance_connections = str2double(input_values{6});
    probability_connection = str2double(input_values{7});
    image_length = str2double(input_values{8});
    storm_data = SMLM_cluster_simulation(p_clusters_localizations,p_clusters,p_connenctions,probability_connection,p_noise,R_clusters,distance_connections,image_length);
    data_simulated{1}.x_data = storm_data(:,1)/1000;
    data_simulated{1}.y_data = storm_data(:,2)/1000;
    data_simulated{1}.area = 0.7+zeros(length(storm_data(:,1)),1);
    data_simulated{1}.name = 'storm_image_simulation';
    data_simulated{1}.type = 'loc_list';
end
end

function storm = SMLM_cluster_simulation(p_em,p_cl,p_conn,p_r,p_noise,R_cl,d_conn,image_length)
background = simulate_noise(image_length,p_noise);
[clusters,d] = simulate_cluster(p_em,R_cl,image_length,p_cl,d_conn);
connections = simulate_connections(clusters,d,p_r,R_cl,p_conn);

connections = horzcat(connections{:});
connections = vertcat(connections{:});
clusters = clusters(:,1);
clusters = vertcat(clusters{:});
% scatter(clusters(:,1),clusters(:,2),1,'r','filled')
% hold on
% scatter(connections(:,1),connections(:,2),1,'r','filled')
% scatter(background(:,1),background(:,2),1,'r','filled')
% axis equal

storm = [clusters;connections;background];
end


function noise_data =simulate_noise(image_length,p_noise)
number_of_points = round(p_noise*image_length*image_length);
noise_data = image_length*1000*rand(number_of_points,2);
end

function connection = simulate_connections(clusters,d,p_r,R_cl,p_conn)
for i = 1:length(d)
    for j = 2:length(d{i})
        if rand(1)<p_r
            connection{i}{j-1} = creat_connection(cell2mat(clusters(d{i}(1),2)),cell2mat(clusters(d{i}(j),2)),R_cl,p_conn);
        else
            connection{i}{j-1} = [];
        end
    end
end
end

function [clusters,d] = simulate_cluster(p_em,R_cl,image_length,p_cl,d_conn)
number_of_clusters = round(p_cl*image_length*image_length);
clusters_centers = image_length*1000*rand(number_of_clusters,2);
for i = 1:number_of_clusters
    clusters{i,1} = simulate__single_cluster(p_em,R_cl);
    clusters{i,1} = clusters{i}+clusters_centers(i,:);
    clusters{i,2} = clusters_centers(i,:);
end
d = rangesearch(clusters_centers,clusters_centers,d_conn*1000);
for i = 1:length(d)
    tmp = d{i};
    d{i} = tmp(tmp>=i);
    clear tmp    
end
I = cellfun(@(x) length(x),d);
I = I>1;
d = d(I);
end

function data = creat_connection(point_one,point_two,R_cl,p_conn)
distance = pdist2(point_one,point_two);
n_points = round(distance*R_cl*p_conn*10e-6);
data(1,:) = R_cl*rand(1,n_points);
data(2,:) = distance*rand(1,n_points);
data = data-mean(data,2);
data(3,:) = 0;
angle = atand((point_two(2)-point_one(2))/(point_two(1)-point_one(1)));
data = rotationmatrix(90+angle,[0 0 1])*data;
data = data(1:2,:)';
data = data+(point_two+point_one)/2;
end

function data = simulate__single_cluster(p_em,R_cl)
R_cl_deviation = 5*R_cl/100;
R_cl_rand = ((R_cl+R_cl_deviation)-(R_cl-R_cl_deviation))*rand+R_cl-R_cl_deviation;
N_em = p_em*(pi*R_cl_rand*R_cl_rand)*10e-6;
data = R_cl_rand.*rand(round(N_em),2);
data = data-mean(data);
dist = pdist2(data,[0,0]);
I = dist>R_cl_rand/2;
data(I,:) = [];
end

function RotationMatrix=rotationmatrix(Angle,Vector)
Norm=Vector./norm(Vector);
RotationMatrix=[cosd(Angle)+Norm(1,1)^2*(1-cosd(Angle)) Norm(1,1)*Norm(1,2)*(1-cosd(Angle))-Norm(1,3)*sind(Angle) Norm(1,1)*Norm(1,3)*(1-cosd(Angle))+Norm(1,2)*sind(Angle);
        Norm(1,1)*Norm(1,2)*(1-cosd(Angle))+Norm(1,3)*sind(Angle) cosd(Angle)+Norm(1,2)^2*(1-cosd(Angle)) Norm(1,2)*Norm(1,3)*(1-cosd(Angle))-Norm(1,1)*sind(Angle);
        Norm(1,1)*Norm(1,3)*(1-cosd(Angle))-Norm(1,2)*sind(Angle) Norm(1,2)*Norm(1,3)*(1-cosd(Angle))+Norm(1,1)*sind(Angle) cosd(Angle)+Norm(1,3)^2*(1-cosd(Angle))];
end
