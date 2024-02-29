function [tracks_image,track_intp] = spt_convert_tracks_to_image(tracks,image,pixel_size)
tracks_norm = cellfun(@(x) x(:,2:3)/pixel_size,tracks,'UniformOutput',false);

track_intp = cell(length(tracks),1);
for i = 1:length(tracks)    
    [track_intp{i}] = interpolate_track(tracks_norm{i});    
end
track_intp_all = vertcat(track_intp{:});
tracks_image = NaN(size(image,1),size(image,2));
for i = 1:size(track_intp_all,1)
    tracks_image(track_intp_all(i,2),track_intp_all(i,1)) = 255;
end
end

function [track_intp] = interpolate_track(track)
track_intp = cell(size(track,1)-1,1);
for i = 1:size(track,1)-1
    [track_intp{i}] = interpolate_track_inside(track(i:i+1,:));
end
track_intp = vertcat(track_intp{:});
track_intp = unique(track_intp,'rows');
track_intp(track_intp==0) = 1;
end

function [track_intp] = interpolate_track_inside(track)
x = [track(1,1),track(2,1)];
y = [track(1,2),track(2,2)];
slope = (y(2)-y(1))/(x(2)-x(1));
dist_x = abs(floor(min(x))-ceil(max(x)));
dist_y = abs(floor(min(y))-ceil(max(y)));
if isequal(slope,-inf) || isequal(slope,inf)
    yq = min(y):max(y);
    xq = x(1)*ones(1,length(yq));
elseif isequal(slope,0)
    xq = min(x):max(x);
    yq = y(1)*ones(1,length(xq));
elseif isnan(slope)
    xq = x(1);
    yq = y(1);
else
    b = y(1)-slope*x(1);
    xq_1 = linspace(min(x),max(x),dist_x*10);
    yq_1 = slope*xq_1+b;
    yq_2 = linspace(min(y),max(y),dist_y*10);
    xq_2 = (yq_2-b)/slope;
    xq = [xq_1,xq_2];
    yq = [yq_1,yq_2];
end
track_interpolated = ceil([xq',yq']);
track_intp = unique(track_interpolated,'rows');
end