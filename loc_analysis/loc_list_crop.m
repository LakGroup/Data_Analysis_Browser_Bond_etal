function loc_list_crop(data)
try
    coordinates = getrect();
    data_crop = cell(1,length(data));
    for i = 1:length(data)
        data_crop{i} = loc_list_crop_inside(data{i},coordinates);
    end
    data_crop = data_crop(~cellfun('isempty',data_crop));
    
catch
    data_crop = [];    
end
loc_list_plot(data_crop)
end

function data_crop = loc_list_crop_inside(data,coordinates)
x1 = coordinates(1);
x2 = x1+coordinates(3);
y1 = coordinates(2);
y2 = y1+coordinates(4);
I1 = min(x1,x2);
I2 = max(x1,x2);
I3 = min(y1,y2);
I4 = max(y1,y2);
if I1==I2 || I3==I4
    data_crop = [];
else
    x_find = find(data.x_data>=I1 & data.x_data<=I2);
    y_find = find(data.y_data>=I3 & data.y_data<=I4);
    I = intersect(x_find,y_find);
    if ~isempty(data.x_data(I))
        data_crop.x_data = data.x_data(I);
        data_crop.y_data = data.y_data(I);
        data_crop.area = data.area(I);
        data_crop.name = [data.name,'_cropped'];
        data_crop.type = 'loc_list';
    else
        data_crop = [];
    end
end
end