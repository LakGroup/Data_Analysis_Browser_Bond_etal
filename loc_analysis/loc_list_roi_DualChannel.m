function [data_crop,data_outofcrop,Int] = loc_list_roi_DualChannel(data,Int)

global Int

if isempty(Int)
    Int = 1;
end

try
    coordinates = getline();
    data_crop = cell(1,length(data));
    data_outofcrop = cell(1,length(data));
    for i = 1:length(data)
        [data_crop{i},data_outofcrop{i}] = loc_list_crop_inside(data{i},coordinates,Int);
    end
    data_crop = data_crop(~cellfun('isempty',data_crop));
    data_outofcrop = data_outofcrop(~cellfun('isempty',data_outofcrop));
catch
    data_crop = [];
    data_outofcrop = [];
end

Int = Int + 1;
end

function [data_crop,data_outofcrop] = loc_list_crop_inside(data,coordinates,Int)
I = inpolygon(data.x_data,data.y_data,coordinates(:,1),coordinates(:,2));
data_crop.x_data = data.x_data(I);
data_crop.y_data = data.y_data(I);
data_crop.area = data.area(I);
EraseName = ['_OutsideROI_' num2str(Int-1)];
try
    data_crop.name = [erase(data.name,EraseName),'_Cell' num2str(Int)];
catch
    data_crop.name = [erase(data.name,'_OutsideROI'),'_Cell' num2str(Int)];
end
data_crop.type = 'loc_list';

if isfield(data,'identifier')
    data_crop.identifier = data.identifier(I);
end

data_outofcrop.x_data = data.x_data(~I);
data_outofcrop.y_data = data.y_data(~I);
data_outofcrop.area = data.area(~I);
try
    data_outofcrop.name = [erase(data.name,EraseName),'_OutsideROI_' num2str(Int)];
catch
    data_outofcrop.name = [erase(data.name,'_OutsideROI'),'_OutsideROI_' num2str(Int)];
end
data_outofcrop.type = 'loc_list';

if isfield(data,'identifier')
    data_outofcrop.identifier = data.identifier(~I);
end

end