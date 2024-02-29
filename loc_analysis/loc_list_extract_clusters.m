function data_cluster = loc_list_extract_clusters(data)
for i=1:length(data)    
    data_cluster{i} = extracting_clusters(data{i});    
end
data_cluster = horzcat(data_cluster{:});
loc_list_plot(data_cluster)
end

function clusters = extracting_clusters(data)
f = waitbar(0,'extracting clusters');
area = data.area;
count(1) = 1;
counter = 1;
for i = 2:length(area)
    if area(i)~=area(i-1)
        counter = counter+1;
        count(counter) = i;
    end
end
waitbar(0.5,f,'extracting clusters');
for i = 1:length(count)
    if i== length(count)
        clusters{i}.x_data = data.x_data(count(i):length(area));
        clusters{i}.y_data = data.y_data(count(i):length(area));
        clusters{i}.area = data.area(count(i):length(area));
        clusters{i}.name = [data.name,'_',num2str(i)];
        clusters{i}.type = 'loc_list';
    else
        clusters{i}.x_data = data.x_data(count(i):count(i+1)-1);
        clusters{i}.y_data = data.y_data(count(i):count(i+1)-1);
        clusters{i}.area = data.area(count(i):count(i+1)-1);
        clusters{i}.name = [data.name,'_',num2str(i)];
        clusters{i}.type = 'loc_list';
    end
end
close(f)
end