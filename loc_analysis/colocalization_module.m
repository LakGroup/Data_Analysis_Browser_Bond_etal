function colocalization_module()
figure()
set(gcf,'name','Colocalization Module','NumberTitle','off','color','k','units','normalized','position',[0.25 0.2 0.5 0.6],'menubar','none','toolbar','figure')
global data listbox
uicontrol('style','pushbutton','units','normalized','position',[0,0.95,0.2,0.05],'string','Set Reference Data','ForegroundColor','b','Callback',{@set_reference_data_callback},'FontSize',12);
uicontrol('style','pushbutton','units','normalized','position',[0.2,0.95,0.2,0.05],'string','Set Colocalization Data','ForegroundColor','b','Callback',{@set_colocalization_data_callback},'FontSize',12);
uicontrol('style','pushbutton','units','normalized','position',[0.4,0.95,0.2,0.05],'string','Start Colocalization','ForegroundColor','b','Callback',{@colocalization_callback},'FontSize',12);
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

    function colocalization_callback(~,~,~)
        input_values = inputdlg({'Overlap Percentage Threshold:'},'',1,{'40'});
        if isempty(input_values)==1
            return
        else
            tic
            overlap_thres = str2double(input_values{1})/100;
            if isempty(data_reference)~=1 && isempty(data_colocalization)~=1
                if length(data_reference)==length(data_colocalization)
                    for i = 1:length(data_reference)
                        counter(1) = i;
                        counter(2) = length(data_reference);
                        [data_localized{i},data_not_localized{i}] = find_colocalization(data_reference{i},data_colocalization{i},overlap_thres,counter);
                        try
                            percentage(i) = 100*length(unique(data_localized{i}.area))/length(unique(data_colocalization{i}.area));
                        catch
                            percentage(i) = 0;
                        end
                            row_names{i} = data_colocalization{i}.name;
                    end 
                    column_names = {'percentage of colocalized clusters'};
                    title = 'Colocalization';
                    table_data_plot(percentage',row_names,column_names,title)
                    data_localized = data_localized(~cellfun('isempty',data_localized));
                    data_not_localized = data_not_localized(~cellfun('isempty',data_not_localized));
                    loc_list_plot(data_localized);
                    loc_list_plot(data_not_localized);                    
                else
                    msgbox('number of reference data is not equal to number of colocalization data')
                end
            end
        end
        
        [file,path] = uiputfile('Co-localized Clusters.mat','Please Specify a name to save the clusters as'); % Open a dialog so you can specify how to save it.
        name = [path extractBefore(file,'.') '.mat']; % Make sure it saves as .mat
        assignin('base','name',name); % Assign the name of the save file to the work space
        toc
        evalin('base', 'save(name,''MaskClusters'')'); % Do the actual saving
        evalin('base', 'clear'); % Clear up the work space
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
            subplot(1,2,1)
            ax = gca; cla(ax)
            scatter(data_down_sampled.x_data,data_down_sampled.y_data,1,log10(data_down_sampled.area),'filled')
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
            subplot(1,2,2)
            ax = gca; cla(ax)
            scatter(data_down_sampled.x_data,data_down_sampled.y_data,1,log10(data_down_sampled.area),'filled')
            axis off
        end
    end
end      

function [data_localized,data_not_localized] = find_colocalization(data_reference,data_colocalization,overlap_thres,counter_waitbar)
reference(:,1) = data_reference.x_data;
reference(:,2) = data_reference.y_data;
reference(:,3) = data_reference.area;
colocalization(:,1) = data_colocalization.x_data;
colocalization(:,2) = data_colocalization.y_data;
colocalization(:,3) = data_colocalization.area;

[data_ref_cluster,data_ref_polyshape] = find_clusters(reference,counter_waitbar);
[data_coloc_cluster,data_coloc_polyshape] = find_clusters(colocalization,counter_waitbar);

f = waitbar(0,['finding colocalized clusters...',num2str(counter_waitbar(1)),'/',num2str(counter_waitbar(2))]);
g = figure();
over_lap = zeros(size(data_ref_polyshape,1),size(data_coloc_polyshape,1));
NotSelected = [1:size(data_coloc_polyshape,1)];
for i = 1:size(data_ref_polyshape,1)
    idx = find_nreaby_clusters(data_ref_polyshape(i,:),data_coloc_polyshape);
    for j = 1:length(idx)
        intersect_area = area(intersect(data_ref_polyshape{i,1},data_coloc_polyshape{idx(j),1}));
        if intersect_area>=overlap_thres*data_coloc_polyshape{idx(j),2}
            over_lap(i,idx(j)) = 1;
        end        
    end
    clear idx
    waitbar(i/size(data_ref_polyshape,1),f,['finding colocalized clusters...',num2str(counter_waitbar(1)),'/',num2str(counter_waitbar(2))]);

    idx_colocalized = find(over_lap(i,:)==1);
%     if isempty(idx_colocalized)~=1
%         ax = gca; cla(ax);  
%         axis off
%         plot(data_ref_polyshape{i,1},'facecolor','r')
%         hold on
%         for k = 1:length(idx_colocalized)
%             plot(data_coloc_polyshape{idx_colocalized(k),1},'facecolor','r')
%         end
%     end
    NotSelected(idx_colocalized) = 0;
    MaskData{i,1}{1,1} = data_ref_cluster{1,i}(:,1:2);
    MaskData{i,1}{1,2} = data_ref_polyshape{i,1}.Vertices;
    MaskData{i,1}{1,2}(end+1,:) = MaskData{i,1}{1,2}(1,:);
    for k = 1:length(idx_colocalized)
        MaskData{i,2}{k,1} = data_coloc_cluster{1,idx_colocalized(k)}(:,1:2);
        MaskData{i,2}{k,2} = data_coloc_polyshape{idx_colocalized(k),1}.Vertices;
        MaskData{i,2}{k,2}(end+1,:) = MaskData{i,2}{k,2}(1,:);
    end
    
    clear idx_colocalized
    
end

% Also save the ones that were not co-localized
NotSelected(NotSelected==0) = []; % Clean up the selection matrix
MaskData{end+1,1} = []; % Make an empty cell for the ones that are outside the reference

% Loop over the non-selected clusters of the colocalization channel
for k = 1:length(NotSelected)
    MaskData{end,2}{k,1} = data_coloc_cluster{1,NotSelected(k)}(:,1:2); % Add the raw localizations to this cell
    MaskData{end,2}{k,2} = data_coloc_polyshape{NotSelected(k),1}.Vertices; % Add the cluster polygons to the cell
    MaskData{end,2}{k,2}(end+1,:) = MaskData{end,2}{k,2}(1,:); % Close the polygon
end
assignin('base','MaskClusters',MaskData); % Copy the data to the workspace so it can be saved

close(f)
close(g)

for i = 1:size(over_lap,1)
    idx_colocalized{i} = find(over_lap(i,:)==1);
end
idx_colocalized = idx_colocalized(~cellfun('isempty',idx_colocalized));
idx_colocalized = horzcat(idx_colocalized{:});
idx_colocalized = unique(idx_colocalized);
idx_not_colocalized = setdiff(1:length(data_coloc_cluster),idx_colocalized);

data_colocalized = data_coloc_cluster(idx_colocalized);
data_not_colocalized = data_coloc_cluster(idx_not_colocalized);

if isempty(data_not_colocalized)~=1
    data_not_colocalized = vertcat(data_not_colocalized{:});    
    data_not_localized.x_data = data_not_colocalized(:,1);
    data_not_localized.y_data = data_not_colocalized(:,2);
    data_not_localized.area = data_not_colocalized(:,3);
    data_not_localized.type = 'loc_list';
    data_not_localized.name = [data_colocalization.name,'_not_colocalized_',num2str(100*overlap_thres),'_percent'];
else
    data_not_localized = [];
end
if isempty(data_colocalized)~=1
    data_colocalized = vertcat(data_colocalized{:});
    data_localized.x_data = data_colocalized(:,1);
    data_localized.y_data = data_colocalized(:,2);
    data_localized.area = data_colocalized(:,3);
    data_localized.type = 'loc_list';
    data_localized.name = [data_colocalization.name,'_colocalized_',num2str(100*overlap_thres),'_percent'];
else
    data_localized = [];
end
end

function [data_cluster,poly_shape] = find_clusters(data,counter_waitbar)
area_unique = unique(data(:,3));
f = waitbar(0,['extracting clusters...',num2str(counter_waitbar(1)),'/',num2str(counter_waitbar(2))]);
data_cluster = cell(1,length(area_unique));
for p = 1:length(area_unique)
    I = data(:,3) == area_unique(p);
    data_cluster{p} = data(I,:);
    clear I
    waitbar(p/length(area_unique),f,['extracting clusters...',num2str(counter_waitbar(1)),'/',num2str(counter_waitbar(2))]);
end
close(f)

f = waitbar(0,['extracting clusters boundary...',num2str(counter_waitbar(1)),'/',num2str(counter_waitbar(2))]);
for p = 1:length(data_cluster)
    k =  boundary(data_cluster{p}(:,1),data_cluster{p}(:,2));
    boundary_data = data_cluster{p}(k,1:2);   
    poly_shape{p,1} = polyshape(boundary_data(:,1),boundary_data(:,2));
    poly_shape{p,2} = area(poly_shape{p,1});
    poly_shape{p,3} = mean(boundary_data);
    clear k boundary_data
    waitbar(p/length(area_unique),f,['extracting clusters boundary...',num2str(counter_waitbar(1)),'/',num2str(counter_waitbar(2))]);
end
close(f)
end

function idx = find_nreaby_clusters(data_ref_polyshape,data_coloc_polyshape)
X = data_coloc_polyshape(:,3);
X = vertcat(X{:});
Y = data_ref_polyshape{1,3};
r = 5*sqrt(data_ref_polyshape{1,2});
idx = rangesearch(X,Y,r);
if isempty(idx)~=1
    idx = horzcat(idx{:});    
else
    idx = [];
end
end