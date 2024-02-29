function [data_filter_above,data_filter_below] = loc_list_clusters_filter_area(data)
answer = inputdlg({'Enter Minimum Area per Cluster:'},'Input',[1 50],{'0.2'});
if isempty(answer)~=1
    min_area = str2double(answer{1});    
    f = waitbar(0,'Filtering Based On Area...');
    for i=1:length(data)        
        [data_filter_above{i},data_filter_below{i}] = filter_area(data{i},min_area); 
        waitbar(i/length(data),f,['Filtering Based On Area...',num2str(i),'/',num2str(length(data))]);
    end
    close(f)
    data_filter_above = data_filter_above(~cellfun(@(x) isempty(x),data_filter_above));
    data_filter_below = data_filter_below(~cellfun(@(x) isempty(x),data_filter_below));
end
end

function [data_to_send_above,data_to_send_below] = filter_area(data,min_area)
clusters = loc_list_extract_clusters_from_data(data);

for j = 1:size(clusters,2)

    xRef = clusters{j}(:,1);
    yRef = clusters{j}(:,2);
    shpRef{j,1} = alphaShape(xRef,yRef);
    CritAlpha = criticalAlpha(shpRef{j},'one-region');
    shpRef{j}.Alpha = CritAlpha;
    
    areas(j) = area(shpRef{j});

end

I = areas>min_area;
clusters_above = clusters(I);
if isempty(clusters_above)~=1
    clusters_above = vertcat(clusters_above{:});
    data_to_send_above.x_data = clusters_above(:,1);
    data_to_send_above.y_data = clusters_above(:,2);
    data_to_send_above.area = clusters_above(:,3);
    if isfield(data,'coordinates')
        data_to_send_above.coordinates = data.coordinates;
    end
    if isfield(data,'identifier')
        data_to_send_above.identifier = clusters_above(:,4);
    end
    data_to_send_above.name = [data.name,'_area_filter_above_',num2str(min_area)];
    data_to_send_above.type = 'loc_list';
else
    data_to_send_above = [];
end

clusters_below = clusters(~I);
if isempty(clusters_below)~=1
    clusters_below = vertcat(clusters_below{:});
    data_to_send_below.x_data = clusters_below(:,1);
    data_to_send_below.y_data = clusters_below(:,2);
    data_to_send_below.area = clusters_below(:,3);
    if isfield(data,'coordinates')
        data_to_send_below.coordinates = data.coordinates;
    end
    if isfield(data,'identifier')
        data_to_send_below.identifier = clusters_below(:,4);
    end
    data_to_send_below.name = [data.name,'_area_filter_below_',num2str(min_area)];
    data_to_send_below.type = 'loc_list';
else
    data_to_send_below = [];
end
end