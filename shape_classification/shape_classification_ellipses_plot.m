function shape_classification_ellipses_plot(data)
number_of_classes = size(data.classes,1);
answer = inputdlg({'Classes to Plot:','Radius of Ellipses:','Scatter Clusters in Class (1 or 0):','Show Error Bar (0 or1):','Show Data Table (0 or 1):','Weight for Total Number of Clusters (0 or 1):'},'Input',[1 50],{['1:',num2str(number_of_classes)],'1','0','0','0','0'});
if isempty(answer)~=1    
    to_plot = eval(answer{1});
    ellipses_radius = str2double(answer{2}); % this is the enlargment factor for the ellipses size (just for visualization purposes)
    scatter_clusters = str2double(answer{3}); % if set to 1 scatters the mass/area plot ofr each of them clusters in a class
    show_errorbar = str2double(answer{4}); % if set to 1 shows error bar for std of major and minor axis       
    show_table = str2double(answer{5});  % if set to 1 shows data table containing classes information
    weight = str2double(answer{6}); % if set to 1 all the statistics will be normalized to the total number of clusters
    if weight == 0
        classes_color_statistics = extract_classes_color_statistics(data.classes); % numbr of clusters in a class from different colors        
    elseif weight == 1
        classes_color_statistics = extract_classes_color_statistics_weighted(data.classes); % numbr of clusters in a class from different colors normalized        
    end
    classes_feature_statistics = extract_classes_feature_statistics(data.classes); % statistics about the class features (mean,std,min,max)
    shape_classification_ellipses_plot_inside(data,classes_color_statistics,classes_feature_statistics,to_plot,ellipses_radius,scatter_clusters,show_errorbar,show_table)
end
end

function shape_classification_ellipses_plot_inside(data,classes_color_statistics,classes_feature_statistics,to_plot,ellipses_radius,scatter_clusters,show_errorbar,show_table)
classes = data.classes;
number_of_classes = size(classes,1);
ellipses_size = classes_color_statistics;
ellipses_size = sum(ellipses_size,2);
ellipses_size = ellipses_size/sum(ellipses_size);
ellipses_size = ellipses_size(to_plot,:);  %ratio between number of total clusters in a class to the number of total clusters

%center position of the ellipse(mean mass and area); r_1 and r_2
%presents the mean major_axis and minor_axis
to_draw_info = classes_feature_statistics(to_plot);
to_draw_info = cellfun(@(x) x(1,:),to_draw_info,'UniformOutput',false);
to_draw_info = vertcat(to_draw_info{:});
to_draw_info = to_draw_info(:,[1,2,7,8]);
if size(to_draw_info,1)>1
    enlarge_factor = (max(to_draw_info(:,1))-min(to_draw_info(:,1)))/(max(to_draw_info(:,2))-min(to_draw_info(:,2)));
else
    enlarge_factor = 1;
end
to_draw_info(:,3) = to_draw_info(:,3).*ellipses_size*ellipses_radius*enlarge_factor;
to_draw_info(:,4) = to_draw_info(:,4).*ellipses_size*ellipses_radius;

%identifies the color assignment for each color
c_map = colormap(jet);
c_map = interp1(1:size(c_map,1),c_map,linspace(1,size(c_map,1),size(classes_color_statistics,2)));

%identifies the share between different colors in a class
ellipse_percentage = classes_color_statistics./sum(classes_color_statistics,2);

if show_errorbar==1
    %error bar shows the std of major and minor axis of each class
    error_bar_info = classes_feature_statistics(to_plot);
    error_bar_info = cellfun(@(x) x(2,:),error_bar_info,'UniformOutput',false);
    error_bar_info = vertcat(error_bar_info{:});
    error_bar_info = error_bar_info(:,[7,8]);
    error_bar_info(:,1) = error_bar_info(:,1)*enlarge_factor;
end

if scatter_clusters==1
    %identifies the color assignment for each class
    c_map_scatter = colormap(jet);
    c_map_scatter = interp1(1:size(c_map,1),c_map_scatter,linspace(1,size(c_map,1),length(to_plot)));
    
    classes_scatter = classes(to_plot,:);
    classes_scatter = classes_scatter(:,2);
    classes_scatter = cellfun(@(x) x(:,1:2),classes_scatter,'UniformOutput',false);
end

figure()
set(gcf,'color',[1,1,1],'units','normalized','position',[0.2 0.15 0.6 0.7]);
hold on
for i = 1:length(to_plot)
    x_c = to_draw_info(i,1);
    y_c = to_draw_info(i,2);
    x_r = to_draw_info(i,3);
    y_r = to_draw_info(i,4);
    nice_ellipse(x_c,y_c,x_r,y_r,ellipse_percentage(to_plot(i),:),c_map)
    text(x_c,y_c,num2str(to_plot(i)),'fontsize',18,'interpreter','latex')
    
    if scatter_clusters==1
        scatter(x_c,y_c,20,c_map_scatter(i,:),'filled')
        scatter(classes_scatter{i,1}(:,1),classes_scatter{i,1}(:,2),1,c_map_scatter(i,:),'filled')
    end
    if show_errorbar==1
        errorbar(x_c,y_c,error_bar_info(i,1),'horizontal','color','k');
        errorbar(x_c,y_c,error_bar_info(i,2),'vertical','color','k');
    end
end
pbaspect([1 1 1])
xlabel('Class Average Number of Locs','interpreter','latex','fontsize',18)
ylabel('Class Average Area','interpreter','latex','fontsize',18)
set(gca,'color',[1,1,1],'TickLength',[0.02 0.02],'TickDir','out','box','on','BoxStyle','full','fontsize',18,'TickLabelInterpreter','latex');
title({'','Ellipticity: Ratio Between Mean(Major Axis) to Mean(Minor Axis) of a Class.','Ellipses Size: Ratio Between Number of Clusters in a Class to the Total Number of Clusters.','Bar Chart: Total Number of Clusters in the Classes Shown in the Graph Divided by the Total Number of Clusters for Each Color',''},'interpreter','latex','fontsize',12)
grid on
%plot bars
bar_data = classes_color_statistics(to_plot,:);
bar_data = bar_data./sum(classes_color_statistics,1);
if size(bar_data,1)>1
    bar_data = sum(bar_data);
end
bar_length = 0.5;
x_i = 0.8;
number_of_colors = size(classes_color_statistics,2);
for i = 1:number_of_colors
    x_i = x_i+0.01;
    annotation('rectangle',[x_i 0.11 0.01 bar_length]);
    if max(bar_data)>0.5 %between 0 and 100
        annotation('rectangle',[x_i 0.11 0.01 bar_length*bar_data(i)],'facecolor',c_map(i,:),'facealpha',0.5);
        if i == number_of_colors
            x_i = x_i+0.01;
            annotation('textbox',[x_i 0.05 0.1 0.1],'string','0\%','fontsize',28,'interpreter','latex','edgecolor','none')
            annotation('textbox',[x_i bar_length+0.05 0.1 0.1],'string','100\%','fontsize',28,'interpreter','latex','edgecolor','none')
        end
    elseif max(bar_data)>0.25 %between 0 and 50
        annotation('rectangle',[x_i 0.11 0.01 2*bar_length*bar_data(i)],'facecolor',c_map(i,:),'facealpha',0.5);
        if i == number_of_colors
            x_i = x_i+0.01;
            annotation('textbox',[x_i 0.05 0.1 0.1],'string','0\%','fontsize',28,'interpreter','latex','edgecolor','none')
            annotation('textbox',[x_i bar_length+0.05 0.1 0.1],'string','50\%','fontsize',28,'interpreter','latex','edgecolor','none')
        end
    elseif max(bar_data)>0.1 % between 0 and 25
        annotation('rectangle',[x_i 0.11 0.01 4*bar_length*bar_data(i)],'facecolor',c_map(i,:),'facealpha',0.5);
        if i == number_of_colors
            x_i = x_i+0.01;
            annotation('textbox',[x_i 0.05 0.1 0.1],'string','0\%','fontsize',28,'interpreter','latex','edgecolor','none')
            annotation('textbox',[x_i bar_length+0.05 0.1 0.1],'string','25\%','fontsize',28,'interpreter','latex','edgecolor','none')
        end
    elseif max(bar_data)>0.05 % between 0 and 10
        annotation('rectangle',[x_i 0.11 0.01 10*bar_length*bar_data(i)],'facecolor',c_map(i,:),'facealpha',0.5);
        if i == number_of_colors
            x_i = x_i+0.01;
            annotation('textbox',[x_i 0.05 0.1 0.1],'string','0\%','fontsize',28,'interpreter','latex','edgecolor','none')
            annotation('textbox',[x_i bar_length+0.05 0.1 0.1],'string','10\%','fontsize',28,'interpreter','latex','edgecolor','none')
        end
    elseif max(bar_data)>0.01 %between 0 and 5
        annotation('rectangle',[x_i 0.11 0.01 20*bar_length*bar_data(i)],'facecolor',c_map(i,:),'facealpha',0.5);
        if i == number_of_colors
            x_i = x_i+0.01;
            annotation('textbox',[x_i 0.05 0.1 0.1],'string','0\%','fontsize',28,'interpreter','latex','edgecolor','none')
            annotation('textbox',[x_i bar_length+0.05 0.1 0.1],'string','5\%','fontsize',28,'interpreter','latex','edgecolor','none')
        end
    else % between 0 and 1
        annotation('rectangle',[x_i 0.11 0.01 100*bar_length*bar_data(i)],'facecolor',c_map(i,:),'facealpha',0.5);
        if i == number_of_colors
            x_i = x_i+0.01;
            annotation('textbox',[x_i 0.05 0.1 0.1],'string','0\%','fontsize',28,'interpreter','latex','edgecolor','none')
            annotation('textbox',[x_i bar_length+0.05 0.1 0.1],'string','1\%','fontsize',28,'interpreter','latex','edgecolor','none')
        end
    end
end

if show_table ==1
    for m = 1:number_of_classes
        row_names{m} = ['class_',num2str(m)];
    end
    for m = 1:number_of_colors
        column_names{m} = ['color_',num2str(m)];
    end
    table_data_plot(classes_color_statistics,row_names,column_names,'Number of Clusters for Each Color')
    table_data_plot(bar_data,{'Bar Data Percentage'},column_names,'Percentage of Clusters Shown on The Graph to The Total Number of Clusters For Each Color')
    table_data_plot(ellipse_percentage,row_names,column_names,'Percentage of Clusters for Each Color of a Class')
end
end

function stat = extract_classes_color_statistics(classes)
for i = 1:size(classes,1)
    colors{i} = unique(cell2mat(classes{i,4}));
end
colors = unique(vertcat(colors{:}));

stat = zeros(size(classes,1),length(colors));
for i = 1:size(classes,1)
    for j = 1:length(colors)
        stat(i,j) = length(find(cell2mat(classes{i,4})==colors(j)));
    end
end
end

function stat_norm = extract_classes_color_statistics_weighted(classes)
for i = 1:size(classes,1)
    colors{i} = unique(cell2mat(classes{i,4}));
end
colors = unique(vertcat(colors{:}));

stat = zeros(size(classes,1),length(colors));
for i = 1:size(classes,1)
    for j = 1:length(colors)
        stat(i,j) = length(find(cell2mat(classes{i,4})==colors(j)));
    end
end
stat_norm = stat./sum(stat,1);
end

function stat = extract_classes_feature_statistics(classes)
for i = 1:size(classes,1)
    if size(classes{i,2},1)>1
        stat{i,1}(1,:) = mean(classes{i,2});
        stat{i,1}(2,:) = std(classes{i,2});
        stat{i,1}(3,:) = min(classes{i,2});
        stat{i,1}(4,:) = max(classes{i,2});
    else
        stat{i,1}(1,:) = classes{i,2};
        stat{i,1}(2,:) = classes{i,2}-classes{i,2};
        stat{i,1}(3,:) = classes{i,2};
        stat{i,1}(4,:) = classes{i,2};
    end
end
end

function nice_ellipse(x0,y0,r1,r2,percentage,c_map)
theta = 2*pi*cumsum(percentage);
for i =  1:length(theta)
    if i==1
        the = linspace(0,theta(i),100);
    else
        the = linspace(theta(i-1),theta(i),100);
    end
    x1 = x0+r1*cos(the);
    y1 = y0+r2*sin(the);
    x1 = [x1,x0];
    y1 = [y1,y0];    
    hold on
    plot(polyshape(x1,y1),'FaceColor',c_map(i,:),'FaceAlpha',0.5)
    text(x0+(r1/2)*cos(the(ceil(length(the)/2))),y0+(r2/2)*sin(the(ceil(length(the)/2))),[num2str(percentage(i)*100),'%'])
end
end