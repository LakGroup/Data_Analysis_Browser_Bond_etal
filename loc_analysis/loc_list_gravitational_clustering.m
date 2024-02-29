function data_bundle = loc_list_gravitational_clustering(data)
answer = inputdlg({'Enter Search Radius:','Number of Clusters:'},'Input',[1 50],{'0.001','50'});
if isempty(answer)~=1
    gamma = str2double(answer{1});
    k = str2double(answer{2});
    for i=1:length(data)
        data_bundle{i} = loc_list_grvitational_clusterin_inside(data{i},gamma,k);
    end
else
    data_bundle = [];
end
end

function data_clustered = loc_list_grvitational_clusterin_inside(data,gamma,k)
r = [data.x_data,data.y_data];

idx = gravitation_algorithm(r,gamma,k);

[clusters,~] = loc_list_clusters(r,idx);

clusters = vertcat(clusters{:});
data_clustered.x_data = clusters(:,1);
data_clustered.y_data = clusters(:,2);
data_clustered.area = clusters(:,3);
data_clustered.name = [data.name,'_bundle_locs'];
data_clustered.type = data.type;
end

function labels = gravitation_algorithm(r,gamma,k)
number_of_points = size(r,1);
m = ones(size(r,1),1);
labels = num2cell(1:number_of_points);
epsilon = 2*gamma;
x_lim = [min(r(:,1)) max(r(:,1))];
y_lim = [min(r(:,2)) max(r(:,2))];
counter = 0;


figure();
set(gcf,'name','Gravitational Clustering','NumberTitle','off','color','w','units','normalized','position',[0.3 0.15 0.4 0.7],'menubar','none','toolbar','none');

while size(r,1)>k
    counter = counter+1;
    index = find_nearest_points(r,epsilon);
    if isempty(index)~=1
        [r,m,labels] = replace_nearest_points(r,m,labels,index);
    end
    
    if size(r,1)>1
        f = gravity(r,m,50);
        a = f./m;        
        a_norm = calculate_norm_vector(a);        
        [~,I] = max(a_norm);
        dt = find_dt(a(I,:),gamma);
        r = 0.5*a.*dt^2+r;          
        
    end
    
    clustering_time(counter) = dt; 
    number_of_frames(counter) = counter;
    number_of_clusters(counter) = size(r,1);    
    
    ax = gca;cla(ax);
    scatter(r(:,1),r(:,2),m,'m','filled','MarkerFaceAlpha',0.6)
    pbaspect([1 1 1])
    xlim(x_lim)
    ylim(y_lim)
    set(gca,'color',[0.1 0.1 0.1]);
    axis equal
    axis off
    drawnow
end

figure();
set(gcf,'name','Gravity Simulation','NumberTitle','off','color','w','units','normalized','position',[0.5 0.42 0.3 0.4]);
plot(number_of_frames,clustering_time,'b')
xlabel('Frame Number','interpreter','latex','fontsize',14)
ylabel('dt','interpreter','latex','fontsize',14)
xlim([1 max(number_of_frames)])
pbaspect([1 1 1])
set(gca,'color','w','TickDir','out','box','on','BoxStyle','full','XColor','k','YColor','k','TickLabelInterpreter','latex','fontsize',14);

figure();
set(gcf,'name','Gravity Simulation','NumberTitle','off','color','w','units','normalized','position',[0.5 0.42 0.3 0.4]);
plot(number_of_frames,number_of_clusters,'b')
pbaspect([1 1 1])
xlabel('Frame Number','interpreter','latex','fontsize',14)
ylabel('Number of Clusters','interpreter','latex','fontsize',14)
xlim([1 max(number_of_frames)])
set(gca,'color','w','TickDir','out','box','on','BoxStyle','full','XColor','k','YColor','k','TickLabelInterpreter','latex','fontsize',14);
end

function [r,m,labels] = replace_nearest_points(r,m,labels,index)
all_idx = horzcat(index{:});
not_in_bundle = setdiff(1:size(r,1),all_idx);
for i = 1:length(index)
    test = labels(index{i});
    replaced_labels{i} = horzcat(test{:});
    replaced_r(i,:) = sum(m(index{i}).*r(index{i},:))./sum(m(index{i}));
    replaced_m(i,1) = sum(m(index{i}));  
    clear test
end
r = [r(not_in_bundle,:);replaced_r];
m = [m(not_in_bundle);replaced_m];
labels = horzcat(labels(not_in_bundle),replaced_labels);
end

function force = gravity(r,m,N)
idx = knnsearch(r,r,'k',N);
for i = 1:size(r,1)    
    force(i,:) = calculate_gravitational_force(r(idx(i,:),:),m(idx(i,:)));
end
    function sum_force = calculate_gravitational_force(r,m)
        r = r-r(1,:);
        r(1,:) = [];
        M = m(1);
        m(1) = [];
        distance = vecnorm(r')';
        f = (M.*m)./(distance.^2);
        r_norm = r./distance;
        force_vector = r_norm.*f;
        sum_force = sum(force_vector,1);
    end
end

function t = find_dt(a,gamma)
opts = optimset('Display','off');
fgfit=@(t) calculate_norm_g(t,a)-gamma;
lb=0;
ub=10;
t0 = 1;
t = lsqnonlin(fgfit,t0,lb,ub,opts);
end

function g_norm = calculate_norm_g(t,a)
g = 0.5*a.*(t.^2);
g_norm = calculate_norm_vector(g);
end

function vec_norm = calculate_norm_vector(vec)
vec_norm = vecnorm(vec')';
end

function index = find_nearest_points(r,epsilon)
neighbors = rangesearch(r,r,epsilon);
for i = 1:length(neighbors)
    if length(neighbors{i})==1
        neighbors{i}(1) = [];
    end
end

index =[];
counter = 0;
used_points = zeros(length(neighbors),1);
if isempty(neighbors)~=1    
    for i =1:length(neighbors)
        if ~used_points(i)
            seed = neighbors{i};
            if ~isempty(seed)
                size_one = 0;
                size_two = length(seed);
                while size_two~=size_one
                    size_one = length(seed);
                    idx = neighbors(seed);
                    idx = horzcat(idx{:});
                    idx = unique(idx);
                    if ~any(intersect(idx,seed))
                        seed = sort([idx;seed]);
                    else
                        seed = idx;
                    end
                    size_two = length(seed);
                end
                used_points(seed) = 1;
                counter = counter+1;
                index{counter,1} = seed;
            end
        end
    end
end
end

function [clusters,boundary] = loc_list_clusters(r,idx)
for i = 1:length(idx)    
    x = r(idx{i},1);
    y = r(idx{i},2);    
    clusters{i}(:,1) = x;
    clusters{i}(:,2) = y;
    [area,boundary_points] = loc_list_calculate_boundary_area(x,y);
    clusters{i}(:,3) = area;
    boundary{i} = boundary_points;
    clear x y area boundary_points
end
end