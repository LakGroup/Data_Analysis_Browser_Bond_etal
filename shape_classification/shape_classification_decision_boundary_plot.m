function shape_classification_decision_boundary_plot(data)
clf(figure())
set(gcf,'name','Shape Classification Decision Boundary Plot','NumberTitle','off','color',[0.1 0.1 0.1],'units','normalized','position',[0.3 0.1 0.4 0.7],'menubar','none','toolbar','figure')

uicontrol('style','text','units','normalized','position',[0,-0.01,0.125,0.05],'string','Mass:','BackgroundColor',[0.1 0.1 0.1],'FontSize',14,'ForegroundColor','w');
mass_index_edit = uicontrol('style','edit','units','normalized','position',[0.125,0,0.125,0.04],'string','5','Callback',@mass_index_callback,'FontSize',14,'BackgroundColor',[0.1 0.1 0.1],'ForegroundColor',[0.5 0.5 0.5]);
mass_index =  str2double(mass_index_edit.String);

uicontrol('style','text','units','normalized','position',[0.25,-0.01,0.125,0.05],'string','Area:','BackgroundColor',[0.1 0.1 0.1],'FontSize',14,'ForegroundColor','w');
area_index_edit = uicontrol('style','edit','units','normalized','position',[0.375,0,0.125,0.04],'string','5','Callback',@area_index_callback,'FontSize',14,'BackgroundColor',[0.1 0.1 0.1],'ForegroundColor',[0.5 0.5 0.5]);
area_index =  str2double(area_index_edit.String);

uicontrol('style','text','units','normalized','position',[0.5,-0.01,0.125,0.05],'string','Aspect:','BackgroundColor',[0.1 0.1 0.1],'FontSize',14,'ForegroundColor','w');
aspect_index_edit = uicontrol('style','edit','units','normalized','position',[0.625,0,0.125,0.04],'string','5','Callback',@aspect_index_callback,'FontSize',14,'BackgroundColor',[0.1 0.1 0.1],'ForegroundColor',[0.5 0.5 0.5]);
aspect_index =  str2double(aspect_index_edit.String);

uicontrol('style','pushbutton','units','normalized','position',[0.75,0,0.125,0.04],'string','Classify','BackgroundColor',[0.1 0.1 0.1],'FontSize',14,'ForegroundColor','w','Callback',@classify);

plot_scatter(data,mass_index,area_index,aspect_index) 

    function mass_index_callback(~,~,~)
        mass_index =  str2double(mass_index_edit.String);
        area_index =  str2double(area_index_edit.String);
        aspect_index =  str2double(aspect_index_edit.String);
        plot_scatter(data,mass_index,area_index,aspect_index)        
    end

    function area_index_callback(~,~,~)
        mass_index =  str2double(mass_index_edit.String);
        area_index =  str2double(area_index_edit.String);
        aspect_index =  str2double(aspect_index_edit.String);
        plot_scatter(data,mass_index,area_index,aspect_index)        
    end

    function aspect_index_callback(~,~,~)
        mass_index =  str2double(mass_index_edit.String);
        area_index =  str2double(area_index_edit.String);
        aspect_index =  str2double(aspect_index_edit.String);
        plot_scatter(data,mass_index,area_index,aspect_index)        
    end

    function plot_scatter(data,mass_index,area_index,aspect_index)      
        ax = gca; cla(ax);
        if mass_index<=1
            mass_index = 1.1;
        end
        if area_index<=1
            area_index = 1.1;
        end
        if aspect_index<=1
            aspect_index = 1.1;
        end
        classes = data.classes;
        parameters = extract_parameters(classes);
        total_number_of_clusters = extract_total_number_of_clusters(classes);
        mass_boundary = calculate_boundary(parameters(:,1),mass_index);
        area_boundary = calculate_boundary(parameters(:,2),area_index);
        ratio_boundary = calculate_boundary(parameters(:,9),aspect_index);
        maximum_number_of_classes = length(mass_boundary)*length(area_boundary)*length(ratio_boundary);        
        hold on
        scatter3(parameters(:,1),parameters(:,2),parameters(:,9),10,'b','filled','MarkerFaceAlpha',0.8)
        plot_boundary_lines(mass_boundary,area_boundary,ratio_boundary)
        view(30,20)
        title({'',['Total number of clusters = ',num2str(total_number_of_clusters)],['Maximum Number of Classes = ',num2str(maximum_number_of_classes)]},'interpreter','latex','fontsize',18,'color','w')
        set(gca,'color',[0.1,0.1,0.1],'TickDir', 'out','box','on','BoxStyle','full','XColor','w','YColor','w','ZColor','w','TickLabelInterpreter','latex');
        xlabel('Mass','interpreter','latex','fontsize',18,'color','w');
        ylabel('Area','interpreter','latex','fontsize',18,'color','w');
        zlabel('Aspect Ratio','interpreter','latex','fontsize',18,'color','w');
    end

    function classify(~,~,~)
        mass_index =  str2double(mass_index_edit.String);
        area_index =  str2double(area_index_edit.String);
        aspect_index =  str2double(aspect_index_edit.String);
        classify_inside(data,mass_index,area_index,aspect_index)
    end


    function classify_inside(data,mass_index,area_index,aspect_index)
        classes = data.classes;
        parameters = extract_parameters(classes);
        mass_boundary = calculate_boundary(parameters(:,1),mass_index);
        area_boundary = calculate_boundary(parameters(:,2),area_index);
        ratio_boundary = calculate_boundary(parameters(:,9),aspect_index);        
        idx = find_clusters_inside_boundary(parameters,mass_boundary,area_boundary,ratio_boundary);
        classes_grouped = cluster_idx(classes,idx);
        I = cellfun(@(x) x(1),classes_grouped(:,3));
        [~,I] = sort(I);
        classes_grouped = classes_grouped(I,:);
        data.classes = classes_grouped;
        data.name = [data.name,'_decision_boundary'];
        shape_classification_plot(data)
    end
end

function parameters = extract_parameters(classes)
parameters = classes(:,3);
parameters = vertcat(parameters{:});
parameters(:,9) = parameters(:,7)./parameters(:,8);
end

function total_number_of_clusters = extract_total_number_of_clusters(classes)
total_number_of_clusters = cellfun(@(x) size(x,1),classes(:,1));
total_number_of_clusters = sum(total_number_of_clusters);
end

function boundary = calculate_boundary(data,stretch_index)
% boundary(1) = min(data);
% i = 1;
% while true
%     i = i+1;
%     boundary(i) = stretch_index*boundary(i-1);
%     if boundary(i)>max(data)
%         break
%     end
% end
boundary = logspace(min(log10(data)),max(log10(data)),stretch_index);
end

function plot_boundary_lines(mass_boundary,area_boundary,ratio_boundary)
[X,Y,Z] = meshgrid(mass_boundary,area_boundary,ratio_boundary);
for i = 1:size(X,3)
    surf(X(:,:,i),Y(:,:,i),Z(:,:,i),'Facecolor','none','EdgeColor','r')
end

X = permute(X,[1 3 2]);
Y = permute(Y,[1 3 2]);
Z = permute(Z,[1 3 2]);
for i = 1:size(X,3)    
    surf(X(:,:,i),Y(:,:,i),Z(:,:,i),'Facecolor','none','EdgeColor','r')
end
end

function idx = find_clusters_inside_boundary(parameters,mass_boundary,area_boundary,ratio_boundary)
m= 1;
for i = 1:length(mass_boundary)
    for j = 1:length(area_boundary)
        for k = 1:length(ratio_boundary)
            m = m+1;
            idx{m} = find(parameters(:,1)<mass_boundary(i) & parameters(:,2)<area_boundary(j) & parameters(:,9)<ratio_boundary(k));
            if isempty(idx{m})~=1
                parameters(idx{m},:) = [];
            end
        end
    end
end
idx = idx(~cellfun('isempty',idx));
end

function classes_cluster = cluster_idx(classes,idx)
f = waitbar(0,'Classifying Clusters');
for i  = 1:length(idx)
    classes_cluster{i} = group_classes(idx{i},classes);
    classes(idx{i},:) = [];
    waitbar(i/length(idx),f,'Classifying Clusters');
end
classes_cluster = vertcat(classes_cluster{:});
close(f)
end

function classes_new = group_classes(idx,classes)
idx_classes = classes(idx,:);

temp = idx_classes(:,1);
classes_new{1,1} = vertcat(temp{:});

temp = idx_classes(:,2);
classes_new{1,2} = vertcat(temp{:});

classes_new{1,3} = mean(classes_new{1,2},1);

temp = idx_classes(:,4);
classes_new{1,4} = vertcat(temp{:});    
end