function [data_crop,data_outofcrop] = loc_list_roi(data)
try
    coordinates = getline();
    data_crop = cell(1,length(data));
    data_outofcrop = cell(1,length(data));
    for i = 1:length(data)
        [data_crop{i},data_outofcrop{i}] = loc_list_crop_inside(data{i},coordinates);
    end
    data_crop = data_crop(~cellfun('isempty',data_crop));
    data_outofcrop = data_outofcrop(~cellfun('isempty',data_outofcrop));
catch
    data_crop = [];
    data_outofcrop = [];
end
end

function [data_crop,data_outofcrop] = loc_list_crop_inside(data,coordinates)
I = inpolygon(data.x_data,data.y_data,coordinates(:,1),coordinates(:,2));
data_crop.x_data = data.x_data(I);
data_crop.y_data = data.y_data(I);
data_crop.area = data.area(I);
data_crop.name = [data.name,'_InsideROI'];
data_crop.type = 'loc_list';

data_outofcrop.x_data = data.x_data(~I);
data_outofcrop.y_data = data.y_data(~I);
data_outofcrop.area = data.area(~I);
data_outofcrop.name = [data.name,'_OutsideROI'];
data_outofcrop.type = 'loc_list';
end