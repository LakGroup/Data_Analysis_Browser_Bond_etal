function spt_motion_classification_points(data)
[nFramesPerTrack,~] = cellfun(@size,data{1}.tracks,'UniformOutput',false);
maxPoints = max(vertcat(nFramesPerTrack{:}));
input_values = inputdlg({'r2 threshold',['Number of data points to fit (0 - ' num2str(maxPoints) '):'],'confined motion slope threshold (<):','directed motion slope threshold (>=):'},'',1,{'0.8','0','0.8','1.2'});
if isempty(input_values)==1
    return
else
    r2_threshold = str2double(input_values{1});
    nPoints = str2double(input_values{2});
    confined_threshold = str2double(input_values{3});
    directed_threshold = str2double(input_values{4});
    
    directed_motions = cell(1,length(data));
    confided_motions = cell(1,length(data));
    brownian_motions = cell(1,length(data));
    below_r2 = cell(1,length(data));
    
    for i = 1:length(data)
        f = waitbar(0,['Fitting Linear Function - data ' num2str(i) ' of ' num2str(length(data))]);
        for j = 1:length(data{i}.msd)
            [slope,r2] = fit_linear_points(data{i}.msd{j},nPoints);
            if r2>=r2_threshold
                if slope>=directed_threshold
                    directed_motions{i} = [directed_motions{i} j];
                elseif slope<confined_threshold
                    confided_motions{i} = [confided_motions{i} j];
                else
                    brownian_motions{i} = [brownian_motions{i} j];
                end
            else
                below_r2{i} = [below_r2{i} j];
            end
            waitbar(j/length(data{i}.msd),f,['Fitting Linear Function - data ' num2str(i) ' of ' num2str(length(data))])
        end
        close(f)
    end
    
    for i = 1:length(data)       
        data_confined{i}.msd = data{i}.msd(confided_motions{i});
        data_confined{i}.name = [data{i}.name,'_confined'];
        data_confined{i}.tracks = data{i}.tracks(confided_motions{i});
        data_confined{i}.type = 'spt';
        
        
        data_brownian{i}.msd = data{i}.msd(brownian_motions{i});
        data_brownian{i}.tracks = data{i}.tracks(brownian_motions{i});
        data_brownian{i}.name = [data{i}.name,'_brownian'];
        data_brownian{i}.type = 'spt';        
               
        data_directed{i}.msd = data{i}.msd(directed_motions{i});
        data_directed{i}.tracks = data{i}.tracks(directed_motions{i});
        data_directed{i}.name = [data{i}.name,'_directed'];
        data_directed{i}.type = 'spt';
       
        data_below_r2{i}.msd = data{i}.msd(below_r2{i});
        data_below_r2{i}.tracks = data{i}.tracks(below_r2{i});
        data_below_r2{i}.name = [data{i}.name,'_below_r2'];
        data_below_r2{i}.type = 'spt';        
        
    end
    spt_plot(horzcat(horzcat(horzcat(data_confined,data_brownian),data_directed),data_below_r2)); 
    
    for i = 1:length(data)
        motion_percentage(i,1) = length(data_brownian{i}.tracks)/length(data{i}.tracks);
        motion_percentage(i,2) = length(data_directed{i}.tracks)/length(data{i}.tracks);
        motion_percentage(i,3) = length(data_confined{i}.tracks)/length(data{i}.tracks);
        motion_percentage(i,4) = length(data_below_r2{i}.tracks)/length(data{i}.tracks);
        names{i} = data{i}.name;
    end
    columns_name = {'brownian motion','directed motion','confined motion','below_r2'};
    figure('name','motion class percentage','NumberTitle','off','units','normalized','position',[0 0.1 1 0.4],'menubar','none','toolbar','figure');
    uitable('Data',motion_percentage,'units','normalized','position',[0.05 0.05 0.95 0.95],'FontSize',12,'RowName',names,'ColumnName',columns_name);
end
end

function [slope,r2] = fit_linear_points(data,nPoints)
ft = fittype('a*x + b');
if size(data,1)>=nPoints
    data_to_fit = data(1:nPoints,:);
else
    data_to_fit = data;
end
[fo, gof] = fit(data_to_fit(:,1), data_to_fit(:,2), ft, 'StartPoint', [0 0]);
slope = fo.a;
r2 = gof.rsquare;
end