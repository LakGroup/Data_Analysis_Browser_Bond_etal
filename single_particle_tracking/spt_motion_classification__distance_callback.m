function spt_motion_classification__distance_callback(data)
input_values = inputdlg({'distance threshold:'},'',1,{'0.5'});
if isempty(input_values)==1
    return
else
    distance_threshold = str2double(input_values{1});    
    
    above_threshold = cell(1,length(data));
    below_threshold = cell(1,length(data));
    
    for i = 1:length(data)
        f = waitbar(0,'Finding Total Distance Traveled');
        for j = 1:length(data{i}.tracks)
            distance = sqrt((data{i}.tracks{j}(end,2)-data{i}.tracks{j}(1,2))^2+(data{i}.tracks{j}(end,3)-data{i}.tracks{j}(1,3))^2);
            if distance>=distance_threshold                
                above_threshold{i} = [above_threshold{i} j];
            else 
                below_threshold{i} = [below_threshold{i} j];                
            end            
            waitbar(j/length(data{i}.msd),f,'Finding Total Distance Traveled')
        end
        close(f)
    end
    
    for i = 1:length(data)       
        data_below{i}.msd = data{i}.msd(below_threshold{i});
        data_below{i}.name = [data{i}.name,'_below'];
        data_below{i}.tracks = data{i}.tracks(below_threshold{i});
        data_below{i}.type = 'spt';
               
        data_above{i}.msd = data{i}.msd(above_threshold{i});
        data_above{i}.tracks = data{i}.tracks(above_threshold{i});
        data_above{i}.name = [data{i}.name,'_above'];
        data_above{i}.type = 'spt';
    end
    spt_plot(horzcat(data_below,data_above)); 
    
    for i = 1:length(data)
        motion_percentage(i,1) = length(data_above{i}.tracks)/length(data{i}.tracks);
        motion_percentage(i,2) = length(data_below{i}.tracks)/length(data{i}.tracks);
        names{i} = data{i}.name;
    end
    columns_name = {'Above Threshold','Below Threshold'};
    figure('name','motion class percentage','NumberTitle','off','units','normalized','position',[0 0.1 1 0.4],'menubar','none','toolbar','figure');
    uitable('Data',motion_percentage,'units','normalized','position',[0.05 0.05 0.95 0.95],'FontSize',12,'RowName',names,'ColumnName',columns_name);
end
end