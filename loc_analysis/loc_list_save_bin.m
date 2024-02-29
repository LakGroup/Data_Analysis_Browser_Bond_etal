function loc_list_save_bin(data)
path = uigetdir(pwd);
if path~=0    
    for i = 1:length(data)
        f = waitbar(0,['Saving .bin File',num2str(i),'/',num2str(length(data))]);
        save_to = fullfile(path,[data{i}.name,num2str(i),'.bin']);
        data_save(:,1) = data{i}.x_data; %x
        data_save(:,2) = data{i}.y_data; %y
        data_save(:,3) = data{i}.x_data; %xc
        data_save(:,4) = data{i}.y_data; %xc
        data_save(:,5) = 100; %height
        data_save(:,6) = 10000; %area
        data_save(:,7) = 300; %width
        data_save(:,8) = 0; %phi
        data_save(:,9) = 1; %aspect
        data_save(:,10) = 0; %background
        data_save(:,11) = 10000; %intensity
        data_save(:,12) = 1; %channel
        data_save(:,13) = 1; %fitIterations
        data_save(:,14) = 1; %frame
        data_save(:,15) = 1; %trackLength
        data_save(:,16) = -1; %link
        data_save(:,17) = 0; %z
        data_save(:,18) = 0; %zc
        waitbar(0.5,f,['Saving .bin File',num2str(i),'/',num2str(length(data))]);
        i3 = Insight3();
        i3.setData(data_save);
        try
            i3.write(save_to);
        catch
            msgbox('file not saved, already exists')
        end
        waitbar(1,f,['Saving .bin File',num2str(i),'/',num2str(length(data))]);
        close(f)
       clear data_save 
    end
end
end