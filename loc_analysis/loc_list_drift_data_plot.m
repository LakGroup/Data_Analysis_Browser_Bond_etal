function loc_list_drift_data_plot(data)

error = 0;
checkField = cellfun(@(x) isfield(x,'Frames'),data);

if any(checkField == 0)
    msgbox("The data needs to have the ''Frames'' field included.");
    error = 1;
end

if numel(data) > 2 || numel(data) < 1
    msgbox("The data can only have 1 or 2 data sets included.");
    error = 1;
end

if error ~= 1

    answer = inputdlg({'Frames per bin:'},'Input',[1 50],{'250'});
    framesPerPlot = str2double(answer{1});

    figure;
    for i = 1:numel(data)
        nPlots = ceil(max(data{i}.Frames)/framesPerPlot);
        CMap = interp1([0;1],[0 1 0; 1 0 0],linspace(0,1,nPlots));

        for k = 1:nPlots
            Idx = (k-1)*framesPerPlot+1:k*framesPerPlot;

            if numel(data) == 1
                plot(data{i}.x_data(ismember(data{i}.Frames,Idx)),data{i}.y_data(ismember(data{i}.Frames,Idx)),'.','Color',CMap(k,:));hold on;
            elseif numel(data) == 2
                subplot(1,2,i);plot(data{i}.x_data(ismember(data{i}.Frames,Idx)),data{i}.y_data(ismember(data{i}.Frames,Idx)),'.','Color',CMap(k,:));hold on;
            end
        end

        if numel(data) == 1
            axis equal;
            title(data{i}.name)
        elseif numel(data) == 2
            subplot(1,2,1);axis equal;ax1 = gca;title(data{1}.name)
            subplot(1,2,2);axis equal;ax2 = gca;title(data{2}.name)
            linkaxes([ax1 ax2]);
        end
    end
end

end