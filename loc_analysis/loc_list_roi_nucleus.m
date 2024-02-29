function loc_list_roi_nucleus(data)
if length(data) < 1 || length(data) > 2
    error('You can only select 1 or 2 files for this.')
end

coordinates = getline();

if isfield(data{1},'coordinates')
    data{1}.coordinates = vertcat(data{1}.coordinates,coordinates);
    data{1}.name = [data{1}.name '_nuc'];
else
    data{1}.coordinates = {coordinates};
    data{1}.name = [data{1}.name '_nuc'];
end
if length(data) == 2
    if isfield(data{2},'coordinates')
        data{2}.coordinates = vertcat(data{2}.coordinates,coordinates);
        data{2}.name = [data{2}.name '_nuc'];
    else
        data{2}.coordinates = {coordinates};
        data{2}.name = [data{2}.name '_nuc'];
    end
end

close
loc_list_plot(data);
hold on;
if length(data) == 2
    for i = 1:numel(data{2}.coordinates)
        plot([data{2}.coordinates{i}(:,1); data{2}.coordinates{i}(1,1)],[data{2}.coordinates{i}(:,2); data{2}.coordinates{i}(1,2)],'w','linewidth',2);
    end
else
    for i = 1:numel(data{1}.coordinates)
        plot([data{1}.coordinates{i}(:,1); data{1}.coordinates{i}(1,1)],[data{1}.coordinates{i}(:,2); data{1}.coordinates{i}(1,2)],'w','linewidth',2);
    end
end

end