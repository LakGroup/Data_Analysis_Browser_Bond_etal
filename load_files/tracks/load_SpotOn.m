function data_load = load_SpotOn()
[files,path] = uigetfile('*.mat','select SpotOn .mat Files(s)','MultiSelect','on');
if path~=0
    if iscell(files)
        f = waitbar(0,'Loading Files');
        for i=1:size(files,2)
            trackedPar = load([path,files{i}],'trackedPar');            
            data_load{i}.tracks = convert_trackedPar_to_tracks(trackedPar);
            data_load{i}.name = files{i}(1:end-4);
            data_load{i}.type = 'spt';
            clear trackedPar
            waitbar(i/size(files,2),f,'Loading Files');
        end
        close(f)
    else
        trackedPar = load([path,files],'trackedPar'); 
        data_load{1}.tracks = convert_trackedPar_to_tracks(trackedPar);
        data_load{1}.name = files(1:end-4);
        data_load{1}.type = 'spt';
        clear trackedPar
    end
else
    data_load = [];
end
end

function tracks = convert_trackedPar_to_tracks(data)
data = data.trackedPar;
for i = 1:length(data)
    tracks{i,1}(:,2:3) = data(i).xy;
    tracks{i,1}(:,1) = data(i).TimeStamp;    
end
end