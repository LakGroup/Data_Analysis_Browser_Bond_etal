function Locs_PatternAnalysis_Module()

% Use data and listbox as global variables (access from anywhere).
global data listbox

% Make a new figure, and set its properties.
figure();
set(gcf,'name','Coloc Pattern Analysis Module','NumberTitle','off','color','k','units','normalized','position',[0.25 0.2 0.5 0.6],'menubar','none','toolbar','figure');

% Add push buttons to the created figure, that allow the user to set the
% reference data, the colocalization data, and start the actual
% colocalization.
uicontrol('style','pushbutton','units','normalized','position',[0,0.95,0.2,0.05],'string','Set Reference Data','ForegroundColor','b','Callback',{@set_reference_data_callback},'FontSize',12);
uicontrol('style','pushbutton','units','normalized','position',[0.2,0.95,0.2,0.05],'string','Set Other Channel','ForegroundColor','b','Callback',{@set_colocalization_data_callback},'FontSize',12);
uicontrol('style','pushbutton','units','normalized','position',[0.4,0.95,0.2,0.05],'string','Start Extraction','ForegroundColor','b','Callback',{@colocalization_callback},'FontSize',12);

% Make the reference data and the colocalization data matrices empty.
data_reference = [];
data_colocalization = [];

    % Create a function for when the button of setting the reference data
    % is being pushed.
    function set_reference_data_callback(~,~,~)
        % Extract the value(s) of the list to select the reference data.
        listbox_value = listbox.Value;
        
        % If the data was not empty (empty session), then the reference
        % data is extracted, and being plotted in the figure opened at the
        % start of this module.
        if ~isempty(data)
            data_reference = data(listbox_value); % Extract the reference data.
            plot_inside_data_reference(data_reference); % Plot the reference data.
        end
    end

    % Create a function for when the button of setting the colocalization
    % data is being pushed.
    function set_colocalization_data_callback(~,~,~)
        % Extract the value(s) of the list to select the reference data.
        listbox_value = listbox.Value;
        
        % If the data was not empty (empty session), then the
        % colocalization data is extracted, and being plotted in the figure
        % opened at the start of this module.
        if ~isempty(data)
            data_colocalization = data(listbox_value); % Extract the colocalization data.
            plot_inside_data_colocalization(data_colocalization);  % Plot the colocalization data.
        end
    end

    % Create a function for when the button of starting the colocalization
    % module is being pressed.
    function colocalization_callback(~,~,~)
        % Show a nice input dialog, to select all the parameters used in
        % the colocalization.
        input_values = InputDialog;
        
        % If cancel is being pressed, stop here. Else, continue the
        % colocalization module.
        if isempty(input_values)
            return
        else
            % Extract the expansion factor used.
            minPoints = str2double(input_values{1});
            Epsilon = str2double(input_values{2});
            PixelSize = str2double(input_values{3});
            PostProcess = str2double(input_values{4});
            minLocs = str2double(input_values{5});
            minArea = str2double(input_values{6});

            [file,path] = uiputfile('Pattern_Analysis.xlsx','Please specify a name to save the statistics as'); % Extract the name of the file given.
            name = fullfile(path,file); % Make it a full name to save it as later.

            if exist(name,'file') == 2
                delete(name);
            end

            if PostProcess == 1
                name_postprocess = [name(1:end-5) '_PostProcessed_' num2str(minLocs) 'minLocs_' num2str(minArea) 'minArea.xlsx']; % Make it a full name to save it as later.
    
                if exist(name_postprocess,'file') == 2
                    delete(name_postprocess);
                end
            end
            
            % Check if the reference and colocalization data sets are not
            % empty. If they are not, continue the analysis, else, show an
            % error message.
            if ~isempty(data_reference) && ~isempty(data_colocalization)
                % Check if the lengths of the reference and colocalization
                % data sets are the same. If not, display an error.
                if length(data_reference)==length(data_colocalization)
                    data_Coloc_Clustered = cell(length(data_reference),1);
                    data_ClusteredAS = cell(length(data_reference),1);
                    data_ClusteredDB = cell(length(data_reference),1);
                    TableCell = cell(length(data_reference),1);
                    data_ClusteredAS_postprocess = cell(length(data_reference),1);
                    data_ClusteredDB_postprocess = cell(length(data_reference),1);
                    TableCell_postprocess = cell(length(data_reference),1);
                    
                    AverageNumClustersAS = NaN(length(data_reference),1);
                    AverageAreaPerClusterAS = NaN(length(data_reference),1);
                    AverageRadiusAS = NaN(length(data_reference),1);
                    AveragePercentCoveredAS = NaN(length(data_reference),1);
                    AveragePercentClusteredAS = NaN(length(data_reference),1);
                    AverageNumClustersDB = NaN(length(data_reference),1);
                    AverageAreaPerClusterDB = NaN(length(data_reference),1);
                    AverageRadiusDB = NaN(length(data_reference),1);
                    AveragePercentCoveredDB = NaN(length(data_reference),1);
                    AveragePercentClusteredDB = NaN(length(data_reference),1);

                    if PostProcess == 1
                        AverageNumClustersAS_postprocess = NaN(length(data_reference),1);
                        AverageAreaPerClusterAS_postprocess = NaN(length(data_reference),1);
                        AverageRadiusAS_postprocess = NaN(length(data_reference),1);
                        AveragePercentCoveredAS_postprocess = NaN(length(data_reference),1);
                        AveragePercentClusteredAS_postprocess = NaN(length(data_reference),1);
                        AverageNumClustersDB_postprocess = NaN(length(data_reference),1);
                        AverageAreaPerClusterDB_postprocess = NaN(length(data_reference),1);
                        AverageRadiusDB_postprocess = NaN(length(data_reference),1);
                        AveragePercentCoveredDB_postprocess = NaN(length(data_reference),1);
                        AveragePercentClusteredDB_postprocess = NaN(length(data_reference),1);
                    end

                    row_names = cell(length(data_reference),1);
                    column_names = {'alphaShape: Avg. #clusters','alphaShape: Avg. Clustered Locs (%)','alphaShape: Avg. Indiv. clusterarea (µm²)','alphaShape: Avg. cluster diameter (µm)','alphaShape: Avg. total area of Ref covered (%)','DB Scan: Avg. #clusters','DB Scan: Avg. Clustered Locs (%)','DB Scan: Avg. Indiv. clusterarea (µm²)','DB Scan: Avg. cluster diameter (µm)','DB Scan: Avg. total area of Ref covered (%)'};
                    column_names_NoAS = {'DB Scan: Avg. #clusters','DB Scan: Avg. Clustered Locs (%)','DB Scan: Avg. Indiv. clusterarea (µm²)','DB Scan: Avg. cluster diameter (µm)','DB Scan: Avg. total area of Ref covered (%)'};
                    title = 'Pattern Analysis Output'; % Set the title.
                    title_postprocess = ['Pattern Analysis Output - After PostProcess: ' num2str(minLocs) 'minLocs; ' num2str(minArea) 'minArea']; % Set the title.

                    VariableNames = {'Name','Ref_Cluster_ID','Ref_#Locs','Ref_Area_µm²','Ref_Density_#locs/µm²','Coloc_#LocsInside','Coloc_Density_#locs/µm²',' ','alphaShape_ID','Total_alphaShape_Clusters','alphaShape_Perc_Locs_Clustered_%','alphaShape_Density_Locs_Unclustered_#locs/µm²','alphaShape_TotalArea_µm²','alphaShape_TotalRefAreaCovered_%','alphaShape_TotalDiameter_µm','alphaShape_#LocsInCluster','alphaShape_ClusterArea_µm²','alphaShape_ClusterDiameter_µm',' ','DBScan_ID','Total_DBScan_Clusters','DBScan_Perc_Locs_Clustered_%','DBScan_Density_Locs_Unclustered_#locs/µm²','DBScan_TotalArea_µm²','DBScan_TotalRefAreaCovered_%','DBScan_TotalDiameter_µm','DBScan_#LocsInCluster','DBScan_ClusterArea_µm²','DBScan_ClusterDiameter_µm'};
                    VariableNames_NoAS = {'Name','Ref_Cluster_ID','Ref_#Locs','Ref_Area_µm²','Ref_Density_#locs/µm²','Coloc_#LocsInside','Coloc_Density_#locs/µm²',' ','DBScan_ID','Total_DBScan_Clusters','DBScan_Perc_Locs_Clustered_%','DBScan_Density_Locs_Unclustered_#locs/µm²','DBScan_TotalArea_µm²','DBScan_TotalRefAreaCovered_%','DBScan_TotalDiameter_µm','DBScan_#LocsInCluster','DBScan_ClusterArea_µm²','DBScan_ClusterDiameter_µm'};
                    
                    % Start doing the actual calculations.
                    % Loop over the different reference data sets, and
                    % perform the colocalization (and postprocessing and
                    % statistics if selected).
                    for i = 1:length(data_reference)
                        % Perform the actual calculations.
                        counter = [i length(data_reference)]; % Set up the counter for the wait bar.
                        [data_Coloc_Clustered{i},data_ClusteredAS{i},data_ClusteredDB{i},data_ClusteredAS_postprocess{i},data_ClusteredDB_postprocess{i},TableCell{i},TableCell_postprocess{i}] = do_pattern_analysis(data_reference{i},data_colocalization{i},minPoints,Epsilon,PixelSize,PostProcess,minLocs,minArea,counter); % See inner function for more explanation.

                        Groups = [find(~isnan(TableCell{i}(:,1))); size(TableCell{i},1)+1];
                        SummaryInfo = cell(numel(Groups)-1,2);
                        for j = 1:numel(Groups)-1
                            SummaryInfo{j,1} = TableCell{i}(Groups(j):Groups(j+1)-1,9);
                            SummaryInfo{j,2} = TableCell{i}(Groups(j):Groups(j+1)-1,20);
                        end
                        AverageNumClustersAS(i) = sum(cellfun(@(x) max(x),SummaryInfo(:,1))) / numel(SummaryInfo(:,1));
                        AverageNumClustersDB(i) = sum(cellfun(@(x) max(x),SummaryInfo(:,2))) / numel(SummaryInfo(:,1));

                        AverageAreaPerClusterAS(i) = mean(TableCell{i}(:,15),'omitnan');
                        AverageAreaPerClusterDB(i) = mean(TableCell{i}(:,25),'omitnan');

                        AverageRadiusAS(i) = mean(TableCell{i}(:,16),'omitnan');
                        AverageRadiusDB(i) = mean(TableCell{i}(:,26),'omitnan');

                        AveragePercentCoveredAS(i) = mean(TableCell{i}(:,12),'omitnan');
                        AveragePercentCoveredDB(i) = mean(TableCell{i}(:,22),'omitnan');

                        AveragePercentClusteredAS(i) = mean(TableCell{i}(:,9),'omitnan');
                        AveragePercentClusteredDB(i) = mean(TableCell{i}(:,19),'omitnan');

                        row_names{i} = data_reference{i}.name;

                        TableCell{i} = vertcat(cell(1,29),horzcat(cell(size(TableCell{i},1),1),num2cell(TableCell{i})));
                        TableCell{i}{1,1} = row_names{i};
                        TableCell{i} = cell2table(TableCell{i});
                        TableCell{i}.Properties.VariableNames = VariableNames;

                        if PostProcess
                            Groups = [find(~isnan(TableCell_postprocess{i}(:,1))); size(TableCell_postprocess{i},1)+1];
                            SummaryInfo = cell(numel(Groups)-1,2);
                            for j = 1:numel(Groups)-1
                                SummaryInfo{j,1} = TableCell_postprocess{i}(Groups(j):Groups(j+1)-1,9);
                                SummaryInfo{j,2} = TableCell_postprocess{i}(Groups(j):Groups(j+1)-1,20);
                            end
                            AverageNumClustersAS_postprocess(i) = sum(cellfun(@(x) max(x),SummaryInfo(:,1))) / numel(SummaryInfo(:,1));
                            AverageNumClustersDB_postprocess(i) = sum(cellfun(@(x) max(x),SummaryInfo(:,2))) / numel(SummaryInfo(:,1));

                            AverageAreaPerClusterAS_postprocess(i) = mean(TableCell_postprocess{i}(:,16),'omitnan');
                            AverageAreaPerClusterDB_postprocess(i) = mean(TableCell_postprocess{i}(:,27),'omitnan');

                            AverageRadiusAS_postprocess(i) = mean(TableCell_postprocess{i}(:,17),'omitnan');
                            AverageRadiusDB_postprocess(i) = mean(TableCell_postprocess{i}(:,28),'omitnan');

                            AveragePercentCoveredAS_postprocess(i) = mean(TableCell_postprocess{i}(:,13),'omitnan');
                            AveragePercentCoveredDB_postprocess(i) = mean(TableCell_postprocess{i}(:,27),'omitnan');

                            AveragePercentClusteredAS_postprocess(i) = mean(TableCell_postprocess{i}(:,10),'omitnan');
                            AveragePercentClusteredDB_postprocess(i) = mean(TableCell_postprocess{i}(:,21),'omitnan');

                            row_names{i} = data_reference{i}.name;

                            TableCell_postprocess{i} = vertcat(cell(1,29),horzcat(cell(size(TableCell_postprocess{i},1),1),num2cell(TableCell_postprocess{i})));
                            TableCell_postprocess{i}{1,1} = row_names{i};
                            TableCell_postprocess{i} = cell2table(TableCell_postprocess{i});
                            TableCell_postprocess{i}.Properties.VariableNames = VariableNames;
                        end

                    end
                    QuickMaths = [round(AverageNumClustersAS,2) round(AveragePercentClusteredAS,2) AverageAreaPerClusterAS AverageRadiusAS round(AveragePercentCoveredAS,2) round(AverageNumClustersDB,2) round(AveragePercentClusteredDB,2) AverageAreaPerClusterDB AverageRadiusDB round(AveragePercentCoveredDB,2)];
                    QuickMaths_NoAS = [round(AverageNumClustersDB,2) round(AveragePercentClusteredDB,2) AverageAreaPerClusterDB AverageRadiusDB round(AveragePercentCoveredDB,2)];
%                     table_data_plot(QuickMaths,row_names,column_names,title); % Show the table.
                    table_data_plot(QuickMaths_NoAS,row_names,column_names_NoAS,title); % Show the table.
                    if PostProcess == 1
                        QuickMaths_postprocess = [round(AverageNumClustersAS_postprocess,2) round(AveragePercentClusteredAS_postprocess,2) AverageAreaPerClusterAS_postprocess AverageRadiusAS_postprocess round(AveragePercentCoveredAS_postprocess,2) round(AverageNumClustersDB_postprocess,2) round(AveragePercentClusteredDB_postprocess,2) AverageAreaPerClusterDB_postprocess AverageRadiusDB_postprocess round(AveragePercentCoveredDB_postprocess,2)];
                        QuickMaths_postprocess_NoAS = [round(AverageNumClustersDB_postprocess,2) round(AveragePercentClusteredDB_postprocess,2) AverageAreaPerClusterDB_postprocess AverageRadiusDB_postprocess round(AveragePercentCoveredDB_postprocess,2)];
%                         table_data_plot(QuickMaths_postprocess,row_names,column_names,title_postprocess); % Show the table.
                        table_data_plot(QuickMaths_postprocess_NoAS,row_names,column_names_NoAS,title_postprocess); % Show the table.
                    end

                    % Make the complete table to write
                    CompleteTable = vertcat(TableCell{:});
                    CompleteTable_NoAS = horzcat(CompleteTable(:,1:7),CompleteTable(:,19:end));

                    CompleteTable_NoAS_CountNaN = table2array(CompleteTable_NoAS);
                    nameIdx = cellfun(@(x) ischar(x),CompleteTable_NoAS_CountNaN(:,1));
                    CompleteTable_NoAS_CountNaN(:,1) = {NaN};
                    CompleteTable_NoAS_CountNaN(cellfun('isempty',CompleteTable_NoAS_CountNaN)) = {NaN};
                    countNaNs = cellfun(@(x) isnan(x),CompleteTable_NoAS_CountNaN);
                    countNaNs = ~(sum(countNaNs,2)==size(CompleteTable_NoAS,2));
                    countNaNs(nameIdx) = 1;
                    CompleteTable_NoAS = CompleteTable_NoAS(countNaNs,:);

%                     writetable(CompleteTable,name,'sheet','SummarySheet');
                    writetable(CompleteTable_NoAS,name,'sheet','SummarySheet');

%                     % Write the Quick Maths sheet.
%                     QuickMaths = array2table(QuickMaths);
%                     QuickMaths.Properties.VariableNames = column_names;
%                     QuickMaths.Properties.RowNames = row_names;
%                     writetable(QuickMaths,name,'WriteRowNames',true,'sheet','QuickMaths');

                    % Write the Quick Maths sheet.
                    QuickMaths_NoAS = array2table(QuickMaths_NoAS);
                    QuickMaths_NoAS.Properties.VariableNames = column_names_NoAS;
                    QuickMaths_NoAS.Properties.RowNames = row_names;
                    writetable(QuickMaths_NoAS,name,'WriteRowNames',true,'sheet','QuickMaths');

                    % Write the individual sheets.
                    for i = 1:numel(data_reference)
                        if length(data_reference{i}.name) > 31
                            Sheetname = data_reference{i}.name(1:31);
                        else
                            Sheetname = data_reference{i}.name;
                        end
                        TableCell{i} = horzcat(TableCell{i}(:,1:7),TableCell{i}(:,19:end));
                        writetable(TableCell{i},name,'sheet',Sheetname); % Write the table to the Excel file.
                    end

                    if PostProcess == 1
                        % Make the complete table to write
                        CompleteTable_postprocess = vertcat(TableCell_postprocess{:});
                        CompleteTable_postprocess_NoAS = horzcat(CompleteTable_postprocess(:,1:7),CompleteTable_postprocess(:,19:end));

                        CompleteTable_postprocess_NoAS_CountNaN = table2array(CompleteTable_postprocess_NoAS);
                        nameIdx = cellfun(@(x) ischar(x),CompleteTable_postprocess_NoAS_CountNaN(:,1));
                        CompleteTable_postprocess_NoAS_CountNaN(:,1) = {NaN};
                        CompleteTable_postprocess_NoAS_CountNaN(cellfun('isempty',CompleteTable_postprocess_NoAS_CountNaN)) = {NaN};
                        countNaNs = cellfun(@(x) isnan(x),CompleteTable_postprocess_NoAS_CountNaN(2:end,2:end));
                        countNaNs = ~(sum(countNaNs,2)==size(CompleteTable_postprocess_NoAS_CountNaN,2)-1);
                        countNaNs = logical(vertcat(1,countNaNs));
                        countNaNs(nameIdx) = 1;
                        CompleteTable_postprocess_NoAS = CompleteTable_postprocess_NoAS(countNaNs,:);

%                         writetable(CompleteTable_postprocess,name_postprocess,'sheet','SummarySheet');
                        writetable(CompleteTable_postprocess_NoAS,name_postprocess,'sheet','SummarySheet');

%                         % Write the Quick Maths sheet.
%                         QuickMaths_postprocess = array2table(QuickMaths_postprocess);
%                         QuickMaths_postprocess.Properties.VariableNames = column_names;
%                         QuickMaths_postprocess.Properties.RowNames = row_names;
%                         writetable(QuickMaths_postprocess,name_postprocess,'WriteRowNames',true,'sheet','QuickMaths');

                        % Write the Quick Maths sheet.
                        QuickMaths_postprocess_NoAS = array2table(QuickMaths_postprocess_NoAS);
                        QuickMaths_postprocess_NoAS.Properties.VariableNames = column_names_NoAS;
                        QuickMaths_postprocess_NoAS.Properties.RowNames = row_names;
                        writetable(QuickMaths_postprocess_NoAS,name_postprocess,'WriteRowNames',true,'sheet','QuickMaths');

                        % Write the individual sheets.
                        for i = 1:numel(data_reference)
                            if length(data_reference{i}.name) > 31
                                Sheetname = data_reference{i}.name(1:31);
                            else
                                Sheetname = data_reference{i}.name;
                            end
                            TableCell_postprocess{i} = horzcat(TableCell_postprocess{i}(:,1:7),TableCell_postprocess{i}(:,19:end));
                            writetable(TableCell_postprocess{i},name_postprocess,'sheet',Sheetname); % Write the table to the Excel file.
                        end
                    end
                    
                    % Remove all the empty cells from the data, to avoid
                    % them being shown in the plots.
                    data_Coloc_Clustered = data_Coloc_Clustered(~cellfun('isempty',data_Coloc_Clustered)); % Remove empty cells of the clustered (by DB) colocalized data.
                    data_ClusteredAS = data_ClusteredAS(~cellfun('isempty',data_ClusteredAS)); % Remove empty cells of the clustered (by DB) colocalized data.
                    data_ClusteredDB = data_ClusteredDB(~cellfun('isempty',data_ClusteredDB)); % Remove empty cells of the clustered (by DB) colocalized data.
                    
                    % Plot the different data sets.
                    loc_list_plot(data_Coloc_Clustered); % Plot the colocalized data.
%                     loc_list_plot(data_ClusteredAS);
                    loc_list_plot(data_ClusteredDB);
%                     send_data_to_workspace(data_Coloc_Clustered);
                    send_data_to_workspace(data_ClusteredDB);

                    if PostProcess == 1
                        % Remove all the empty cells from the data, to avoid
                        % them being shown in the plots.
                        data_ClusteredAS_postprocess = data_ClusteredAS_postprocess(~cellfun('isempty',data_ClusteredAS_postprocess)); % Remove empty cells of the clustered (by DB) colocalized data.
                        data_ClusteredDB_postprocess = data_ClusteredDB_postprocess(~cellfun('isempty',data_ClusteredDB_postprocess)); % Remove empty cells of the clustered (by DB) colocalized data.

                        % Plot the different data sets.
%                         loc_list_plot(data_ClusteredAS_postprocess);
                        loc_list_plot(data_ClusteredDB_postprocess);
                        % send_data_to_workspace(data_Coloc_Clustered);
                        send_data_to_workspace(data_ClusteredDB_postprocess);
                    end
                    
                else
                    msgbox('The number of Reference data sets and Colocalization data set provided is not the same.'); % Display an error message if the size of the reference and the colocalization data set are not equal.
                end
            else
                msgbox('Either the Reference data set or Colocalization data set were not provided'); % Display an error message if either no reference or colocalization data set was selected.
            end
        end
    end

    function plot_inside_data_reference(data)        
        if length(data)>1
            slider_step=[1/(length(data)-1),1];
            slider = uicontrol('style','slider','units','normalized','position',[0,0,0.05,0.95],'value',1,'min',1,'max',length(data),'sliderstep',slider_step,'Callback',{@sld_callback});
        end
        slider_value=1;
        plot_inside_scatter(data{slider_value})        
        
        function sld_callback(~,~,~)
            slider_value = round(slider.Value);
            plot_inside_scatter(data{slider_value})
        end
        
        function plot_inside_scatter(data)
            data_down_sampled = loc_list_down_sample(data,50000);
            subplot(1,2,1)
            ax = gca; cla(ax)
            scatter(data_down_sampled.x_data,data_down_sampled.y_data,1,log10(data_down_sampled.area),'filled')
            axis off
        end
    end

    function plot_inside_data_colocalization(data)
        if length(data)>1
            slider_step=[1/(length(data)-1),1];
            slider = uicontrol('style','slider','units','normalized','position',[0.5,0,0.05,0.95],'value',1,'min',1,'max',length(data),'sliderstep',slider_step,'Callback',{@sld_callback});
        end
        slider_value=1;
        plot_inside_scatter(data{slider_value})  
        
        function sld_callback(~,~,~)
            slider_value = round(slider.Value);
            plot_inside_scatter(data{slider_value})
        end
        
        function plot_inside_scatter(data)
            data_down_sampled = loc_list_down_sample(data,50000);
            subplot(1,2,2)
            ax = gca; cla(ax)
            scatter(data_down_sampled.x_data,data_down_sampled.y_data,1,log10(data_down_sampled.area),'filled')
            axis off
        end
    end
end      

function [data_Coloc_Clustered,data_ClusteredAS,data_ClusteredDB,data_ClusteredAS_postprocess,data_ClusteredDB_postprocess,TableCell,TableCell_postprocess] = do_pattern_analysis(data_reference,data_colocalization,db_points,epsilon,PixelSize,PostProcess,minLocs,minArea,counter_waitbar)

% Show a wait bar to follow the progress
wb = waitbar(0,['Data pair: ',num2str(counter_waitbar(1)),'/',num2str(counter_waitbar(2)) ' - Step 1: Extracting clusters from reference data...                                                          ']);
drawnow

% Extract the reference data and its individual clusters
try
    DataRef = horzcat(data_reference.x_data,data_reference.y_data,data_reference.area,data_reference.identifier); % Set up the reference data
catch
    DataRef = horzcat(data_reference.x_data,data_reference.y_data,data_reference.area); % Set up the reference data
end
Groups = findgroups(DataRef(:,3)); % Find unique groups and their number
ClustersRef = splitapply(@(x){(x)},DataRef(:,1:3),Groups);

% Extract the second channel's data (no need to extract clusters)
DataColoc = horzcat(data_colocalization.x_data,data_colocalization.y_data,data_colocalization.area,data_colocalization.identifier);
Groups = findgroups(DataColoc(:,4)); % Find unique groups and their number
ClustersColoc = splitapply(@(x){(x)},DataColoc(:,1:4),Groups);

% Link the coloc clusters to the reference clusters
CentersRef = cellfun(@(x) mean(x(:,1:2)),ClustersRef,'UniformOutput',false);
CentersRef = vertcat(CentersRef{:});
CentersColoc = cellfun(@(x) mean(x(:,1:2)),ClustersColoc,'UniformOutput',false);
CentersColoc = vertcat(CentersColoc{:});
Identifier = zeros(numel(ClustersRef),1);
for i = 1:numel(ClustersRef)
    dist = pdist2(CentersColoc(i,:),CentersRef);
    [~,Identifier(i)] = min(dist);
    ClustersColoc{i}(:,4) = Identifier(i);
end

if numel(unique(Identifier)) ~= numel(CentersRef)
    IdxBoundary = cellfun(@(x) boundary(x(:,1:2),1),ClustersRef,'UniformOutput',false);
    BoundaryCoords = cellfun(@(x,y) x(y,1:2),ClustersRef,IdxBoundary,'UniformOutput',false);

    [Counts,Groups] = groupcounts(Identifier);
    Groups = Groups(Counts>1);
    ColocConfused = find(ismember(Identifier,Groups));

    closestRefCluster = zeros(numel(ColocConfused),1);
    for i = 1:numel(ColocConfused)

        dist = zeros(numel(BoundaryCoords),1);
        for j = 1:numel(BoundaryCoords)
            dist(j) = min(pdist2(CentersColoc(ColocConfused(i),:),BoundaryCoords{j}));
        end
        [~,Idx] = min(dist);
        closestRefCluster(i) = Idx;
    end
    Identifier(ColocConfused) = closestRefCluster;

end
[~,SortedIdx] = sort(Identifier);
ClustersColoc = ClustersColoc(SortedIdx);

% Do the clustering of the reference channel
waitbar(1/3,wb,['Data pair: ',num2str(counter_waitbar(1)),'/',num2str(counter_waitbar(2)) ' - Step 2: Performing alphaShape analysis...']);
warning('off','all')

% Make polygons of the reference clusters.
IdxBoundary = cellfun(@(x) boundary(x(:,1:2),1),ClustersRef,'UniformOutput',false);
BoundaryCoords = cellfun(@(x,y) x(y,1:2),ClustersRef,IdxBoundary,'UniformOutput',false);
PolygonsRefs = cellfun(@(x) polyshape(x),BoundaryCoords,'UniformOutput',false);
RefArea = cellfun(@(x) area(x)*(PixelSize/1000)^2,PolygonsRefs);

% Perform an alphaShape analysis for the 'clustering'
ColocAS = cell(numel(ClustersRef),1);
ColocClustersAS = cell(numel(ClustersRef),1);
TableColocAS = cell(numel(ClustersRef),1);
if PostProcess == 1
    ColocClustersAS_postprocess = cell(numel(ClustersRef),1);
    TableColocAS_postprocess = cell(numel(ClustersRef),1);
end
for i = 1:numel(ClustersColoc)
    ColocAS{i} = alphaShape(ClustersColoc{i}(:,1),ClustersColoc{i}(:,2));
    ColocAS{i}.Alpha = criticalAlpha(ColocAS{i},'all-points');

    % Do the alphaShape-based metrics calculations.
    TableColocAS{i} = NaN(ColocAS{i}.numRegions,9);
    ColocClustersAS{i} = cell(ColocAS{i}.numRegions,1);
    counter = 1;
    if PostProcess == 1
        ColocClustersAS_postprocess{i} = cell(ColocAS{i}.numRegions,1);
        counter_postprocess = 1;
    end
    for j = 1:ColocAS{i}.numRegions

        isInsideColoc = inShape(ColocAS{i},ClustersColoc{i}(:,1),ClustersColoc{i}(:,2),j);
        if sum(isInsideColoc) >= db_points
            ColocClustersAS{i}{counter} = ClustersColoc{i}(isInsideColoc,:);
            ColocClustersAS{i}{counter}(:,3) = area(ColocAS{i},j);
    
            TableColocAS{i}(counter,1) = counter;
            TableColocAS{i}(counter,8) = size(ColocClustersAS{i}{counter},1);
            TableColocAS{i}(counter,9) = area(ColocAS{i},j)*(PixelSize/1000)^2;
            TableColocAS{i}(counter,10) = sqrt(TableColocAS{i}(counter,9) / pi)*2;

            counter = counter + 1;
        end
        if PostProcess == 1
            if sum(isInsideColoc) >= minLocs && area(ColocAS{i},j)*(PixelSize/1000)^2 >= minArea
                ColocClustersAS_postprocess{i}{counter_postprocess} = ClustersColoc{i}(isInsideColoc,:);
                ColocClustersAS_postprocess{i}{counter_postprocess}(:,3) = area(ColocAS{i},j);
        
                TableColocAS_postprocess{i}(counter_postprocess,1) = counter_postprocess;
                TableColocAS_postprocess{i}(counter_postprocess,8) = size(ColocClustersAS_postprocess{i}{counter_postprocess},1);
                TableColocAS_postprocess{i}(counter_postprocess,9) = area(ColocAS{i},j)*(PixelSize/1000)^2;
                TableColocAS_postprocess{i}(counter_postprocess,10) = sqrt(TableColocAS_postprocess{i}(counter_postprocess,9) / pi)*2;
    
                counter_postprocess = counter_postprocess + 1;
            end
        end
    end
    TableColocAS{i}(counter:end,:) = [];
    TableColocAS{i}(1,2) = counter-1;
    TableColocAS{i}(1,3) = round(sum(TableColocAS{i}(:,8)) / size(ClustersColoc{i},1) * 100,2);
    TableColocAS{i}(1,4) = round((size(ClustersColoc{i},1) - sum(TableColocAS{i}(:,8))) / RefArea(i),2);
    TableColocAS{i}(1,5) = sum(TableColocAS{i}(:,9));
    TableColocAS{i}(1,6) = TableColocAS{i}(1,5) / RefArea(i) * 100;
    TableColocAS{i}(1,7) = sqrt(TableColocAS{i}(1,5) / pi)*2;

    if PostProcess == 1
        TableColocAS_postprocess{i}(counter_postprocess:end,:) = [];
        TableColocAS_postprocess{i}(1,2) = counter_postprocess-1;
        TableColocAS_postprocess{i}(1,3) = round(sum(TableColocAS_postprocess{i}(:,8)) / size(ClustersColoc{i},1) * 100,2);
        TableColocAS_postprocess{i}(1,4) = round((size(ClustersColoc{i},1) - sum(TableColocAS_postprocess{i}(:,8))) / RefArea(i),2);
        TableColocAS_postprocess{i}(1,5) = sum(TableColocAS_postprocess{i}(:,9));
        TableColocAS_postprocess{i}(1,6) = TableColocAS_postprocess{i}(1,5) / RefArea(i) * 100;
        TableColocAS_postprocess{i}(1,7) = sqrt(TableColocAS_postprocess{i}(1,5) / pi)*2;
    end

end

% Update the waitbar
waitbar(2/3,wb,['Data pair: ',num2str(counter_waitbar(1)),'/',num2str(counter_waitbar(2)) ' - Step 2: Performing DB Scan analysis...']);

% Perform a DBScan analysis for the clustering
ColocClustersDB = cell(numel(ClustersRef),1);
TableColocDB = cell(numel(ClustersRef),1);
if PostProcess == 1
    ColocClustersDB_postprocess = cell(numel(ClustersRef),1);
    TableColocDB_postprocess = cell(numel(ClustersRef),1);
end
pythonpath = which('dbscan_python.py');
for i = 1:numel(ClustersColoc)
    ClustersColoc_temp = ClustersColoc{i};
    % Prepare the data for the python script
    data_db = [ClustersColoc{i}(:,1) ClustersColoc{i}(:,2)];
    save('temp_file.mat','data_db','epsilon','db_points');

    % Perform the python DB Scan code and load the results
    system(['python ' pythonpath]);
    load('idx.mat')
    delete temp_file.mat
    delete idx.mat

    % Extract the results
    data_db(idx==-1,:) = [];
    ClustersColoc_temp(idx==-1,:) = [];
    idx(idx==-1) = [];
    Groups = findgroups(idx'); % Find unique groups and their number
    if ~isempty(Groups)
        ColocClustersDB{i} = splitapply(@(x){(x)},[data_db(:,1:2) ClustersColoc_temp(:,3) ClustersColoc_temp(:,4)],Groups);
        clusterSizes = cellfun(@(x) size(x,1),ColocClustersDB{i});
        ColocClustersDB{i}(clusterSizes<db_points) = [];
        if PostProcess == 1
            ColocClustersDB_postprocess{i} = ColocClustersDB{i};
            clusterSizes = cellfun(@(x) size(x,1),ColocClustersDB{i});
            clusterAreas = zeros(size(ColocClustersDB{i},1),1);
            for j = 1:size(ColocClustersDB_postprocess{i},1)
                shpColocDB = alphaShape(ColocClustersDB_postprocess{i}{j}(:,1),ColocClustersDB_postprocess{i}{j}(:,2));
                shpColocDB.Alpha = criticalAlpha(shpColocDB,'one-region');
                clusterAreas(j) = area(shpColocDB);
            end
            ColocClustersDB_postprocess{i}(clusterSizes<minLocs | clusterAreas*(PixelSize/1000)^2 < minArea) = [];
        end
    else
        ColocClustersDB{i} = cell(0,1);
        ColocClustersDB_postprocess{i} = cell(0,1);
    end

    % Calculate the DB Scan-based metrics calculations.
    TableColocDB{i} = NaN(numel(ColocClustersDB{i}),9);
    for j = 1:numel(ColocClustersDB{i})

        shpColocDB = alphaShape(ColocClustersDB{i}{j}(:,1),ColocClustersDB{i}{j}(:,2));
        shpColocDB.Alpha = criticalAlpha(shpColocDB,'one-region');
        ColocClustersDB{i}{j}(:,3) = area(shpColocDB);

        TableColocDB{i}(j,1) = j;
        TableColocDB{i}(j,8) = size(ColocClustersDB{i}{j},1);
        TableColocDB{i}(j,9) = area(shpColocDB)*(PixelSize/1000)^2;
        TableColocDB{i}(j,10) = sqrt(TableColocDB{i}(j,9) / pi)*2;
    end
    TableColocDB{i}(1,2) = numel(ColocClustersDB{i});
    TableColocDB{i}(1,3) = round(sum(TableColocDB{i}(:,8)) / size(ClustersColoc{i},1) * 100,2);
    TableColocDB{i}(1,4) = round((size(ClustersColoc{i},1) - sum(TableColocDB{i}(:,8))) / RefArea(i),2);
    TableColocDB{i}(1,5) = sum(TableColocDB{i}(:,9));
    TableColocDB{i}(1,6) = TableColocDB{i}(1,5) / RefArea(i) * 100;
    TableColocDB{i}(1,7) = sqrt(TableColocDB{i}(1,5) / pi)*2;

    if PostProcess == 1
        TableColocDB_postprocess{i} = NaN(numel(ColocClustersDB_postprocess{i}),9);

        for j = 1:numel(ColocClustersDB_postprocess{i})

            shpColocDB_postprocess = alphaShape(ColocClustersDB_postprocess{i}{j}(:,1),ColocClustersDB_postprocess{i}{j}(:,2));
            shpColocDB_postprocess.Alpha = criticalAlpha(shpColocDB_postprocess,'one-region');
            ColocClustersDB_postprocess{i}{j}(:,3) = area(shpColocDB_postprocess);

            TableColocDB_postprocess{i}(j,1) = j;
            TableColocDB_postprocess{i}(j,8) = size(ColocClustersDB_postprocess{i}{j},1);
            TableColocDB_postprocess{i}(j,9) = area(shpColocDB_postprocess)*(PixelSize/1000)^2;
            TableColocDB_postprocess{i}(j,10) = sqrt(TableColocDB_postprocess{i}(j,9) / pi)*2;
        end
        TableColocDB_postprocess{i}(1,2) = numel(ColocClustersDB_postprocess{i});
        TableColocDB_postprocess{i}(1,3) = round(sum(TableColocDB_postprocess{i}(:,8)) / size(ClustersColoc{i},1) * 100,2);
        TableColocDB_postprocess{i}(1,4) = round((size(ClustersColoc{i},1) - sum(TableColocDB_postprocess{i}(:,8))) / RefArea(i),2);
        TableColocDB_postprocess{i}(1,5) = sum(TableColocDB_postprocess{i}(:,9));
        TableColocDB_postprocess{i}(1,6) = TableColocDB_postprocess{i}(1,5) / RefArea(i) * 100;
        TableColocDB_postprocess{i}(1,7) = sqrt(TableColocDB_postprocess{i}(1,5) / pi)*2*PixelSize;
    end
end

% Make the final table
TableCell = cell(numel(ClustersRef),1);
for i = 1:numel(ClustersRef)
    maxSize = max([size(TableColocAS{i},1) size(TableColocDB{i},1)]);

    TableCell{i} = NaN(maxSize,28);
    TableCell{i}(1,1) = i;
    TableCell{i}(1,2) = size(ClustersRef{i},1);
    TableCell{i}(1,3) = RefArea(i);
    TableCell{i}(1,4) = round(TableCell{i}(1,2) / TableCell{i}(1,3),2);
    TableCell{i}(1,5) = size(ClustersColoc{i},1);
    TableCell{i}(1,6) = round(TableCell{i}(1,5) / TableCell{i}(1,3),2);

    TableCell{i}(1:size(TableColocAS{i},1),8:17) = TableColocAS{i};
    TableCell{i}(1:size(TableColocDB{i},1),19:28) = TableColocDB{i};
end
TableCell = vertcat(TableCell{:});

% Make the final table
if PostProcess == 1
    TableCell_postprocess = cell(numel(ClustersRef),1);
    for i = 1:numel(ClustersRef)
        maxSize = max([size(TableColocAS_postprocess{i},1) size(TableColocDB_postprocess{i},1)]);
    
        TableCell_postprocess{i} = NaN(maxSize,28);
        TableCell_postprocess{i}(1,1) = i;
        TableCell_postprocess{i}(1,2) = size(ClustersRef{i},1);
        TableCell_postprocess{i}(1,3) = RefArea(i);
        TableCell_postprocess{i}(1,4) = round(TableCell_postprocess{i}(1,2) / TableCell_postprocess{i}(1,3),2);
        TableCell_postprocess{i}(1,5) = size(ClustersColoc{i},1);
        TableCell_postprocess{i}(1,6) = round(TableCell_postprocess{i}(1,5) / TableCell_postprocess{i}(1,3),2);
    
        TableCell_postprocess{i}(1:size(TableColocAS_postprocess{i},1),8:17) = TableColocAS_postprocess{i};
        TableCell_postprocess{i}(1:size(TableColocDB_postprocess{i},1),19:28) = TableColocDB_postprocess{i};
    end
    TableCell_postprocess = vertcat(TableCell_postprocess{:});
end

% Update the waitbar
waitbar(1,wb,['Data pair: ',num2str(counter_waitbar(1)),'/',num2str(counter_waitbar(2)) ' - Step 2: Extracting the results and saving...']);

% Prepare the final data for output
shpColoc = cellfun(@(x) alphaShape(x(:,1:2)),ClustersColoc,'UniformOutput',false);
AlpaOneRegion = cellfun(@(x) criticalAlpha(x,'one-region'),shpColoc);
for i = 1:numel(ClustersColoc)
    shpColoc{i}.Alpha = AlpaOneRegion(i);
    ClustersColoc{i}(:,3) = area(shpColoc{i});
end
ClustersColoc = vertcat(ClustersColoc{:});

ColocClustersAS = vertcat(ColocClustersAS{:}); % First time to get all the sub regions under each other
ColocClustersAS = vertcat(ColocClustersAS{:}); % Second time to get all the localizations under each other

ColocClustersDB = vertcat(ColocClustersDB{:}); % First time to get all the sub regions under each other
ColocClustersDB = vertcat(ColocClustersDB{:}); % Second time to get all the localizations under each other

if PostProcess == 1
    ColocClustersAS_postprocess = vertcat(ColocClustersAS_postprocess{:}); % First time to get all the sub regions under each other
    ColocClustersAS_postprocess = vertcat(ColocClustersAS_postprocess{:}); % Second time to get all the localizations under each other
    
    ColocClustersDB_postprocess = vertcat(ColocClustersDB_postprocess{:}); % First time to get all the sub regions under each other
    ColocClustersDB_postprocess = vertcat(ColocClustersDB_postprocess{:}); % Second time to get all the localizations under each other
end

if ~isempty(ClustersColoc)
    data_Coloc_Clustered.x_data = ClustersColoc(:,1);
    data_Coloc_Clustered.y_data = ClustersColoc(:,2);
    data_Coloc_Clustered.area = ClustersColoc(:,3);
    data_Coloc_Clustered.identifier = ClustersColoc(:,4);
    data_Coloc_Clustered.type = 'loc_list';
    data_Coloc_Clustered.name = [data_colocalization.name '_ColocClusterByReferenceCluster'];
else
    data_Coloc_Clustered = [];
end

if ~isempty(ColocClustersAS)
    data_ClusteredAS.x_data = ColocClustersAS(:,1);
    data_ClusteredAS.y_data = ColocClustersAS(:,2);
    data_ClusteredAS.area = ColocClustersAS(:,3);
    data_ClusteredAS.identifier = ColocClustersAS(:,4);
    data_ClusteredAS.type = 'loc_list';
    data_ClusteredAS.name = [data_colocalization.name '_AlphaShapeClustered_' num2str(db_points) 'minPoints'];
else
    data_ClusteredAS = [];
end

if ~isempty(ColocClustersDB)
    data_ClusteredDB.x_data = ColocClustersDB(:,1);
    data_ClusteredDB.y_data = ColocClustersDB(:,2);
    data_ClusteredDB.area = ColocClustersDB(:,3);
    data_ClusteredDB.identifier = ColocClustersDB(:,4);
    data_ClusteredDB.type = 'loc_list';
    data_ClusteredDB.name = [data_colocalization.name '_DBScanClustered_' num2str(db_points) 'minPoints_' num2str(epsilon) 'Epsilon'];
else
    data_ClusteredDB = [];
end

if PostProcess == 1
    if ~isempty(ColocClustersAS_postprocess)
        data_ClusteredAS_postprocess.x_data = ColocClustersAS_postprocess(:,1);
        data_ClusteredAS_postprocess.y_data = ColocClustersAS_postprocess(:,2);
        data_ClusteredAS_postprocess.area = ColocClustersAS_postprocess(:,3);
        data_ClusteredAS_postprocess.identifier = ColocClustersAS_postprocess(:,4);
        data_ClusteredAS_postprocess.type = 'loc_list';
        data_ClusteredAS_postprocess.name = [data_colocalization.name '_AlphaShapeClustered_' num2str(db_points) 'minPoints_Postprocessed_' num2str(minLocs) 'minLocs_' num2str(minArea) 'minArea'];
    else
        data_ClusteredAS_postprocess = [];
    end
    
    if ~isempty(ColocClustersDB_postprocess)
        data_ClusteredDB_postprocess.x_data = ColocClustersDB_postprocess(:,1);
        data_ClusteredDB_postprocess.y_data = ColocClustersDB_postprocess(:,2);
        data_ClusteredDB_postprocess.area = ColocClustersDB_postprocess(:,3);
        data_ClusteredDB_postprocess.identifier = ColocClustersDB_postprocess(:,4);
        data_ClusteredDB_postprocess.type = 'loc_list';
        data_ClusteredDB_postprocess.name = [data_colocalization.name '_DBScanClustered_' num2str(db_points) 'minPoints_' num2str(epsilon) 'Epsilon_Postprocessed_' num2str(minLocs) 'minLocs_' num2str(minArea) 'minArea'];
    else
        data_ClusteredDB_postprocess = [];
    end
else
    data_ClusteredAS_postprocess = [];
    data_ClusteredDB_postprocess = [];
    TableCell_postprocess = [];
end

% Turn back on the warnings
warning('on','all')

close(wb)
end

function input_values = InputDialog()

    %  Create a figure for the input dialog and show the parameter the user
    %  has to provide (i.e., the expansion factor, in pixels)
    InputFigure = figure('Units','Normalized','Position',[.4 .4 .22 .2],'NumberTitle','off','Name','Pattern Analysis','menubar','none');
    uicontrol('Style','text','Units','Normalized','Position',[.05 .85 .6 .1],'String','Min. number of points: ','FontSize',10,'HorizontalAlignment','right');
    minPoints = uicontrol('Style','Edit','Units','Normalized','Position',[.65 .85 .15 .1],'String','5','FontSize',10);
    uicontrol('Style','text','Units','Normalized','Position',[.05 .73 .6 .1],'String','Search radius (epsilon): ','FontSize',10,'HorizontalAlignment','right');
    Epsilon = uicontrol('Style','Edit','Units','Normalized','Position',[.65 .73 .15 .1],'String','0.25','FontSize',10);
    uicontrol('Style','text','Units','Normalized','Position',[.05 .61 .6 .1],'String','Pixelsize (nm): ','FontSize',10,'HorizontalAlignment','right');
    PixelSize = uicontrol('Style','Edit','Units','Normalized','Position',[.65 .61 .15 .1],'String','117','FontSize',10);uicontrol('Style','text','Units','Normalized','Position',[.1 .49 .6 .1],'String','Postprocess?','FontSize',10,'HorizontalAlignment','left');
    PostProcess = uicontrol('Style','checkbox','Units','Normalized','Position',[.05 .49 .05 .1],'CallBack',@postProcessCallback);
    minLoc_text = uicontrol('Style','text','Units','Normalized','Position',[.05 .39 .9 .1],'String','Minimum number of localizations: ','FontSize',10,'HorizontalAlignment','left','Enable','off');
    minLoc = uicontrol('Style','Edit','Units','Normalized','Position',[.65 .39 .15 .1],'String','10','FontSize',10,'Enable','off');
    minArea_text = uicontrol('Style','text','Units','Normalized','Position',[.05 .27 .9 .1],'String','Minimum area (µm²): ','FontSize',10,'HorizontalAlignment','left','Enable','off');
    minArea = uicontrol('Style','Edit','Units','Normalized','Position',[.65 .27 .15 .1],'String','1E-9','FontSize',10,'Enable','off');
    uicontrol('Style','PushButton','Units','Normalized','Position',[.1 .07 .35 .15],'String','OK','CallBack',@DoneCallback);
    uicontrol('Style','PushButton','Units','Normalized','Position',[.55 .07 .35 .15],'String','Cancel','CallBack',@CancelCallback);
    
    % Wait until the user does something with this input dialog
    uiwait(InputFigure)

    function postProcessCallback(~,~,~)
        if PostProcess.Value == 1
            minLoc_text.Enable = 'on';
            minLoc.Enable = 'on';
            minArea_text.Enable = 'on';
            minArea.Enable = 'on';
        elseif PostProcess.Value == 0
            minLoc_text.Enable = 'off';
            minLoc.Enable = 'off';
            minArea_text.Enable = 'off';
            minArea.Enable = 'off';
        end
    end
    
    % Specify the callback of the 'done' button
    function DoneCallback(~,~,~)
        uiresume(InputFigure)
        input_values{1} = get(minPoints,'String');
        input_values{2} = get(Epsilon,'String');
        input_values{3} = get(PixelSize,'String');
        input_values{4} = num2str(get(PostProcess,'Value'));
        input_values{5} = get(minLoc,'String');
        input_values{6} = get(minArea,'String');
        close(InputFigure)
    end

    % Specify the callback of the 'cancel' button
    function CancelCallback(~,~,~)
        uiresume(InputFigure)
        close(InputFigure)
        input_values = {};
    end

end