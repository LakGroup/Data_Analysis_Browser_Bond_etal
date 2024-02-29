track(:,1) = [3,9];
track(:,2) = [10,50];
image = zeros(50,50);

track_intp = interpolate_track_inside(track);
track_intp = unique(track_intp,'rows');

tracks_image = zeros(size(image,1),size(image,2));
for i = 1:size(track_intp,1)
    tracks_image(track_intp(i,2),track_intp(i,1)) = 255;
end
figure()
x = 0:size(tracks_image,2);
y = 0:size(tracks_image,1);
[x,y] = meshgrid(linspace(0,size(tracks_image,2),size(tracks_image,2)),linspace(0,size(tracks_image,1),size(tracks_image,1)));
pcolor(x,y,tracks_image)
hold on
plot(track(:,1),track(:,2))

function track_intp = interpolate_track_inside(track)
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
    xq_1 = linspace(min(x),max(x),dist_x*2);
    yq_1 = slope*xq_1+b;
    yq_2 = linspace(min(y),max(y),dist_y*2);
    xq_2 = (yq_2-b)/slope;
    xq = [xq_1,xq_2];
    yq = [yq_1,yq_2];
end
track_intp = ceil([xq',yq']);
track_intp = unique(track_intp,'rows');
end