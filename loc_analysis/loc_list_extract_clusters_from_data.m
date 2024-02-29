function clusters = loc_list_extract_clusters_from_data(data)
area = data.area;
count(1) = 1;
counter = 1;
for i = 2:length(area)
    if area(i)~=area(i-1)
        counter = counter+1;
        count(counter) = i;
    end
end
for i = 1:length(count)
    if i== length(count)
        clusters{i}(:,1) = data.x_data(count(i):length(area));
        clusters{i}(:,2) = data.y_data(count(i):length(area));
        clusters{i}(:,3) = data.area(count(i):length(area));
        if isfield(data,'identifier')
            clusters{i}(:,4) = data.identifier(count(i):length(area));
        end
        
    else
        clusters{i}(:,1) = data.x_data(count(i):count(i+1)-1);
        clusters{i}(:,2) = data.y_data(count(i):count(i+1)-1);
        clusters{i}(:,3) = data.area(count(i):count(i+1)-1);
        if isfield(data,'identifier')
            clusters{i}(:,4) = data.identifier(count(i):count(i+1)-1);
        end
    end
end
end