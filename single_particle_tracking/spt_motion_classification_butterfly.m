function spt_motion_classification_butterfly(data)
input_values = inputdlg({'spatial threshold','distance threshold:'},'',1,{'1.5','8'});
if isempty(input_values)==1
    return
else
    spatial_threshold = str2double(input_values{1});
    distance_threshold = str2double(input_values{2});
    
    not_butterfly_motions = cell(1,length(data)); 
    butterfly_motions = cell(1,length(data));    
    
    for i = 1:length(data)
        f = waitbar(0,'calculating...');
        for j = 1:length(data{i}.tracks)
            is_buttefly = frame_to_frame_jump(data{i}.tracks{j},spatial_threshold,distance_threshold);            
            if is_buttefly == 1
                butterfly_motions{i} = [butterfly_motions{i} j];
            else
                not_butterfly_motions{i} = [not_butterfly_motions{i} j];
            end
            waitbar(j/length(data{i}.msd),f,'calculating...')
        end
        close(f)        
    end
    
    for i = 1:length(data)       
        data_not_butterfly{i}.tracks = data{i}.tracks(not_butterfly_motions{i});
        data_not_butterfly{i}.msd = data{i}.msd(not_butterfly_motions{i});
        data_not_butterfly{i}.name = [data{i}.name,'_not_butterflies'];
        data_not_butterfly{i}.type = 'spt';               
        
        data_butterfly{i}.tracks = data{i}.tracks(butterfly_motions{i});
        data_butterfly{i}.msd = data{i}.msd(butterfly_motions{i});
        data_butterfly{i}.name = [data{i}.name,'_butterflies'];
        data_butterfly{i}.type = 'spt';
    end
    spt_plot(horzcat(data_not_butterfly,data_butterfly));
    
    for i = 1:length(data)
        motion_percentage(i,1) = length(data_butterfly{i}.tracks)/length(data{i}.tracks);
        motion_percentage(i,2) = length(data_not_butterfly{i}.tracks)/length(data{i}.tracks);
        names{i} = data{i}.name;
    end
    columns_name = {'butterfly motion','not-butterfly motion'};
    figure('name','motion class percentage','NumberTitle','off','units','normalized','position',[0 0.1 1 0.4],'menubar','none','toolbar','figure');
    uitable('Data',motion_percentage,'units','normalized','position',[0.05 0.05 0.95 0.95],'FontSize',12,'RowName',names,'ColumnName',columns_name);
end
end

function K = frame_to_frame_jump(data,spatial_threshold,distance_threshold)
for i = 1:size(data,1)-1
    jumps(i,1) = pdist(data(i:i+1,2:3));    
end
I = any(jumps>mean(jumps)+spatial_threshold*std(jumps));
J = sum(jumps)>distance_threshold+mean(jumps);
K = I & J;
end