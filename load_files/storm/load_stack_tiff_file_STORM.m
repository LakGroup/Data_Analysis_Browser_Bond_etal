function data_load = load_stack_tiff_file_STORM()
[file_name,path] = uigetfile({'*.tif';'*.tiff'},'Select TIFF File(s)','MultiSelect','on');
if isequal(file_name,0)
    data_load=[];
else
    file_name=cellstr(file_name);
    input_values = inputdlg({'steps'},'',1,{'100'});
    if isempty(input_values)==1
        return
    else
        step = str2double(input_values{1});
        for i = 1:length(file_name)
            try                
                [data_load_storm{i},data_load_conv{i}] = load_tiff_STORM(path,file_name{i},step);
            catch
                msgbox(strcat('data should be a stack tiff image'));
                data_load=[];
            end
        end
        try
            data_load = data_load_storm;
        catch
            data_load = [];
        end
    end
end
end

function [data_load_storm,data_load_conv] = load_tiff_STORM(path,file_name,step)
info = imfinfo(fullfile(path,file_name));
N=numel(info);
f=waitbar(0,'Please wait...');
for i =1:N
    image{i} = imread(fullfile(path,file_name),i);
    waitbar(i/N,f,'Please wait...');
end
close(f)

x = 1:step:N;
if x(end)~=N
    x(end+1) = N;
end
for j = 1:length(x)-1
    image_wanted{j} = image(x(j):x(j+1)-1);
end
image_conventional = image_wanted(1:2:end);
image_storm = image_wanted(2:2:end);

data_load_conv{1}.image = horzcat(image_conventional{:});
data_load_conv{1}.name = [file_name(1:end-4),'_',num2str(i)];
data_load_conv{1}.type = 'image';
data_load_conv{1}.info = 'NaN';

data_load_storm.image = horzcat(image_storm{:});
data_load_storm.name = [file_name(1:end-4),'_',num2str(i)];
data_load_storm.type = 'image';
data_load_storm.info = 'NaN';
end