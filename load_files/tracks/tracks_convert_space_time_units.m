function trajectory = tracks_convert_space_time_units(trajectory,space_units,time_units,pixel_s,frame_interval)
for i = 1:length(trajectory)
    if isequal(space_units,'pixels')
        trajectory{i}(:,2:3) = trajectory{i}(:,2:3)*pixel_s;
    end
    
    if isequal(time_units,'frames')
        trajectory{i}(:,1) = trajectory{i}(:,1)*frame_interval;
    end
end
end