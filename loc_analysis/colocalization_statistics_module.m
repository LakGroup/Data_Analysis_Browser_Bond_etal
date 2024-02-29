function colocalization_statistics_module()
figure()
set(gcf,'name','Colocalization Statistics Module','NumberTitle','off','color','k','units','normalized','position',[0.25 0.2 0.5 0.6],'menubar','none','toolbar','figure')
global data listbox
uicontrol('style','pushbutton','units','normalized','position',[0,0.95,0.2,0.05],'string','Set Reference Data','ForegroundColor','b','Callback',{@set_reference_data_callback},'FontSize',12);
uicontrol('style','pushbutton','units','normalized','position',[0.2,0.95,0.2,0.05],'string','Set Colocalization Data','ForegroundColor','b','Callback',{@set_colocalization_data_callback},'FontSize',12);
uicontrol('style','pushbutton','units','normalized','position',[0.4,0.95,0.2,0.05],'string','Statistical Analysis','ForegroundColor','b','Callback',{@statistics_callback},'FontSize',12);
data_reference = [];
data_colocalization = [];

    function set_reference_data_callback(~,~,~)
        listbox_value = listbox.Value;
        if isempty(data)~=1
            data_reference = data(listbox_value);
            plot_inside_data_reference(data_reference)
        end
    end

    function set_colocalization_data_callback(~,~,~)
        listbox_value = listbox.Value;
        if isempty(data)~=1
            data_colocalization = data(listbox_value);
            plot_inside_data_colocalization(data_colocalization)
        end
    end

    function statistics_callback(~,~,~)
        if isempty(data_reference)~=1 && isempty(data_colocalization)~=1
            if length(data_reference)==length(data_colocalization)
                for i = 1:length(data_reference)
                    counter(1) = i;
                    counter(2) = length(data_reference);
                    bundle_data{i} = find_statistics(data_reference{i},data_colocalization{i},counter);
                    names{i} = data_colocalization{i}.name;
                end
                plot_bundle_data(bundle_data,names)
                [table_data,table_name] = stat_table(bundle_data,names);
                table_data_plot(table_data,table_name,{'Number of Locs (Reference Data)','Cluster Area (Reference Data)','Number of Colocalized Clusters','Sum Area Colocalized Clusters','Mean Colocalized Clusters Distance to Ref Cluster'},'Colocalization Statistical Analysis')
                
                for i = 1:length(data_reference)
                    for j = 1:size(bundle_data{i},1)
                        Ae = [];
                        Sz = [];
                        Center = [];
                        for k = 1:size(bundle_data{i}{j,3},2)
                            shp = alphaShape(bundle_data{i}{j,3}{1,k}(:,1),bundle_data{i}{j,3}{1,k}(:,2));
                            Ae(k) = area(shp)*117*117;
                            Sz(k) = size(bundle_data{i}{j,3}{1,k},1);
                            Center(k,:) = mean(bundle_data{i}{j,3}{1,k}(:,1:2));
                        end
                        Distances = pdist(Center,'Euclidean');
                        Distances = squareform(Distances);
                        bundle_data{i}{j,5} = Ae;
                        bundle_data{i}{j,6} = Sz;
                        bundle_data{i}{j,7} = Distances;
                    end
                end
                
                assignin('base','bundle_data',bundle_data)
                
                for i = 1:length(data_reference)
                    
                    Table = [];
                    Idx = [];
                    Distances = [];
                    
                    for j = 1:size(bundle_data{i},1)
                        
                        refshp = alphaShape(bundle_data{i}{j,1}(:,1),bundle_data{i}{j,1}(:,2));
                        refshp.Alpha
                        refArea = area(refshp)*117*117;
                        refLocs = size(bundle_data{i}{j,1},1);
                        
                        Points = find_distance(bundle_data{i}(j,:));
                        Points = cellfun(@(x) x(3,1),Points);
                        Center = [];
                        for k = 1:size(bundle_data{i}{j,3},2)
                            Center(k,:) = mean(bundle_data{i}{j,3}{1,k}(:,1:2));
                        end
                        if size(Center,1) == 1
                            Idx = NaN(1,3);
                            Distances = NaN(1,3);
                        elseif size(Center,1) == 2
                            [Idx,Distances] = knnsearch(Center,Center,'K',2);
                            Idx(:,3) = NaN;Distances(:,3) = NaN;
                        else
                            [Idx,Distances] = knnsearch(Center,Center,'K',3);
                        end
                        Table = [Table; repmat(j,[size(bundle_data{i}{j,3},2),1]) repmat(refLocs,[size(bundle_data{i}{j,3},2),1]) repmat(refArea,[size(bundle_data{i}{j,3},2),1]) [1:size(bundle_data{i}{j,3},2)]' bundle_data{i}{j,6}' bundle_data{i}{j,5}' Idx(:,2) Distances(:,2)*117 Idx(:,3) Distances(:,3)*117 Points'*117];
                    end
                    Table2{i} = array2table(Table);
                    Table2{i}.Properties.VariableNames = {'Reference_cluster','Number_of_localizations_in_reference_cluster','Reference_cluster_area','Colocalization_cluster','Number_of_localizations_in_colocalization_cluster', 'Area_of_colocalization_cluster','Cluster_number_of_closest_distance', 'Distance_to_closest_cluster', 'Cluster_number_of_second_closest_distance', 'Distance_to_second_closest_cluster','Colocalized_clusters_distance_to_reference_cluster'};
                end
                [file,path] = uiputfile('*.xlsx','Please Specify a name to save this as');
                name = fullfile(path,file);
                for i = 1:length(data_reference)
                    writetable(Table2{i},name,'sheet',['Ref ' num2str(i)]);
                end

            else
                msgbox('number of reference data is not equal to number of colocalizaiton data')
            end
        end
    end

    function plot_inside_data_reference(data)
        if length(data)>1
            slider_step=[1/(length(data)-1),1];
            slider = uicontrol('style','slider','units','normalized','position',[0,0,0.05,0.95],'value',1,'min',1,'max',length(data),'sliderstep',slider_step,'Callback',{@sld_callback});
        end
        slider_value=1;
        plot_inside_scatter(data{slider_value})
        
        function sld_callback(~,~,~)
            slider_value = round(slider.Value);
            plot_inside_scatter(data{slider_value})
        end
        
        function plot_inside_scatter(data)
            data_down_sampled = loc_list_down_sample(data,50000);
            color = data_down_sampled.area;
            subplot(1,2,1)
            ax = gca; cla(ax)
            scatter(data_down_sampled.x_data,data_down_sampled.y_data,1,log10(color),'filled')
            title({'','','','',['Number of Clusters = ',num2str(length(unique(color)))]},'interpreter','latex','color','w')
            axis off
        end
    end

    function plot_inside_data_colocalization(data)
        if length(data)>1
            slider_step=[1/(length(data)-1),1];
            slider = uicontrol('style','slider','units','normalized','position',[0.5,0,0.05,0.95],'value',1,'min',1,'max',length(data),'sliderstep',slider_step,'Callback',{@sld_callback});
        end
        slider_value=1;
        plot_inside_scatter(data{slider_value})
        
        function sld_callback(~,~,~)
            slider_value = round(slider.Value);
            plot_inside_scatter(data{slider_value})
        end
        
        function plot_inside_scatter(data)
            data_down_sampled = loc_list_down_sample(data,50000);
            color = data_down_sampled.area;
            subplot(1,2,2)
            ax = gca; cla(ax)
            scatter(data_down_sampled.x_data,data_down_sampled.y_data,1,log10(color),'filled')
            title({'','','','',['Number of Clusters = ',num2str(length(unique(color)))]},'interpreter','latex','color','w')
            axis off
        end
    end
end

%--------------------------------plot bundle data--------------------------
%--------------------------------plot bundle data--------------------------
function plot_bundle_data(data,names)
figure()
set(gcf,'name','Colocalization Statistical Analysis','NumberTitle','off','color','k','units','normalized','position',[0.25 0.2 0.5 0.6],'menubar','none','toolbar','figure')
if length(data)>1
    slider_one_step=[1/(length(data)-1),1];
    slider_one = uicontrol('style','slider','units','normalized','position',[0,0,0.03,1],'value',1,'min',1,'max',length(data),'sliderstep',slider_one_step,'Callback',{@slider_one_callback});
end
slider_one_value=1;

if size(data{slider_one_value},1)>1
    slider_step_two=[1/(size(data{slider_one_value},1)-1),1/(size(data{slider_one_value},1)-1)];
    slider_two = uicontrol('style','slider','units','normalized','position',[0.03,0,0.97,0.04],'value',1,'min',1,'max',size(data{slider_one_value},1),'sliderstep',slider_step_two,'Callback',{@slider_two_callback});
end
slider_two_value=1;

try
    plot_inside(data{slider_one_value}(slider_two_value,:),names{slider_one_value})
end

    function slider_one_callback(~,~,~)
        slider_one_value = round(slider_one.Value);
        if size(data{slider_one_value},1)>1
            slider_two.SliderStep = [1/(size(data{slider_one_value},1)-1),1/(size(data{slider_one_value},1)-1)];
            slider_two.Max = size(data{slider_one_value},1);
            slider_two.Min = 1;
            slider_two.Value = 1;
        end
        slider_two_value = 1;
        plot_inside(data{slider_one_value}(slider_two_value,:),names{slider_one_value})
    end

    function slider_two_callback(~,~,~)
        slider_two_value = round(slider_two.Value);
        plot_inside(data{slider_one_value}(slider_two_value,:),names{slider_one_value})
    end

    function plot_inside(data,name)
        set(gca,'color',[0.1 0.1 0.1])
        ax = gca;cla(ax);
        hold on
        plot(data{2},'Facecolor','b','Facealpha',0.2)
        scatter(data{1}(:,1),data{1}(:,2),3,'b','filled','MarkerFaceAlpha',0.8)
        area_ref_cluster = area(data{2});
        number_of_ref_locs = size(data{1},1);
        if ~isempty(data{3})
            for i = 1:length(data{3})
                plot(data{4}{i},'Facecolor','y','Facealpha',0.3)
                scatter(data{3}{i}(:,1),data{3}{i}(:,2),3,'y','filled','MarkerFaceAlpha',0.8)
                number_of_coloc_locs(i) = size(data{3}{i},1);
                area_coloc_clusters(i) = area(data{4}{i});
            end
            points = find_distance(data);
            for i = 1:length(points)
                plot(points{i}(1:2,1),points{i}(1:2,2),'r')
                text(mean(points{i}(1:2,1)),mean(points{i}(1:2,2)),num2str(points{i}(3,1)),'color','w')
            end
            number_of_coloc_locs = sum(number_of_coloc_locs);
            number_of_coloc_clusters = length(data{3});
            area_coloc_clusters = sum(area_coloc_clusters);
        else
            number_of_coloc_locs = 0;
            number_of_coloc_clusters = 0;
            area_coloc_clusters = 0;
        end
        title({'','','',['File Name: ',regexprep(name,'_',' ')],['Number of localizations (Reference Cluster) :',num2str(number_of_ref_locs)],['Number of localizations (colocalization data) :',num2str(number_of_coloc_locs)],['Number of Colocalized Clusters :',num2str(number_of_coloc_clusters)],['Area (Reference Cluster) :',num2str(area_ref_cluster)],['Sum Area (Colocalized Clusters) :',num2str(area_coloc_clusters)]},'interpreter','latex','fontsize',14,'color','w')
        axis equal
        axis off
    end
end

function points = find_distance(data)
[x,y] = boundary(data{2});
for i = 1:length(data{3})
    if size(data{3}{i},1)>1
        coloc_clust_mean = mean(data{3}{i});
    else
        coloc_clust_mean = data{3}{i};
    end
    I = knnsearch([x,y],coloc_clust_mean(1,1:2),'K',1);
    points{i}(1,:) = coloc_clust_mean(1,1:2);
    points{i}(2,:) = [x(I),y(I)];
    points{i}(3,1) = pdist2(points{i}(1,:),points{i}(2,:));
    clear I coloc_clust_mean
end
end
%--------------------------------plot bundle data--------------------------
%--------------------------------plot bundle data--------------------------

%-----------------------------find stat bundle data------------------------
%-----------------------------find stat bundle data------------------------
function [table_data,names_table] = stat_table(data,names)
for i = 1:length(data)
    [table_data{i},names_table{i}] = extract_statistics(data{i},names{i});
end
names_table = horzcat(names_table{:});
table_data = vertcat(table_data{:});
end

function [table_data,names_table] = extract_statistics(data,name)
for i = 1:size(data,1)
    table_data(i,1) = size(data{i,1},1);
    table_data(i,2) = area(data{i,2});
    if ~isempty(data{i,3})
        for k = 1:length(data{i,3})
            number_of_coloc_locs(k) = size(data{i,3}{k},1);
            area_coloc_clusters(k) = area(data{i,4}{k});
        end
        points = find_distance(data(i,:));
        points = cellfun(@(x) x(3,1),points);
        number_of_coloc_locs = sum(number_of_coloc_locs);
        number_of_coloc_clusters = length(data{i,3});
        area_coloc_clusters = sum(area_coloc_clusters);
    else
        number_of_coloc_locs = 0;
        number_of_coloc_clusters = 0;
        area_coloc_clusters = 0;
        points = 0;
    end
    table_data(i,3) = number_of_coloc_clusters;
    table_data(i,4) = area_coloc_clusters;
    table_data(i,5) = mean(points);
    names_table{i} = [name,'_',num2str(i)];
end
end
%-----------------------------find stat bundle data------------------------
%-----------------------------find stat bundle data------------------------

%--------------------------------find bundle data--------------------------
%--------------------------------find bundle data--------------------------
function bundle_data = find_statistics(data_reference,data_colocalization,counter_waitbar)
[data_cluster_ref,poly_shapes_ref] = extract_clusters_from_data(data_reference,counter_waitbar);
[data_cluster_coloc,poly_shapes_coloc] = extract_clusters_from_data(data_colocalization,counter_waitbar);
idx = find_clolocalized_clusters(poly_shapes_ref,poly_shapes_coloc);
bundle_data = bundle_ref_coloc_clusters(data_cluster_ref,data_cluster_coloc,poly_shapes_ref,poly_shapes_coloc,idx);
end

function [data_cluster,poly_shapes] = extract_clusters_from_data(data,counter_waitbar)
ref(:,1) = data.x_data;
ref(:,2) = data.y_data;
ref(:,3) = data.area;
area_unique = unique(ref(:,3));
data_cluster = cell(1,length(area_unique));
f = waitbar(0,['extracting clusters...',num2str(counter_waitbar(1)),'/',num2str(counter_waitbar(2))]);
for p = 1:length(area_unique)
    I = ref(:,3) == area_unique(p);
    data_cluster{p} = ref(I,:);
    k = boundary(data_cluster{p}(:,1),data_cluster{p}(:,2));
    poly_shapes{p} = polyshape(data_cluster{p}(k,1),data_cluster{p}(k,2));
    %data_ref_boundary{p} = data_cluster{p}(k,:);
    clear I k
    waitbar(p/length(area_unique),f,['extracting clusters...',num2str(counter_waitbar(1)),'/',num2str(counter_waitbar(2))]);
end
close(f)
end

function index = find_clolocalized_clusters(poly_shapes_ref,poly_shapes_coloc)
f = waitbar(0,'finding colocalized clusters...');
to_check = zeros(length(poly_shapes_coloc),1);
index = cell(length(poly_shapes_ref),1);
for i = 1:length(poly_shapes_ref)
    idx = cell(length(poly_shapes_coloc),1);
    for j = 1:length(poly_shapes_coloc)
        if to_check(j)~=1
            Isect = intersect(poly_shapes_ref{i},poly_shapes_coloc{j});
            idx{j} = Isect.Vertices;
            if ~isempty(idx{j})
                to_check(j) = 1;
            end
        end
    end
    idx = find(~cellfun(@isempty,idx));
    index{i} = idx;
    clear idx
    waitbar(i/length(poly_shapes_ref),f,'finding colocalized clusters...');
end
close(f)
end

function bundle_data = bundle_ref_coloc_clusters(data_cluster_ref,data_cluster_coloc,poly_shapes_ref,poly_shapes_coloc,idx)
for i = 1:length(idx)
    bundle_data{i,1} = data_cluster_ref{i};
    bundle_data{i,2} = poly_shapes_ref{i};
    if ~isempty(idx{i})
        bundle_data{i,3} = data_cluster_coloc(idx{i});
        bundle_data{i,4} = poly_shapes_coloc(idx{i});
    end
end
end
%--------------------------------find bundle data--------------------------
%--------------------------------find bundle data--------------------------