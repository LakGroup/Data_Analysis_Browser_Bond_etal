function data = load_microscopy_file()
%%%%%% file type can be either "bin", "locb" or "csv".
%%%%%% example: data = load_microscopy_file('bin');
%%%%%% example: data = load_microscopy_file('locb');
%%%%%% example: data = load_microscopy_file('csv');
[file_names,path] = uigetfile({'*.bin;*.locb;*.csv'},'Select File(s)','MultiSelect','on');
if isequal(file_names,0)
    data = [];
else
    file_names = cellstr(file_names); 
    f = waitbar(0,'Loading...');
    m = 0;
    for i=1:length(file_names)
        
        if isequal(file_names{i}(end-2:end),'bin')
            file_type = 'bin';
            name = file_names{i}(1:end-4);
        elseif isequal(file_names{i}(end-2:end),'ocb')
            file_type = 'locb';
            name = file_names{i}(1:end-5);
        elseif isequal(file_names{i}(end-2:end),'csv')
            file_type = 'csv';
            name = file_names{i}(1:end-4);
        end
        
        waitbar(i/length(file_names),f,['Loading...',num2str(i),'/',num2str(length(file_names))])  
        try  
            data_read = load_microscopy_file_inside(fullfile(path,file_names{i}),file_type);            
            for k = 1:length(data_read)
%                 data{m+k}.frames = data_read{k}(:,1);
%                 data{m+k}.x_data = data_read{k}(:,2);
%                 data{m+k}.y_data = data_read{k}(:,3);
%                 data{m+k}.z_data = data_read{k}(:,4);
                data{m+k}.x_data = data_read{k}(:,1);
                data{m+k}.y_data = data_read{k}(:,2);
                data{m+k}.area = 0.7+zeros(length(data_read{k}(:,1)),1);
                if length(data_read)>1
                    data{m+k}.name = [name,'_channel_',num2str(k-1)];
                else
                    data{m+k}.name = name;
                end
                data{m+k}.type = 'loc_list';
            end            
            m = length(data);
            clear data_read            
        catch            
            data = [];
            continue
        end
    end
    close(f)
    data = data(~cellfun('isempty',data));    
end
end

function data_read = load_microscopy_file_inside(path,file_type)
if isequal(file_type,'bin')
    data_read = load_bin_inside(path);
elseif isequal(file_type,'locb')
    data_read = load_locb_inside(path);
elseif isequal(file_type,'csv')
    data_read = load_csv_inside(path);
end
end

function data_channel = load_bin_inside(path)
data_read = Insight3(path); 
data_read = data_read.getData();
channels = unique(data_read(:,12));
for i = 1:length(channels)
    I = data_read(:,12) == channels(i);
    data_channel{i} = data_read(I,3:4);
    data_channel{i} = unique(data_channel{i},'rows');
    clear I
end
end

function data_read = load_csv_inside(path)
table = csvread(path,1,0);
channels = unique(table(:,1));
for k = 1:length(channels)
    I = table(:,1)==channels(k);
%     data_read{k} = table(I,[2 8 9 10]);
    data_read{k} = table(I,[8 9]);
    data_read{k} = unique(data_read{k},'rows');    
    clear I
end
end

function data_read = load_locb_inside(path)
dataStructure = loadLocB(path);

list = dataStructure.LocalizationResults;
listCol = values(dataStructure.LocalizationMapping,{'rawX','rawY'});

XY = [list{listCol{1}} list{listCol{2}}];
corPosXY = XY;
offsets = dataStructure.CoordinateOffset;
if ~isempty(offsets)
   frameOffset = dataStructure.DriftFrame;
   frameLoc = dataStructure.LocalizationFrameIndex;
   fstFrame = frameOffset(1);
   for ii = 1:length(frameLoc)
       offInd = frameLoc(ii)-fstFrame+1;
       corPosXY(ii,:) = corPosXY(ii,:) + offsets(offInd);
   end
end
XY = double(corPosXY);

channel_index = dataStructure.ChannelIndex;
channels = unique(channel_index);
for i = 1:length(channels)
    data_read{i} = XY(channel_index==channels(i),:);
    data_read{i} = unique(data_read{i},'rows');
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
    ChannelIndex = typecast(reshape(LocalizationBytes(5,:),[NumLocResults,1]),'int8');
    % Localization Results have mixed data types
    LocResult = cell(1,18);
    for ii = 1:7
        rowInd = 4*(ii-1)+6;
        LocResult{ii} = typecast(reshape(LocalizationBytes(rowInd:rowInd+3,:),[4*NumLocResults,1]),'single');
    end
    LocResult{8} = logical(reshape(LocalizationBytes(35,:),[NumLocResults,1]));
    for ii = 9:16
       rowInd = 4*(ii-9)+35;
       LocResult{ii} = typecast(reshape(LocalizationBytes(rowInd:rowInd+3,:),[4*NumLocResults,1]),'single');
    end
    for ii = 17:18
       rowInd = 4*(ii-17)+67;
       LocResult{ii} = typecast(reshape(LocalizationBytes(rowInd:rowInd+3,:),[4*NumLocResults,1]),'uint32');
    end

    pointerVal = pointerVal+NumLocResults*74;
    NumAcqResults = typecast(rawData.Data(pointerVal:pointerVal+3),'int32');
    pointerVal = pointerVal+4;
    % bug in locBfile?  have to add 4 again to get everything to work
    pointerVal = pointerVal+4;
    
    AcqBytes = reshape(rawData.Data(pointerVal:pointerVal+int64(NumAcqResults*62)-1),[62,NumAcqResults]);
    AcquisitionFrameIndex = typecast(reshape(AcqBytes(1:4,:),[NumAcqResults*4,1]),'int32');
    % initialize Acquisition cell array
    AcqData = cell(1,10);
    AcqData{1} = typecast(reshape(AcqBytes(5:8,:),[NumAcqResults*4,1]),'uint32');
    AcqData{2} = logical(reshape(AcqBytes(9,:),[NumAcqResults,1]));
    AcqData{3} = typecast(reshape(AcqBytes(10:13,:),[NumAcqResults*4,1]),'uint32');
    for ii = 4:8
        rowInd = 8*(ii-4)+14;
        AcqData{ii} = typecast(reshape(AcqBytes(rowInd:rowInd+7,:),[NumAcqResults*8,1]),'double');
    end
    AcqData{9} = logical(reshape(AcqBytes(54,:),[NumAcqResults,1]));
    AcqData{10} = typecast(reshape(AcqBytes(55:62,:),[NumAcqResults*8,1]),'double');
    
    LocalizationKeyset = {'rawX','rawY','rawZ','sigma_x','sigma_y','intensity',...
        'background','is_valid','CRLB_x','CRLB_y','CRLB_I','CRLB_bg',...
        'CRLB_sigma_x','CRLB_sigma_y','logLikelihood','LLR_pValue',...
        'spotDetect_x','spotDetect_y'};
    AcquisitionKeySet = {'versionNumber','hasCameraFrameIndex','frameIndex',...
        'stagePositionIn_uM_x','stagePositionIn_uM,y','stagePositionIn_uM_z',...
        'illuminationAngleInDegrees','temperatureInCelsius','outOfRangeAccelerationDetected'};
    LocalizationResultsMap = containers.Map(LocalizationKeyset,1:18);
    AcquisitionMap = containers.Map(AcquisitionKeySet,1:9);
    
    % read out information here
    out.header = header';
    out.version = version;
    out.drift = DriftFlag;
    out.numDriftResults = NumDrift;
    out.DriftFrame = DriftFrame;
    out.CoordinateOffset = CoordinateOffset;
    out.numLocResults = NumLocResults;
    out.LocalizationFrameIndex = LocalizationFrameIndex;
    out.ChannelIndex = ChannelIndex;
    out.LocalizationResults = LocResult;
    out.LocalizationMapping = LocalizationResultsMap;
    out.numAcqResults = NumAcqResults;
    out.AcquisitionFrameIndex = AcquisitionFrameIndex;
    out.AcquisitionData = AcqData;
    out.AcquisitionMapping = AcquisitionMap;
end