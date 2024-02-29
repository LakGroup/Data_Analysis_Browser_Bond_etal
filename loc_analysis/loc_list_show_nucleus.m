function loc_list_show_nucleus(data)

hold on;
if isfield(data,'coordinates')
    for i = 1:numel(data.coordinates)
        plot([data.coordinates{i}(:,1); data.coordinates{i}(1,1)],[data.coordinates{i}(:,2); data.coordinates{i}(1,2)],'w','linewidth',2);
    end
end
end