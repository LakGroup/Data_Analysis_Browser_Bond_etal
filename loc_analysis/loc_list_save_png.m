function loc_list_save_png(data,map,c_lim)
path = uigetdir(pwd);
if path~=0
    answer = inputdlg({'Pixel Size:','Resolution:'},'Input',[1 50],{'116','20'});
    if isempty(answer)~=1
        pixel_size = str2double(answer{1});
        resolution = str2double(answer{2});
        f=waitbar(0,'Saving Image...');
        for i = 1:length(data)
            color_data = loc_list_to_image(data{i},pixel_size,resolution,map,c_lim);                       
            imwrite(color_data,[fullfile(path,[data{i}.name,num2str(i)]),'.png']);
            waitbar(i/length(data),f,'Saving Image...');
        end
        close(f)
    end
end
end

function color_data = loc_list_to_image(data,pixel_size,resolution,map,c_lim)
points(:,1) = data.x_data;
points(:,2) = data.y_data;
area = data.area;
area(area==0) = 1;
area = log10(area);
area(area<c_lim(1)) = c_lim(1);
area(area>c_lim(2)) = c_lim(2);

if length(unique(area))>1
    area = area./(area+1);
    area = area-min(area);
    area = area/max(area);
    area = floor(area*length(area));
    area(area==0) = 1;
else
    if unique(area)~=0
        area = area/max(area);
        area = floor(area*length(area));
        area(area==0) = 1;
    else
        area(area==0) =1;
    end
end

map = colormap(map);
map_interp = interp1(1:size(map,1),map,linspace(1,size(map,1),length(area)));
points(:,1) = points(:,1)-min(points(:,1));
points(:,2) = points(:,2)-min(points(:,2));
points = round(points*pixel_size/resolution);
points(points==0)=1;

color_data_R = zeros([max(points(:,1)) max(points(:,2))]);
color_data_G = zeros([max(points(:,1)) max(points(:,2))]);
color_data_B = zeros([max(points(:,1)) max(points(:,2))]);
for i=1:size(points,1)
    color_data_R(points(i,1),points(i,2)) = map_interp(area(i),1);
    color_data_G(points(i,1),points(i,2)) = map_interp(area(i),2);
    color_data_B(points(i,1),points(i,2)) = map_interp(area(i),3);    
end
color_data = cat(3, color_data_R, color_data_G, color_data_B);
end