function colocalization_module_New()

% Use data and listbox as global variables (access from anywhere).
global data listbox

% Make a new figure, and set its properties.
figure();
set(gcf,'name','Colocalization Module','NumberTitle','off','color','k','units','normalized','position',[0.25 0.2 0.5 0.6],'menubar','none','toolbar','figure');

% Add push buttons to the created figure, that allow the user to set the
% reference data, the colocalization data, and start the actual
% colocalization.
uicontrol('style','pushbutton','units','normalized','position',[0,0.95,0.2,0.05],'string','Set Reference Data','ForegroundColor','b','Callback',{@set_reference_data_callback},'FontSize',12);
uicontrol('style','pushbutton','units','normalized','position',[0.2,0.95,0.2,0.05],'string','Set Colocalization Data','ForegroundColor','b','Callback',{@set_colocalization_data_callback},'FontSize',12);
uicontrol('style','pushbutton','units','normalized','position',[0.4,0.95,0.2,0.05],'string','Start Colocalization','ForegroundColor','b','Callback',{@colocalization_callback},'FontSize',12);

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
            overlap_thres = str2double(input_values{1})/100; % Extract the threshold of overlap used.
            Stats = str2double(input_values{2}); % Extract whether or not statistics have to be calculated.
            PixelSize = str2double(input_values{3}); % Extract the pixel size (default is 117 nm).
            PostProcess = str2double(input_values{4}); % Extract whether or not data has to be postprocessed.
            minLoc = str2double(input_values{5}); % Extract the minimum number of localizations for postprocessing.
            minArea = str2double(input_values{6}); % Extract the minimum area (in nm²) for postprocessing.
            
            % If statistics have to be calculated, open a window to select
            % where the file should be saved.
            if Stats
               [file,path] = uiputfile('*.xlsx','Please specify a name to save the statistics as'); % Extract the name of the file given.
               name = fullfile(path,file); % Make it a full name to save it as later.
               
               % Delete the file if it exists. Avoid extra entries if the
               % file already existed before.
               if exist(name,'file') == 2
                   delete(name);
               end
            else
                name = []; % If no statistics have to be calculated, make an empty name.
            end
            
            % Check if the reference and colocalization data sets are not
            % empty. If they are not, continue the analysis, else, show an
            % error message.
            if ~isempty(data_reference) && ~isempty(data_colocalization)
                % Check if the lengths of the reference and colocalization
                % data sets are the same. If not, display an error.
                if length(data_reference)==length(data_colocalization)
                    % Pre-allocate and initialize for speed and convenience
                    % reasons.
                    data_localized = cell(length(data_reference),1);
                    data_not_localized = cell(length(data_reference),1);
                    data_localized_postprocessed = cell(length(data_reference),1);
                    data_removed_postprocessed = cell(length(data_reference),1);
                    Table = cell(length(data_reference),1);
                    Table_postprocessed = cell(length(data_reference),1);
                    percentage = zeros(1,length(data_reference));
                    row_names = cell(length(data_reference),1);
                    
                    % Start doing the actual calculations.
                    % Loop over the different reference data sets, and
                    % perform the colocalization (and postprocessing and
                    % statistics if selected).
                    for i = 1:length(data_reference)
                        % Perform the actual calculations.
                        counter = [i length(data_reference)]; % Set up the counter for the wait bar.
                        [data_localized{i},data_not_localized{i},data_localized_postprocessed{i},data_removed_postprocessed{i},Table{i},Table_postprocessed{i}] = find_colocalization_new(data_reference{i},data_colocalization{i},overlap_thres,counter,name,PixelSize,PostProcess,minLoc,minArea); % See inner function for more explanation.
                        
                        % Calculate the percentage of overlap, depending on
                        % whether or not the data was postprocessed. 
                        if PostProcess
                            % First try to see if there actually was data
                            % colocalized after postprocessing. If not, the
                            % percentage of overlap is 0.
                            try
                                percentage(i) = 100*length(unique(data_localized_postprocessed{i}.area))/length(unique(data_colocalization{i}.area)); % The percentage is calculated as unique areas in the colocalized data, divided by unique areas in the colocalization data (this is the data before the calculation was done). The area is used as a unique identifier for each cluster.
                            catch
                                percentage(i) = 0; % If the above calculation failed (i.e., cell is empty), overlap = 0.
                            end
                            
                            % Set the column name of the tabel so that it
                            % reflects that the data was postprocessed.
                            column_names = {'Percentage of colocalized clusters after postprocessing'};
                        else
                            % First try to see if there actually was data
                            % colocalized (without postprocessing). If not,
                            % the percentage of overlap is 0.
                            try
                                percentage(i) = 100*length(unique(data_localized{i}.area))/length(unique(data_colocalization{i}.area)); % The percentage is calculated as unique areas in the colocalized data, divided by unique areas in the colocalization data (this is the data before the calculation was done). The area is used as a unique identifier for each cluster.
                            catch
                                percentage(i) = 0; % If the above calculation failed (i.e., cell is empty), overlap = 0.
                            end
                            
                            % Set the column name of the tabel so that it
                            % reflects that the data was not postprocessed.
                            column_names = {'Percentage of colocalized clusters'};
                        end
                        
                        % Set the row names, according to the name of the
                        % colocalization data set.
                        row_names{i} = data_colocalization{i}.name;
                    end
                    
                    % Set the title of the table being shown, and actually
                    % show the table.
                    title = 'Colocalization'; % Set the title.
                    table_data_plot(percentage',row_names,column_names,title); % Show the table.
                    
                    % Remove all the empty cells from the data, to avoid
                    % them being shown in the plots.
                    data_localized = data_localized(~cellfun('isempty',data_localized)); % Remove empty cells of the colocalized data.
                    data_not_localized = data_not_localized(~cellfun('isempty',data_not_localized)); % Remove empty cells of the non-colocalized data.
                    data_localized_postprocessed = data_localized_postprocessed(~cellfun('isempty',data_localized_postprocessed)); % Remove empty cells of the colocalized and postprocessed data.
                    data_removed_postprocessed = data_removed_postprocessed(~cellfun('isempty',data_removed_postprocessed)); % Remove empty cells of the colocalized data that was removed after postprocessing.
                    
                    % Plot the four different data sets.
                    loc_list_plot(data_localized); % Plot the colocalized data.
                    loc_list_plot(data_not_localized); % Plot the noncolocalized data.
                    loc_list_plot(data_localized_postprocessed); % Plot the colocalized and postprocessed data.
                    loc_list_plot(data_removed_postprocessed); % Plot the colocalized data that was removed after postprocessing.
                    
                    % Make the tables that contain the statistics of the
                    % different colocalized clusters, and if needed also of
                    % the postprocessed colocalized data.
                    if Stats
                        % Make an empty row first, with 1 less column than 
                        % the total number of columns (to keep a space for 
                        % the data name).
                        EmptyRow = cell(1,19); % Make an empty cell.
                        EmptyRow(1:end) = {NaN}; % Fill the cells with NaN (as these are not displayed in Excel).
                        
                        % Loop over the different reference data sets, so
                        % that an summary of all the different data ROIs
                        % can be obtained.
                        for i = 1:length(data_reference)
                            % Add the name of the reference data set in an
                            % empty row, just above the actual data, so
                            % that this can easily be found back in the
                            % data browser.
                            TableName = horzcat({data_reference{i}.name},EmptyRow); % Concatenate the title and the empty columns.
                            
                            % Make the tables for non-postprocessed data
                            % and postprocessed data. The first data set is
                            % slightly different than the subsequent ones
                            % (because it is easier to code it in the naive
                            % way).
                            if i == 1
                                Table_noPostProcess = [TableName; num2cell(Table{i})]; % Append the table (before postprocessing) after the name of the reference data.
                                
                                % Do the same for the postprocessed data if
                                % the postprocessing checkbox was checked.
                                if PostProcess
                                    Table_PostProcess = [TableName; num2cell(Table_postprocessed{i})];
                                end
                            else
                                Table_noPostProcess = [Table_noPostProcess; TableName; num2cell(Table{i})]; % Append the table (before postprocessing) after the name of the reference data.
                                
                                % Do the same for the postprocessed data if
                                % the postprocessing checkbox was checked.
                                if PostProcess
                                    Table_PostProcess = [Table_PostProcess; TableName; num2cell(Table_postprocessed{i})];
                                end
                            end
                        end
                        
                        % Make a table out of the cells, set the column
                        % variable names and write it as a .xlsx file.
                        Table_noPostProcess = cell2table(Table_noPostProcess); % Convert the cell to a table.
                        Table_noPostProcess.Properties.VariableNames = {'Reference_cluster','Number_of_localizations_in_reference_cluster','Reference_cluster_area','Reference_cluster_density','Colocalization_cluster','Number_of_localizations_in_colocalization_cluster', 'Area_of_colocalization_cluster','Colocalization_cluster_density','Percentage_of_overlap','Colocalization_MajorAxis','Colocalization_MinorAxis','Cluster_number_of_closest_distance', 'Distance_to_closest_cluster', 'Cluster_number_of_second_closest_distance', 'Distance_to_second_closest_cluster','Cluster_number_of_closest_borderdistance', 'Distance_to_closest_clusterborder', 'Cluster_number_of_second_closest_borderdistance', 'Distance_to_second_closest_clusterborder','Colocalized_clusters_distance_to_reference_cluster_border'}; % Set the column variable names.
                        writetable(Table_noPostProcess,name,'sheet','SummarySheet'); % Write the table to the Excel file, in a Summary sheet.
                        
                        % Do the same for the postprocessed colocalized
                        % data if the checkbox was checked.
                        if PostProcess
                            namePostProcess = horzcat(extractBefore(name,'.xlsx'),'_postprocessing.xlsx'); % Change the name to reflect that this is the postprocessed summary of the data.
                            
                            % Delete the file if it exists. Avoid extra entries if the
                            % file already existed before.
                            if exist(namePostProcess,'file') == 2
                                delete(namePostProcess);
                            end
                            
                            Table_PostProcess = cell2table(Table_PostProcess); % Convert the cell to a table.
                            Table_PostProcess.Properties.VariableNames = {'Reference_cluster','Number_of_localizations_in_reference_cluster','Reference_cluster_area','Reference_cluster_density','Colocalization_cluster','Number_of_localizations_in_colocalization_cluster', 'Area_of_colocalization_cluster','Colocalization_cluster_density','Percentage_of_overlap','Colocalization_MajorAxis','Colocalization_MinorAxis','Cluster_number_of_closest_distance', 'Distance_to_closest_cluster', 'Cluster_number_of_second_closest_distance', 'Distance_to_second_closest_cluster','Cluster_number_of_closest_borderdistance', 'Distance_to_closest_clusterborder', 'Cluster_number_of_second_closest_borderdistance', 'Distance_to_second_closest_clusterborder','Colocalized_clusters_distance_to_reference_cluster_border'}; % Set the column variable names.
                            writetable(Table_PostProcess,namePostProcess,'sheet','SummarySheet'); % Write the table to the Excel file, in a Summary sheet.
                        end
                        
                        % Write every data set also as an individual sheet
                        % in the Excel file. This might be useful for a
                        % more detailed analysis. !!This process is slow!!
                        for i = 1:length(data_reference)
                            TableName = horzcat({data_reference{i}.name},EmptyRow); % Concatenate the title and the empty columns.
                            IndividualTable = [TableName; num2cell(Table{i})]; % Append the table (before postprocessing) after the name of the reference data.
                            TableSheet = cell2table(IndividualTable); % Convert the table of each reference data set to a table.
                            TableSheet.Properties.VariableNames = {'Reference_cluster','Number_of_localizations_in_reference_cluster','Reference_cluster_area','Reference_cluster_density','Colocalization_cluster','Number_of_localizations_in_colocalization_cluster', 'Area_of_colocalization_cluster','Colocalization_cluster_density','Percentage_of_overlap','Colocalization_MajorAxis','Colocalization_MinorAxis','Cluster_number_of_closest_distance', 'Distance_to_closest_cluster', 'Cluster_number_of_second_closest_distance', 'Distance_to_second_closest_cluster','Cluster_number_of_closest_borderdistance', 'Distance_to_closest_clusterborder', 'Cluster_number_of_second_closest_borderdistance', 'Distance_to_second_closest_clusterborder','Colocalized_clusters_distance_to_reference_cluster_border'}; % Set the column variable names.
                            writetable(TableSheet,name,'sheet',['Data ' num2str(i)]); % Write the table to the Excel file, in an individual sheet for each reference data.
                            
                            % Do the same for the postprocessed colocalized
                            % data if the checkbox was checked.
                            if PostProcess
                                IndividualTable_postprocess = [TableName; num2cell(Table_postprocessed{i})]; % Append the table (before postprocessing) after the name of the reference data.
                                TablePostProcessSheet = cell2table(IndividualTable_postprocess); % Append the table (before postprocessing) after the name of the reference data.
                                TablePostProcessSheet.Properties.VariableNames = {'Reference_cluster','Number_of_localizations_in_reference_cluster','Reference_cluster_area','Reference_cluster_density','Colocalization_cluster','Number_of_localizations_in_colocalization_cluster', 'Area_of_colocalization_cluster','Colocalization_cluster_density','Percentage_of_overlap','Colocalization_MajorAxis','Colocalization_MinorAxis','Cluster_number_of_closest_distance', 'Distance_to_closest_cluster', 'Cluster_number_of_second_closest_distance', 'Distance_to_second_closest_cluster','Cluster_number_of_closest_borderdistance', 'Distance_to_closest_clusterborder', 'Cluster_number_of_second_closest_borderdistance', 'Distance_to_second_closest_clusterborder','Colocalized_clusters_distance_to_reference_cluster_border'}; % Set the column variable names.
                                writetable(TablePostProcessSheet,namePostProcess,'sheet',['Data ' num2str(i)]); % Write the table to the Excel file, in an individual sheet for each reference data.
                            end
                        end
                    end
                else
                    msgbox('Number of reference data is not equal to number of colocalization data'); % Display an error message if the size of the reference and the colocalization data set are not equal.
                end
            else
                msgbox('No reference or colocalization data was selected'); % Display an error message if either no reference or colocalization data set was selected.
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

function [data_localized,data_not_localized,data_localized_postprocess,data_removed_postprocess,Table,Table_PostProcess] = find_colocalization_new(data_reference,data_colocalization,overlap_thres,counter_waitbar,name,PixelSize,PostProcess,minLoc,minArea)

wb = waitbar(0,['Data pair: ',num2str(counter_waitbar(1)),'/',num2str(counter_waitbar(2)) ' - Step 1: Extracting clusters from data...                                                          ']);
% set(findall(wb),'Units','normalized');
% set(wb,'Position',[0.3 0.45 0.35 0.075])
drawnow

DataRef = horzcat(data_reference.x_data,data_reference.y_data,data_reference.area); % Set up the reference data
Groups = findgroups(DataRef(:,3)); % Find unique groups and their number
ClustersRef = splitapply(@(x){(x)},DataRef(:,1:3),Groups);

DataColoc = horzcat(data_colocalization.x_data,data_colocalization.y_data,data_colocalization.area); % Extract the data
Groups = findgroups(DataColoc(:,3)); % Find unique groups and their number
ClustersColoc = splitapply(@(x){(x)},DataColoc(:,1:3),Groups); % Split the clusters into the corresponding groups

waitbar(1/3,wb,['Data pair: ',num2str(counter_waitbar(1)),'/',num2str(counter_waitbar(2)) ' - Step 2: Filtering co-localization clusters...']);

% Extract the colocalization channel cluster centers
ColocCenter = cell2mat(cellfun(@(x) mean(x(:,1:2)), ClustersColoc,'UniformOutput',false));

% Pre-allocate and initialize for speed and convenience reasons
PolyLowResRefExpanded = cell(size(ClustersRef,1),1);

% Create a set of low-resolution coordinates of all the reference cluster
% coordinates
warning('off','all') % Turn off warnings for the creation of the polygons
for j = 1:size(ClustersRef,1)
    % Update the wait bar
    waitbar(1/3+(j/size(ClustersRef,1))/3,wb,['Data pair: ',num2str(counter_waitbar(1)),'/',num2str(counter_waitbar(2)) ' - Step 2: Filtering co-localization clusters...']);
    
    if size(ClustersRef{j},1) > 1000 % work around for really small clusters (covering less than a 2x2 area). This assumes that any cluster larger than 1000 points will cover this area (which might not always be the case)
        LowResCoords = unique(round(ClustersRef{j}(:,1:2)),'rows'); % Create a low-res version of the reference coordinates
        LowResBoundary = boundary(LowResCoords,1); % Calculate the boundary
        LowResBoundaryCoords = LowResCoords(LowResBoundary,:); % Extract the coordinates from the boundary
    else
        ResBoundary = boundary(ClustersRef{j}(:,1:2)); % Calculate the boundary of the cluster
        LowResBoundaryCoords = ClustersRef{j}(ResBoundary,1:2); % Extract the coordinates from the boundary
    end
    PolyLowResRef = polyshape(LowResBoundaryCoords); % Create a polygon from these coordinates
    PolyLowResRefExpanded{j} = polybuffer(PolyLowResRef,5); % Expand the polygon with 5 pixels
end

% Determine the possible reference clusters related to the co-localization
% clusters
IsInside = cellfun(@(x) inpolygon(ColocCenter(:,1),ColocCenter(:,2),x.Vertices(:,1),x.Vertices(:,2)),PolyLowResRefExpanded,'UniformOutput',false);
Idx = cellfun(@(x) find(x), IsInside,'UniformOutput',false);

% Clean up the reference clusters that do not have any potential
% co-localization clusters associated to them
SelectRefClusters = cell2mat(cellfun(@(x) ~isempty(x),Idx,'UniformOutput',false));
ClustersRef = {ClustersRef{SelectRefClusters}}';
IdxClusters = {Idx{SelectRefClusters}}';

waitbar(2/3,wb,['Data pair: ',num2str(counter_waitbar(1)),'/',num2str(counter_waitbar(2)) ' - Step 3: Calculating co-localization...']);

% Pre-allocate for speed reasons
PercentageInside = cell(size(ClustersRef,1),1);
shpRef = cell(size(ClustersRef,1),1);
if ~isempty(name)
    refArea = zeros(size(ClustersRef,1),1);
    refLocs = zeros(size(ClustersRef,1),1);
end
% Create alpha shapes of the reference clusters and then check if the
% coordinates of the selected clusters are inside these.
for j = 1:size(ClustersRef,1)
    % Extract the coordinates of the reference cluster and make an
    % 'alphashape' of it. This alphashape will keep into account the
    % holes inside the reference clusters.
    alpha = 0.8; % This was set with Qing that looked good for her tubulins data
    xRef = ClustersRef{j}(:,1);
    yRef = ClustersRef{j}(:,2);
    shpRef{j} = alphaShape(xRef,yRef,alpha);
    CritAlpha = criticalAlpha(shpRef{j},'all-points');
    if CritAlpha < alpha
        shpRef{j}.Alpha = CritAlpha;
    end
    
    if ~isempty(name)
        refArea(j,1) = area(shpRef{j})*PixelSize*PixelSize;
        refLocs(j,1) = size(xRef,1);
    end
    
    % Pre-allocate for speed reasons
    PercentageInside{j} = zeros(size(IdxClusters{j},1),1);
    % Loop over the different potential overlapping clusters and
    % calculate their overlap with the reference cluster
    for k = 1:size(IdxClusters{j},1)
        % Update the wait bar
        waitbar(2/3+(j/size(ClustersRef,1))/3,wb,['Data pair: ',num2str(counter_waitbar(1)),'/',num2str(counter_waitbar(2)) ' - Step 3: Calculating overlap... - Reference cluster ' num2str(j) ' of ' num2str(size(ClustersRef,1))]);
        
        % Calculate the actual overlap
        ColocCoords = ClustersColoc{IdxClusters{j}(k)}(:,1:2); % Extract the coordinates for the potentially interesting cluster
        try
            tf = inShape(shpRef{j},ColocCoords(:,1),ColocCoords(:,2)); % Calculate the overlap between reference cluster and co-localization channel cluster
        catch
            shpRef{j}.Alpha = CritAlpha;
            tf = inShape(shpRef{j},ColocCoords(:,1),ColocCoords(:,2)); % Calculate the overlap between reference cluster and co-localization channel cluster
        end            
        total = numel(tf); % Determine the total number of coordinates
        PercentageInside{j}(k) = sum(tf) / total; % The percentage of overlap is calculated as the number of coordinate pairs that overlap with the reference cluster divided by the total number of coordinate pairs
    end
end

% Check if any co-localization cluster got assigned to multiple
% reference clusters. This is possible due to the expanded boundary
% region of the reference clusters
[C,~,IC] = unique(vertcat(IdxClusters{:})); % Find the unique values
IC = accumarray(IC,1); % Count how many times each unique value occurs
C(IC==1,:) = []; % Remove the cluster Ids that only occur once
% Only do this if there are duplicate assignments
if ~isempty(C)
    % Find out where the duplicates are, to what reference cluster they
    % are associated and then remove the unimportant contributions
    for j = 1:numel(C)
        % For each duplicate assignment, find out to which reference
        % cluster is was associated
        ClustersWithDuplicates = cellfun(@(x) find(x==C(j)),IdxClusters,'UniformOutput',false);
        DuplicateIdx = find(~cellfun(@(x) isempty(x), ClustersWithDuplicates));
        % Pre-allocate for speed reasons
        Percentages = zeros(numel(DuplicateIdx),1);
        % Extract the percentages of overlap so that only the maximum
        % one can be kept
        for k = 1:numel(DuplicateIdx)
            Percentages(k,:) = PercentageInside{DuplicateIdx(k)}(IdxClusters{DuplicateIdx(k)}==C(j));
        end
        [~,Idx] = max(Percentages);
        DuplicateIdx(Idx) = [];
        % Remove the co-localization cluster id from the calculations.
        % Only 1 assignment per co-localization cluster
        for k = 1:numel(DuplicateIdx)
            PercentageInside{DuplicateIdx(k)}(IdxClusters{DuplicateIdx(k)}==C(j)) = [];
            IdxClusters{DuplicateIdx(k)}(IdxClusters{DuplicateIdx(k)}==C(j)) = [];
        end
    end
    % Clean up the reference clusters that do not have any
    % co-localization clusters associated to them anymore
    SelectRefClusters = cell2mat(cellfun(@(x) ~isempty(x),IdxClusters,'UniformOutput',false));
    PercentageInside = {PercentageInside{SelectRefClusters}}';
    IdxClusters = {IdxClusters{SelectRefClusters}}';
    
    % Update for the statistics calculation
    if ~isempty(name)
        shpRef = {shpRef{SelectRefClusters}}'; % Reference alpha shape selection
        refArea = refArea(SelectRefClusters); % Reference area selection
        refLocs = refLocs(SelectRefClusters); % Reference localization selection
    end
end

% Determine whether or not the co-localization clusters pass the
% threshold to be considered co-localized and then filter the ones that
% were from the ones that were not.
ColocalizedOrNot = cellfun(@(x) x>=overlap_thres, PercentageInside, 'UniformOutput',false); % Perform the thresholding to select the ones that were.

% Extract the clusters that contain co-localized clusters and remove the
% reference clusters that do not contain any of them anymore.
IdxClusters_colocalized = cellfun(@(x,y) x(y),IdxClusters,ColocalizedOrNot,'UniformOutput',false);
Percentages_colocalized = cellfun(@(x,y) x(y),PercentageInside,ColocalizedOrNot,'UniformOutput',false);
nonEmpty = find(~cellfun(@isempty,IdxClusters_colocalized));
IdxClusters_colocalized = {IdxClusters_colocalized{nonEmpty}}';
Percentages_colocalized = {Percentages_colocalized{nonEmpty}}';

% Update for the statistics calculation
if ~isempty(name)
    shpRef = {shpRef{nonEmpty}}'; % Reference alpha shape selection
    refArea = refArea(nonEmpty); % Reference area selection
    refLocs = refLocs(nonEmpty); % Reference localization selection
end

% Assign the clusters to be co-localized or not co-localized
ColocClusterIds = vertcat(IdxClusters_colocalized{:}); % Make one big column to extract it more easily
data_colocalized = {ClustersColoc{ColocClusterIds}}';
NotColocClusterIds = setdiff(1:size(ClustersColoc,1),ColocClusterIds)';
data_not_colocalized = {ClustersColoc{NotColocClusterIds}}';

if ~isempty(data_not_colocalized)
    data_not_colocalized = vertcat(data_not_colocalized{:});    
    data_not_localized.x_data = data_not_colocalized(:,1);
    data_not_localized.y_data = data_not_colocalized(:,2);
    data_not_localized.area = data_not_colocalized(:,3);
    data_not_localized.type = 'loc_list';
    data_not_localized.name = [data_colocalization.name,'_not_colocalized_',num2str(100*overlap_thres),'_percent'];
else
    data_not_localized = [];
end
if ~isempty(data_colocalized)
    data_colocalized = vertcat(data_colocalized{:});
    data_localized.x_data = data_colocalized(:,1);
    data_localized.y_data = data_colocalized(:,2);
    data_localized.area = data_colocalized(:,3);
    data_localized.type = 'loc_list';
    data_localized.name = [data_colocalization.name,'_colocalized_',num2str(100*overlap_thres),'_percent'];
else
    data_localized = [];
end

if PostProcess
    
    IdxCluster_postprocess = IdxClusters_colocalized;
    Percentages_postprocess = Percentages_colocalized;
    
    for j = 1:size(IdxClusters_colocalized,1)
            
        for k = 1:size(IdxClusters_colocalized{j},1)
            ColocCoords = ClustersColoc{IdxClusters_colocalized{j}(k)}(:,1:2);
            shpColoc = alphaShape(ColocCoords(:,1),ColocCoords(:,2));
            colocArea = area(shpColoc)*PixelSize*PixelSize; % Pixel size is 117 nm
            colocLocs = size(ColocCoords,1);
            
            if colocLocs < minLoc || colocArea < minArea
                IdxCluster_postprocess{j}(k) = NaN;
                Percentages_postprocess{j}(k) = NaN;
            end
        end
    
    end
    
    IdxCluster_postprocess = cellfun(@(x) x(~isnan(x)), IdxCluster_postprocess,'UniformOutput',false);
    Percentages_postprocess = cellfun(@(x) x(~isnan(x)), Percentages_postprocess,'UniformOutput',false);
    nonEmpty_postprocess = find(~cellfun(@isempty,IdxCluster_postprocess));
    IdxCluster_postprocess = {IdxCluster_postprocess{nonEmpty_postprocess}}';
    Percentages_postprocess = {Percentages_postprocess{nonEmpty_postprocess}}';
    if ~isempty(name)
        shpRef2 = {shpRef{nonEmpty_postprocess}}';
        refArea2 = refArea(nonEmpty_postprocess);
        refLocs2 = refLocs(nonEmpty_postprocess);
    end
    
    % Assign the clusters to be co-localized or not co-localized after
    % post processing
    ColocClusterIds_postprocess = vertcat(IdxCluster_postprocess{:});
    data_colocalized_postprocess = {ClustersColoc{ColocClusterIds_postprocess}}';
    NotColocClusterIds_postprocess = setdiff(ColocClusterIds,ColocClusterIds_postprocess)';
    data_removed_after_postprocess = {ClustersColoc{NotColocClusterIds_postprocess}}';
    
    if ~isempty(data_removed_after_postprocess)
        data_removed_after_postprocess = vertcat(data_removed_after_postprocess{:});
        data_removed_postprocess.x_data = data_removed_after_postprocess(:,1);
        data_removed_postprocess.y_data = data_removed_after_postprocess(:,2);
        data_removed_postprocess.area = data_removed_after_postprocess(:,3);
        data_removed_postprocess.type = 'loc_list';
        data_removed_postprocess.name = [data_colocalization.name,'_Removed_after_PostProcessing_From_Colocalized_',num2str(100*overlap_thres),'_percent_',num2str(minLoc),'minLoc_',num2str(minArea),'minArea'];
    else
        data_removed_postprocess = [];
    end
    if ~isempty(data_colocalized_postprocess)
        data_colocalized_postprocess = vertcat(data_colocalized_postprocess{:});
        data_localized_postprocess.x_data = data_colocalized_postprocess(:,1);
        data_localized_postprocess.y_data = data_colocalized_postprocess(:,2);
        data_localized_postprocess.area = data_colocalized_postprocess(:,3);
        data_localized_postprocess.type = 'loc_list';
        data_localized_postprocess.name = [data_colocalization.name,'_colocalized_and_postprocessed_',num2str(100*overlap_thres),'_percent_',num2str(minLoc),'minLoc_',num2str(minArea),'minArea'];
    else
        data_localized_postprocess = [];
    end

else
    data_removed_postprocess = [];
    data_localized_postprocess = [];
end
   
if ~isempty(name)
    
    Table = [];
    Table_PostProcess = [];
    
    for j = 1:size(IdxClusters_colocalized,1)
        
        colocArea = zeros(size(IdxClusters_colocalized{j},1),1);
        colocLocs = zeros(size(IdxClusters_colocalized{j},1),1);
        MajorAxis = zeros(size(IdxClusters_colocalized{j},1),1);
        MinorAxis = zeros(size(IdxClusters_colocalized{j},1),1);
        DistanceToBorder = zeros(size(IdxClusters_colocalized{j},1),1);
        Center = zeros(size(IdxClusters_colocalized{j},1),2);
        
        clear ColocCoords
        for k = 1:size(IdxClusters_colocalized{j},1)
            
            ColocCoords{k} = ClustersColoc{IdxClusters_colocalized{j}(k)}(:,1:2);
            shpColoc = alphaShape(ColocCoords{k}(:,1),ColocCoords{k}(:,2));
            colocArea(k,1) = area(shpColoc)*PixelSize*PixelSize; % Pixel size is 117 nm
            colocLocs(k,1) = size(ColocCoords{k},1);
            Center(k,:) = mean(ColocCoords{k});
            
            [~,RotatedData] = pca(ColocCoords{k}); % To rotate the data into the biggest possible major axis & smallest possible minor axis
            x_length = max(RotatedData(:,1))-min(RotatedData(:,1));
            y_length = max(RotatedData(:,2))-min(RotatedData(:,2));
            MajorAxis(k,1) = max([x_length,y_length])*PixelSize;
            MinorAxis(k,1) = min([x_length,y_length])*PixelSize;
            
            I = nearestNeighbor(shpRef{j}, Center(k,:));
            BorderPoints = shpRef{j}.Points(I,:);
            DistanceToBorder(k,1) = pdist2(Center(k,:),BorderPoints)*PixelSize;
                        
        end
        
        clear Idx Distances ColocBorderIdx ColocBorderDistance
        if size(Center,1) == 1
            Idx = NaN(1,3);
            Distances = NaN(1,3);
            ColocBorderDistance = NaN(1,2);
            ColocBorderIdx = NaN(1,2);
        elseif size(Center,1) == 2
            [Idx,Distances] = knnsearch(Center,Center,'K',2);
            Idx(:,3) = NaN;Distances(:,3) = NaN;
            
            Ids = cellfun(@(x) boundary(x(:,1),x(:,2)),ColocCoords,'UniformOutput',false);
            ColocBorders = cellfun(@(x,y) x(y,:),ColocCoords,Ids,'UniformOutput',false);
            
            [~, ColocBorderDistance] = knnsearch(ColocBorders{1},ColocBorders{2},'K',1);
            ColocBorderDistance = min(ColocBorderDistance);
            ColocBorderIdx(1,1) = 2; ColocBorderIdx(2,1) = 1;ColocBorderDistance(2,1) = ColocBorderDistance(1,1);
            ColocBorderIdx(:,2) = NaN;ColocBorderDistance(:,2) = NaN;
        else
            [IdxColocBorders,Distances] = knnsearch(Center,Center,'K',6);
            Idx = IdxColocBorders(:,1:3); Distances = Distances(:,1:3);
            
            Ids = cellfun(@(x) boundary(x(:,1),x(:,2)),ColocCoords,'UniformOutput',false);
            ColocBorders = cellfun(@(x,y) x(y,:),ColocCoords,Ids,'UniformOutput',false);
            for k = 1:size(IdxClusters_colocalized{j},1)
                clear DistColoc
                for l = 1:size(IdxColocBorders,2)-1
                    [~,AllDistances] = knnsearch(ColocBorders{k},ColocBorders{IdxColocBorders(k,l+1)},'K',1);
                    DistColoc(l) = min(AllDistances);
                end
                [ColocBorderDistance(k,:),IdsClosest] = mink(DistColoc,2);
                ColocBorderIdx(k,:) = IdxColocBorders(k,IdsClosest+1);
            end
        end
        Distances = Distances*PixelSize;
        ColocBorderDistance = ColocBorderDistance*PixelSize;
        
        Table = [Table; [j;NaN([size(IdxClusters_colocalized{j},1)-1,1])] [refLocs(j);NaN([size(IdxClusters_colocalized{j},1)-1,1])] [refArea(j);NaN([size(IdxClusters_colocalized{j},1)-1,1])] [refLocs(j)/refArea(j);NaN([size(IdxClusters_colocalized{j},1)-1,1])] (1:size(IdxClusters_colocalized{j},1))' colocLocs colocArea colocLocs./colocArea round(Percentages_colocalized{j}*100,2) MajorAxis MinorAxis Idx(:,2) Distances(:,2) Idx(:,3) Distances(:,3) ColocBorderIdx(:,1) ColocBorderDistance(:,1) ColocBorderIdx(:,2) ColocBorderDistance(:,2) DistanceToBorder];
        
    end
    
    if PostProcess
        
        for j = 1:size(IdxCluster_postprocess,1)
            
            colocArea = zeros(size(IdxCluster_postprocess{j},1),1);
            colocLocs = zeros(size(IdxCluster_postprocess{j},1),1);
            MajorAxis = zeros(size(IdxCluster_postprocess{j},1),1);
            MinorAxis = zeros(size(IdxCluster_postprocess{j},1),1);
            DistanceToBorder = zeros(size(IdxCluster_postprocess{j},1),1);
            Center = zeros(size(IdxCluster_postprocess{j},1),2);
            
            clear ColocCoords
            for k = 1:size(IdxCluster_postprocess{j},1)
                
                ColocCoords{k} = ClustersColoc{IdxCluster_postprocess{j}(k)}(:,1:2);
                shpColoc = alphaShape(ColocCoords{k}(:,1),ColocCoords{k}(:,2));
                colocArea(k,1) = area(shpColoc)*PixelSize*PixelSize; % Pixel size is 117 nm
                colocLocs(k,1) = size(ColocCoords{k},1);
                Center(k,:) = mean(ColocCoords{k});
                
                [~,RotatedData] = pca(ColocCoords{k}); % To rotate the data into the biggest possible major axis & smallest possible minor axis
                x_length = max(RotatedData(:,1))-min(RotatedData(:,1));
                y_length = max(RotatedData(:,2))-min(RotatedData(:,2));
                MajorAxis(k,1) = max([x_length,y_length])*PixelSize;
                MinorAxis(k,1) = min([x_length,y_length])*PixelSize;
                
                I = nearestNeighbor(shpRef2{j}, Center(k,:));
                BorderPoints = shpRef2{j}.Points(I,:);
                DistanceToBorder(k,1) = pdist2(Center(k,:),BorderPoints)*PixelSize;
                
            end
            
            clear Idx Distances ColocBorderIdx ColocBorderDistance
            if size(Center,1) == 1
                Idx = NaN(1,3);
                Distances = NaN(1,3);
                ColocBorderDistance = NaN(1,2);
                ColocBorderIdx = NaN(1,2);
            elseif size(Center,1) == 2
                [Idx,Distances] = knnsearch(Center,Center,'K',2);
                Idx(:,3) = NaN;Distances(:,3) = NaN;
                
                Ids = cellfun(@(x) boundary(x(:,1),x(:,2)),ColocCoords,'UniformOutput',false);
                ColocBorders = cellfun(@(x,y) x(y,:),ColocCoords,Ids,'UniformOutput',false);
                
                [~, ColocBorderDistance] = knnsearch(ColocBorders{1},ColocBorders{2},'K',1);
                ColocBorderDistance = min(ColocBorderDistance);
                ColocBorderIdx(1,1) = 2; ColocBorderIdx(2,1) = 1;ColocBorderDistance(2,1) = ColocBorderDistance(1,1);
                ColocBorderIdx(:,2) = NaN;ColocBorderDistance(:,2) = NaN;
            else
                [IdxColocBorders,Distances] = knnsearch(Center,Center,'K',6);
                Idx = IdxColocBorders(:,1:3); Distances = Distances(:,1:3);
                
                Ids = cellfun(@(x) boundary(x(:,1),x(:,2)),ColocCoords,'UniformOutput',false);
                ColocBorders = cellfun(@(x,y) x(y,:),ColocCoords,Ids,'UniformOutput',false);
                for k = 1:size(IdxCluster_postprocess{j},1)
                    clear DistColoc
                    for l = 1:size(IdxColocBorders,2)-1
                        [~,AllDistances] = knnsearch(ColocBorders{k},ColocBorders{IdxColocBorders(k,l+1)},'K',1);
                        DistColoc(l) = min(AllDistances);
                    end
                    [ColocBorderDistance(k,:),IdsClosest] = mink(DistColoc,2);
                    ColocBorderIdx(k,:) = IdxColocBorders(k,IdsClosest+1);
                end
            end
            Distances = Distances*PixelSize;
            ColocBorderDistance = ColocBorderDistance*PixelSize;
            
            Table_PostProcess = [Table_PostProcess; [j;NaN([size(IdxCluster_postprocess{j},1)-1,1])] [refLocs2(j);NaN([size(IdxCluster_postprocess{j},1)-1,1])] [refArea2(j);NaN([size(IdxCluster_postprocess{j},1)-1,1])] [refLocs2(j)/refArea2(j);NaN([size(IdxCluster_postprocess{j},1)-1,1])] (1:size(IdxCluster_postprocess{j},1))' colocLocs colocArea colocLocs./colocArea round(Percentages_postprocess{j}*100,2) MajorAxis MinorAxis Idx(:,2) Distances(:,2) Idx(:,3) Distances(:,3) ColocBorderIdx(:,1) ColocBorderDistance(:,1) ColocBorderIdx(:,2) ColocBorderDistance(:,2) DistanceToBorder];
            
        end
        
    end
    
else
    Table = [];
    Table_PostProcess = [];
end

close(wb)
warning('on','all') % Turn the warnings back on
end

function input_values = InputDialog()

    InputFigure = figure('Units','Normalized','Position',[.4 .4 .22 .2],'NumberTitle','off','Name','Co-localization input dialog','menubar','none');
    uicontrol('Style','text','Units','Normalized','Position',[.05 .85 .6 .1],'String','Overlap Percentage Threshold: ','FontSize',10,'HorizontalAlignment','left');
    Overlap = uicontrol('Style','Edit','Units','Normalized','Position',[.65 .85 .25 .1],'String','40','FontSize',10);
    uicontrol('Style','text','Units','Normalized','Position',[.1 .72 .6 .1],'String','Calculate statistics?','FontSize',10,'HorizontalAlignment','left');
    Statistics = uicontrol('Style','checkbox','Units','Normalized','Position',[.05 .72 .05 .1],'CallBack',@StatsCallback);
    PixelSize_text = uicontrol('Style','text','Units','Normalized','Position',[.05 .62 .9 .1],'String','PixelSize of the camera in nm: ','FontSize',10,'HorizontalAlignment','left','Enable','off');
    PixelSize = uicontrol('Style','Edit','Units','Normalized','Position',[.65 .62 .25 .1],'String','117','FontSize',10,'Enable','off');
    uicontrol('Style','text','Units','Normalized','Position',[.1 .49 .6 .1],'String','Postprocess?','FontSize',10,'HorizontalAlignment','left');
    PostProcess = uicontrol('Style','checkbox','Units','Normalized','Position',[.05 .49 .05 .1],'CallBack',@postProcessCallback);
    minLoc_text = uicontrol('Style','text','Units','Normalized','Position',[.05 .39 .9 .1],'String','Minimum number of localizations: ','FontSize',10,'HorizontalAlignment','left','Enable','off');
    minLoc = uicontrol('Style','Edit','Units','Normalized','Position',[.65 .39 .25 .1],'String','0','FontSize',10,'Enable','off');
    minArea_text = uicontrol('Style','text','Units','Normalized','Position',[.05 .27 .9 .1],'String','Minimum area (nm²): ','FontSize',10,'HorizontalAlignment','left','Enable','off');
    minArea = uicontrol('Style','Edit','Units','Normalized','Position',[.65 .27 .25 .1],'String','0','FontSize',10,'Enable','off');
    uicontrol('Style','PushButton','Units','Normalized','Position',[.05 .07 .45 .15],'String','OK','CallBack',@DoneCallback);
    uicontrol('Style','PushButton','Units','Normalized','Position',[.52 .07 .45 .15],'String','Cancel','CallBack',@CancelCallback);
    
    uiwait(InputFigure)
    
    function StatsCallback(~,~,~)
        if Statistics.Value == 1
            PixelSize_text.Enable = 'on';
            PixelSize.Enable = 'on';
        elseif Statistics.Value == 0
            PixelSize_text.Enable = 'off';
            PixelSize.Enable = 'off';
        end
    end

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
    
    function DoneCallback(~,~,~)
        uiresume(InputFigure)
        input_values{1} = get(Overlap,'String');
        input_values{2} = num2str(get(Statistics,'Value'));
        input_values{3} = get(PixelSize,'String');
        input_values{4} = num2str(get(PostProcess,'Value'));
        input_values{5} = get(minLoc,'String');
        input_values{6} = get(minArea,'String');
        close(InputFigure)
    end

    function CancelCallback(~,~,~)
        uiresume(InputFigure)
        close(InputFigure)
        input_values = {};
    end

end