clear;clc;close all
[file_name,path] = uigetfile('*.locb','Select .txt File(s)','MultiSelect','on');
if path~=0
    file_name = cellstr(file_name);
    [file,path_excel] = uiputfile('*.xlsx');
    if path_excel~=0
        save_to = fullfile(path_excel,file);
        for i = 1:length(file_name)
            locs_per_frame = load_locb_inside(fullfile(path,file_name{i}));
            plot(locs_per_frame)
            xlabel('Frame Number')
            ylabel('Number of Localizations per Frame')
            title(regexprep(file_name{i},'_',' '))
            drawnow
            data_table = array2table(locs_per_frame');            
            writetable(data_table,save_to,'sheet',regexprep(file_name{i},'_',' '))
            clear locs_per_frame data_table   
        end
    end
end

function locs_per_frame = load_locb_inside(dataPath)
dataStructure = loadLocB(dataPath);
frames = dataStructure.LocalizationFrameIndex;
to_look = frames(1);
number_of_locs = 1;
counter = 0;
for i = 2:length(frames)
    if frames(i)==to_look
       number_of_locs = number_of_locs+1;
    else
        to_look = frames(i);
        counter = counter+1;
        locs_per_frame(counter) = number_of_locs;
        number_of_locs = 1;
    end    
end
end

function out = loadLocB(fileLoc)
    % using memmapfile function for this iteration
    rawData = memmapfile(fileLoc);
    
    header = char(rawData.Data(1:8));
    version = typecast(rawData.Data(9:12),'int32');
    DriftFlag = logical(rawData.Data(13));
    NumDrift = typecast(rawData.Data(14:21),'int64');
    
    pointerVal = 22;
    if DriftFlag
        DriftBytes = reshape(rawData.Data(pointerVal:NumDrift*12+pointerVal-1),[12,NumDrift]);
        DriftFrame = typecast(reshape(DriftBytes(1:4,:),[4*NumDrift,1]),'int32'); % frames with drift correction
        CoordinateOffset = [typecast(reshape(DriftBytes(5:8,:),[4*NumDrift,1]),'single'), ...
            typecast(reshape(DriftBytes(9:12,:),[4*NumDrift,1]),'single')];
    else
        DriftFrame = [];
        CoordinateOffset = [];
     end
    pointerVal = pointerVal+NumDrift*12;
    NumLocResults = typecast(rawData.Data(pointerVal:pointerVal+7),'int64');
    pointerVal = pointerVal+8;
    LocalizationBytes = reshape(rawData.Data(pointerVal:pointerVal+NumLocResults*74-1),[74,NumLocResults]);
    LocalizationFrameIndex = typecast(reshape(LocalizationBytes(1:4,:),[4*NumLocResults,1]),'int32');
    out.LocalizationFrameIndex = LocalizationFrameIndex;
end