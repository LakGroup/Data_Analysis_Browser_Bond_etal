function data_load = load_image()
[file_name,path] = uigetfile({'*.jpg;*.png;*.jpg;*.tif;*.tiff;*.jpeg'},'Select Image File(s)','MultiSelect','on');
if isequal(file_name,0)
    data_load=[];
else
    file_name = cellstr(file_name);
    f=waitbar(0,'Loading Image(s)...');    
    for i = 1:length(file_name)
        waitbar(i/length(file_name),f,['Loading...',num2str(i),'/',num2str(length(file_name))]) 
        try
            data_load{i} = load_image_file(path,file_name{i});
        catch            
            data_load{i} = [];
        end
    end
    data_load = data_load(~cellfun('isempty',data_load));
    close(f)
end
end

function data_load = load_image_file(path,file_name)
info = imfinfo(fullfile(path,file_name));
N = numel(info);
if N>1
    for i =1:N
        image{i} = imread(fullfile(path,file_name),i);
    end
else
    image{1} = imread(fullfile(path,file_name));
end
data_load.image = image;
data_load.name = file_name(1:end-4);
data_load.type = 'image';
data_load.info = 'NaN';
end