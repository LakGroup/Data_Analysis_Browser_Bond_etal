function Locs_Extraction_Module_batch()

% Use data and listbox as global variables (access from anywhere).
global data listbox

% Make a new figure, and set its properties.
figure();
set(gcf,'name','Localization Extraction Module','NumberTitle','off','color','k','units','normalized','position',[0.25 0.2 0.5 0.6],'menubar','none','toolbar','figure');

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
            Expansion = str2double(input_values{1});
            BgExpansion = str2double(input_values{2});
            ColocThreshold = str2double(input_values{3});
            Stats = str2double(input_values{4});

            input_values_batch = inputdlg({'How many experiments are there?','Number of files per experiment:'},'Input',[1 50],{'3','[5 10 3]'});
            ExperimentNumber = str2double(input_values_batch{1});
            FilesPerExperiment = str2num(input_values_batch{2});

            StartStop = zeros(ExperimentNumber,2);
            for j = 1:ExperimentNumber
                if j == 1
                    StartStop(j,1) = 1;
                else
                   StartStop(j,1) = sum(FilesPerExperiment(1:j-1))+1;
                end
                StartStop(j,2) = sum(FilesPerExperiment(1:j));
            end

            if Stats == 1
                name = cell(ExperimentNumber,1);
                for j = 1:ExperimentNumber
                    [file,path] = uiputfile(['NewLysoMaskExtraction_Exp' num2str(j) '.xlsx'],['Please specify a name to save the statistics as for Experiment ' num2str(j)]); % Extract the name of the file given.
                    name{j} = fullfile(path,file); % Make it a full name to save it as later.

                    if exist(name{j},'file') == 2
                        delete(name{j});
                    end
                end

                uiwait(msgbox('This is the save name for the summary sheet for all experiment!'));
                [file,path] = uiputfile('SummaryForAll.xlsx','Please specify a name to save the summary statistics for all experiments'); % Extract the name of the file given.
                Summaryname = fullfile(path,file); % Make it a full name to save it as later.
                if exist(Summaryname,'file') == 2
                    delete(Summaryname);
                end
                        
                if BgExpansion ~= 0
                    AllSummaryTables = cell2table(cell(0,17));
                    AllSummaryTables.Properties.VariableNames = {'Name','Ref_Cluster_ID','Area_Ref_Cluster_pix²','#Locs_Inside','Density_#Locs/pix²','Coloc_Higher_Than_Background_(1=yes)','Enrichment Ratio','Circularity','Distance to Nucleus (nm)','Area_Donut_Around_pix²','#Locs_Inside_Donut','Density_Donut_#Locs/pix²',' ','Background_ID','Area_Background_pix²','#Locs_Background','Density_Background_#Locs/pix²'};
                else
                    AllSummaryTables = cell2table(cell(0,12));
                    AllSummaryTables.Properties.VariableNames = {'Name','Ref_Cluster_ID','Area_Ref_Cluster_pix²','#Locs_Inside','Density_#Locs/pix²','Coloc_Higher_Than_Background_(1=yes)','Enrichment Ratio','Circularity','Distance to Nucleus (nm)','Area_Donut_Around_pix²','#Locs_Inside_Donut','Density_Donut_#Locs/pix²'};
                end

                AllDataTable = cell2table(cell(0,4));
                AllDataTable.Properties.VariableNames = {'Average density inside cluster (locs/pix²)','Percentage of enriched clusters (Higher than threshold)','Average density around cluster (locs/pix²)','Average background density (locs/pix²)'};

            end

            wb = waitbar(0,['Running batch analysis. Currently at Experiment 0/' num2str(ExperimentNumber)]);
            for j = 1:ExperimentNumber
                waitbar(j/ExperimentNumber,wb,['Running batch analysis. Currently at Experiment ' num2str(j) '/' num2str(ExperimentNumber)]);

                % Check if the reference and colocalization data sets are not
                % empty. If they are not, continue the analysis, else, show an
                % error message.
                data_ref = data_reference(StartStop(j,1):StartStop(j,2));
                data_coloc = data_colocalization(StartStop(j,1):StartStop(j,2));
                if ~isempty(data_ref) && ~isempty(data_coloc)
                    % Check if the lengths of the reference and colocalization
                    % data sets are the same. If not, display an error.
                    if length(data_ref)==length(data_coloc)
                        % Pre-allocate and initialize for speed and convenience
                        % reasons.
                        data_inside = cell(length(data_ref),1);
                        data_insidedonut = cell(length(data_ref),1);
                        data_insideBgdonut = cell(length(data_ref),1);
                        data_notinside = cell(length(data_ref),1);
                        data_insideHigher = cell(length(data_ref),1);
                        data_insideLower = cell(length(data_ref),1);
                        data_ref_none = cell(length(data_ref),1);
                        data_ref_coloc = cell(length(data_ref),1);
                        TableCell = cell(length(data_ref),1);
                        if Stats == 1
                            AverageDensityInside = nan(length(data_ref),1);
                            AverageDensityDonut = nan(length(data_ref),1);
                            PercentageEnriched = nan(length(data_ref),1);
                            row_names = cell(length(data_ref),1);
                            if BgExpansion ~= 0
                                AverageDensityBg = nan(length(data_ref),1);
                            end
                        end
                        
                        % Start doing the actual calculations.
                        % Loop over the different reference data sets, and
                        % perform the colocalization (and postprocessing and
                        % statistics if selected).
                        for i = 1:length(data_ref)
                            % Perform the actual calculations.
                            counter = [i length(data_ref)]; % Set up the counter for the wait bar.
                            [data_inside{i},data_insidedonut{i},data_insideBgdonut{i},data_notinside{i},data_insideHigher{i},data_insideLower{i},data_ref_none{i},data_ref_coloc{i},TableCell{i}] = find_extract_locs(data_ref{i},data_coloc{i},Expansion,BgExpansion,ColocThreshold,Stats,counter); % See inner function for more explanation.
    
                            if Stats == 1
                                AverageDensityInside(i) = mean(cellfun(@(x) x, TableCell{i}(:,5)),'omitnan');
                                PercentageEnriched(i) = sum(cellfun(@(x) x, TableCell{i}(:,6)),'omitnan') / (numel(cellfun(@(x) x, TableCell{i}(:,6)))-1)*100;
                                AverageDensityDonut(i) = mean(cellfun(@(x) x, TableCell{i}(:,12)),'omitnan');
                                    row_names{i} = data_ref{i}.name;
                                if BgExpansion ~= 0
                                    AverageDensityBg(i) = mean(cellfun(@(x) x, TableCell{i}(:,17)),'omitnan');
                                else
                                    AverageDensityBg(i) = NaN;
                                end
                            end
                        end
                        if Stats == 1
                            column_names = {'Average density inside cluster (locs/pix²)','Percentage of enriched clusters (Higher than threshold)','Average density around cluster (locs/pix²)','Average background density (locs/pix²)'};
                            title = 'Densities per file'; % Set the title.
%                             table_data_plot([round(AverageDensityInside,2) round(PercentageEnriched,2) round(AverageDensityDonut,2) round(AverageDensityBg,2)],row_names,column_names,title); % Show the table.
                        end
                        
                        % Remove all the empty cells from the data, to avoid
                        % them being shown in the plots.
                        data_inside = data_inside(~cellfun('isempty',data_inside)); % Remove empty cells of the colocalized data.
                        data_insidedonut = data_insidedonut(~cellfun('isempty',data_insidedonut)); % Remove empty cells of the non-colocalized data.
                        data_insideBgdonut = data_insideBgdonut(~cellfun('isempty',data_insideBgdonut)); % Remove empty cells of the colocalized and postprocessed data.
                        data_notinside = data_notinside(~cellfun('isempty',data_notinside)); % Remove empty cells of the colocalized and postprocessed data.
                        data_insideHigher = data_insideHigher(~cellfun('isempty',data_insideHigher)); % Remove empty cells of the colocalized and postprocessed data.
                        data_insideLower = data_insideLower(~cellfun('isempty',data_insideLower)); % Remove empty cells of the colocalized and postprocessed data.
                        data_ref_none = data_ref_none(~cellfun('isempty',data_ref_none));
                        data_ref_coloc = data_ref_coloc(~cellfun('isempty',data_ref_coloc)); % Remove empty cells of the colocalized and postprocessed data.
                        TableCell = TableCell(~cellfun('isempty',TableCell));
    
                        if Stats == 1
                            if BgExpansion ~= 0
                                CompleteTable = cell2table(cell(0,17));
                                CompleteTable.Properties.VariableNames = {'Name','Ref_Cluster_ID','Area_Ref_Cluster_pix²','#Locs_Inside','Density_#Locs/pix²','Coloc_Higher_Than_Background_(1=yes)','Enrichment Ratio','Circularity','Distance to Nucleus (nm)','Area_Donut_Around_pix²','#Locs_Inside_Donut','Density_Donut_#Locs/pix²',' ','Background_ID','Area_Background_pix²','#Locs_Background','Density_Background_#Locs/pix²'};
                            else
                                CompleteTable = cell2table(cell(0,12));
                                CompleteTable.Properties.VariableNames = {'Name','Ref_Cluster_ID','Area_Ref_Cluster_pix²','#Locs_Inside','Density_#Locs/pix²','Coloc_Higher_Than_Background_(1=yes)','Enrichment Ratio','Circularity','Distance to Nucleus (nm)','Area_Donut_Around_pix²','#Locs_Inside_Donut','Density_Donut_#Locs/pix²'};
                            end    
    
                            Table_toWrite = cell(numel(data_ref),1);
                            Sheetname = cell(numel(data_ref),1);
                            for i = 1:numel(data_ref)
                                Table_toWrite{i} = cell2table(TableCell{i}); % Convert the cell to a table.
                                if BgExpansion ~= 0
                                    Table_toWrite{i}.Properties.VariableNames = {'Name','Ref_Cluster_ID','Area_Ref_Cluster_pix²','#Locs_Inside','Density_#Locs/pix²','Coloc_Higher_Than_Background_(1=yes)','Enrichment Ratio','Circularity','Distance to Nucleus (nm)','Area_Donut_Around_pix²','#Locs_Inside_Donut','Density_Donut_#Locs/pix²',' ','Background_ID','Area_Background_pix²','#Locs_Background','Density_Background_#Locs/pix²'};
                                else
                                    Table_toWrite{i}.Properties.VariableNames = {'Name','Ref_Cluster_ID','Area_Ref_Cluster_pix²','#Locs_Inside','Density_#Locs/pix²','Coloc_Higher_Than_Background_(1=yes)','Enrichment Ratio','Circularity','Distance to Nucleus (nm)','Area_Donut_Around_pix²','#Locs_Inside_Donut','Density_Donut_#Locs/pix²'};
                                end
                                
                                if length(data_ref{i}.name) > 31
                                    Sheetname{i} = data_ref{i}.name(1:31);
                                else
                                    Sheetname{i} = data_ref{i}.name;
                                end
                                CompleteTable = vertcat(CompleteTable,Table_toWrite{i});
                            end
                            writetable(CompleteTable,name{j},'sheet','SummarySheet'); % Write the table to the Excel file.
    
                            data_table = array2table([round(AverageDensityInside,2) round(PercentageEnriched,2) round(AverageDensityDonut,2) round(AverageDensityBg,2)]);
                            data_table.Properties.VariableNames = column_names;
                            data_table.Properties.RowNames = row_names;
                            writetable(data_table,name{j},'WriteRowNames',true,'sheet','QuickMaths');
    
                            for i = 1:numel(data_ref)
                                writetable(Table_toWrite{i},name{j},'sheet',Sheetname{i}); % Write the table to the Excel file.
                            end
                        end
                        
                        % Plot the four different data sets.
    %                     loc_list_plot(data_notinside); % Plot the colocalized and postprocessed data.
    %                     loc_list_plot(data_insideBgdonut); % Plot the noncolocalized data.
    %                     loc_list_plot(data_insidedonut); % Plot the noncolocalized data.
    %                     loc_list_plot(data_insideLower); % Plot the colocalized data.
                        loc_list_plot(data_insideHigher); % Plot the colocalized data.
    %                     loc_list_plot(data_inside); % Plot the colocalized data.
                        loc_list_plot(data_ref_none);
                        loc_list_plot(data_ref_coloc);
                        send_data_to_workspace(data_ref_coloc);
                        send_data_to_workspace(data_ref_none);
                        send_data_to_workspace(data_insideHigher);

                        AllSummaryTables = vertcat(AllSummaryTables,CompleteTable);
%                         AllDataTable = vertcat(AllDataTable,data_table);
                        
                    else
                        msgbox('Number of reference data is not equal to number of colocalization data'); % Display an error message if the size of the reference and the colocalization data set are not equal.
                    end
                else
                    msgbox('No reference or colocalization data was selected'); % Display an error message if either no reference or colocalization data set was selected.
                end
            end
            writetable(AllSummaryTables,Summaryname,'sheet','SummarySheet'); % Write the table to the Excel file.
%             writetable(AllDataTable,Summaryname,'WriteRowNames',true,'sheet','QuickMaths');
            close(wb)
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

function [data_inside,data_insidedonut,data_insideBgdonut,data_notinside,data_insideHigher,data_insideLower,data_ref_none,data_ref_coloc,TableCell] = find_extract_locs(data_reference,data_colocalization,Expansion,BgExpansion,ColocThreshold,Stats,counter_waitbar)

% Show a wait bar to follow the progress
wb = waitbar(0,['Data pair: ',num2str(counter_waitbar(1)),'/',num2str(counter_waitbar(2)) ' - Step 1: Extracting clusters from reference data...                                                          ']);
drawnow

% Extract the reference data and its individual clusters
DataRef = horzcat(data_reference.x_data,data_reference.y_data,data_reference.area); % Set up the reference data
Groups = findgroups(DataRef(:,3)); % Find unique groups and their number
ClustersRef = splitapply(@(x){(x)},DataRef(:,1:3),Groups);
for i = 1:length(ClustersRef)
    ClustersRef{i}(:,4) = i;
end

if Stats == 1
    if BgExpansion == 0
        TableCell = cell(numel(ClustersRef)+1,12);
    else
        TableCell = cell(numel(ClustersRef)+1,17);
        TableCell(:,13:17) = {NaN};
    end
    TableCell{1,1} = data_reference.name;
    TableCell(1,2:end) = {NaN};
    TableCell(2:end,1) = {NaN};
    TableCell(2:end,2) = num2cell((1:numel(ClustersRef))');
    
end

% Extract the second channel's data (no need to extract clusters)
DataColoc = horzcat(data_colocalization.x_data,data_colocalization.y_data,data_colocalization.area);

% Update the waitbar
if Stats ~= 1 || BgExpansion == 0
    waitbar(1/3,wb,['Data pair: ',num2str(counter_waitbar(1)),'/',num2str(counter_waitbar(2)) ' - Step 2: Making polygons...']);
else
    waitbar(1/5,wb,['Data pair: ',num2str(counter_waitbar(1)),'/',num2str(counter_waitbar(2)) ' - Step 2a: Making polygons...']);
end

% Create a set of polyshapes of the reference clusters, then expand these
% with x pixels (user-specified), and then subtract those 2 to get the
% donut.
% It is true that the expansion of one reference cluster can be inside an 
% other reference cluster. This will not be counted twice, as the data that
% is inside the reference clusters is removed from the pool to check of the
% 'donut' localizations
warning('off','all')

% Make polygons
IdxBoundary = cellfun(@(x) boundary(x(:,1:2),1),ClustersRef,'UniformOutput',false);
BoundaryCoords = cellfun(@(x,y) x(y,1:2),ClustersRef,IdxBoundary,'UniformOutput',false);
PolygonsRefs = cellfun(@(x) polyshape(x),BoundaryCoords,'UniformOutput',false);
PolygonsRefsExpanded = cellfun(@(x) polybuffer(x,Expansion),PolygonsRefs,'UniformOutput',false);

IsInsideCluster = cellfun(@(x) inpolygon(DataColoc(:,1),DataColoc(:,2),x.Vertices(:,1),x.Vertices(:,2)),PolygonsRefs,'UniformOutput',false);
IsInsideCluster2 = horzcat(IsInsideCluster{:});
IdxOverlapped = find(sum(IsInsideCluster2,2)>1);
for i = 1:numel(IdxOverlapped)
    IdxRef = find(IsInsideCluster2(IdxOverlapped(i),:));
    
    DistRef = zeros(numel(IdxRef),1);
    for j = 1:numel(IdxRef)
        Dist = pdist2(DataColoc(IdxOverlapped(i),1:2),BoundaryCoords{IdxRef(j)});
        DistRef(j) = min(Dist);
    end
    [~,IdxClosest] = min(DistRef);
    numbRefs = 1:numel(IdxRef);
    numbRefs(IdxClosest) = [];
    IsInsideCluster2(IdxOverlapped(i),IdxRef(numbRefs)) = 0;
    IsInsideCluster{IdxRef(numbRefs)}(IdxOverlapped(i)) = 0;
end
IsInsideCluster2 = logical(sum(IsInsideCluster2,2));
DataInsideCluster = DataColoc(IsInsideCluster2,:);
DataOutsideCluster = DataColoc(~IsInsideCluster2,:);
[~,Identifier] = max(horzcat(IsInsideCluster{:}),[],2);
DataInsideCluster(:,4) = Identifier(IsInsideCluster2);
IsInsideCluster = cellfun(@(x) sum(x),IsInsideCluster,'UniformOutput',false);

if BgExpansion ~= 0
    PolygonsRefsExpanded2 = cellfun(@(x) polybuffer(x,BgExpansion),PolygonsRefsExpanded,'UniformOutput',false);
    if Stats == 1
        PolygonsRefsExpanded_b = PolygonsRefsExpanded;
    end
end

if Stats == 1

    waitbar(2/5,wb,['Data pair: ',num2str(counter_waitbar(1)),'/',num2str(counter_waitbar(2)) ' - Step 2b: Cleaning areas around reference cluster...']);

    PolygonRefArea = cellfun(@(x) area(x),PolygonsRefs);
    PolygonRefperim = cellfun(@(x) perimeter(x),PolygonsRefs);
    PolygonRefCircularity = 4 .* pi .* PolygonRefArea ./ PolygonRefperim.^2;

    if isfield(data_reference,'coordinates')

        NucleusDist = zeros(numel(BoundaryCoords),1);
        for i = 1:numel(BoundaryCoords)

            IsInsideNucleus = cellfun(@(x) inpolygon(BoundaryCoords{i}(:,1),BoundaryCoords{i}(:,2),x(:,1),x(:,2)),data_reference.coordinates,'UniformOutput',false);
            IsInsideNucleus = sum(sum(horzcat(IsInsideNucleus{:}),2));
            
            if IsInsideNucleus == 0
                [~, NucleusDistance] = cellfun(@(x) knnsearch(BoundaryCoords{i},x,'K',1),data_reference.coordinates,'UniformOutput',false);
                NucleusDist(i) = min(cellfun(@min, NucleusDistance));
            end
        end
    else
        NucleusDist = NaN(numel(BoundaryCoords),1);
    end

    OverlappedDonuts = triu(overlaps(vertcat(PolygonsRefsExpanded{:})),1); % The 1 is because we do not care about the diagonal itself.

    [IdxFirst,IdxSecond] = find(OverlappedDonuts);
    [~,Idx] = sort(IdxFirst);
    OverlapIdx = [IdxFirst(Idx) IdxSecond(Idx)];
    
    ChainId = 1;
    Chain = cell(0,0);
    while ~isempty(OverlapIdx)
        Targets = OverlapIdx(1,:);
        OverlapIdx(1,:) = [];
        Chain{ChainId} = Targets;
        IdxToRemove = [];
        IdxToRemove_Old = [];
        j = 1;
        while j == 1 || numel(IdxToRemove) ~= numel(IdxToRemove_Old)
            j = 2;
            IdxToRemove_Old = IdxToRemove;
            for i = 1:size(OverlapIdx,1)
                if any(ismember(OverlapIdx(i,:),Targets)) && ~ismember(i,IdxToRemove)
                    Chain{ChainId} = horzcat(Chain{ChainId},OverlapIdx(i,~ismember(OverlapIdx(i,:),Targets)));
                    Targets = horzcat(Targets,OverlapIdx(i,~ismember(OverlapIdx(i,:),Targets)));
                    IdxToRemove = [IdxToRemove i];
                end
            end
        end
        OverlapIdx(IdxToRemove,:) = [];
        ChainId = ChainId + 1;
    end

    PolygonsRefs_New = PolygonsRefs;
    if ~isempty(Chain)
        for i = 1:numel(Chain)
            PolygonsRefsExpanded{Chain{i}(1)} = union(vertcat(PolygonsRefsExpanded{Chain{i}}));
            PolygonsRefsExpanded(Chain{i}(2:end)) = {polyshape()};
    
            PolygonsRefs_New{Chain{i}(1)} = union(vertcat(PolygonsRefs_New{Chain{i}}));
            PolygonsRefs_New(Chain{i}(2:end)) = {polyshape()};
        end
        Chain = horzcat(Chain{:});
    
        OtherIds = setdiff((1:numel(PolygonsRefs)),Chain);
        Chain = horzcat(Chain,OtherIds)+1;
    end

    PolygonRefExpandedArea = cellfun(@(x) area(x),PolygonsRefsExpanded);
    PolygonsRefs_NewArea = cellfun(@(x) area(x),PolygonsRefs_New);
    PolygonRefDonuts = PolygonRefExpandedArea - PolygonsRefs_NewArea;
    PolygonRefDonuts(PolygonRefDonuts==0) = NaN;

    if BgExpansion ~= 0

        waitbar(3/5,wb,['Data pair: ',num2str(counter_waitbar(1)),'/',num2str(counter_waitbar(2)) ' - Step 2c: Cleaning background areas...']);

        OverlappedBgDonuts = triu(overlaps(vertcat(PolygonsRefsExpanded2{:})),1); % The 1 is because we do not care about the diagonal itself.
        
        while sum(OverlappedBgDonuts(:)) ~= 0
            [IdxFirst,IdxSecond] = find(OverlappedBgDonuts);
            [~,Idx] = sort(IdxFirst);
            OverlapIdx = [IdxFirst(Idx) IdxSecond(Idx)];
            [UniqueFirsts,Idx] = unique(OverlapIdx(:,1),'stable');
            OverlapIdx = OverlapIdx(Idx,:);
            OverlapIdx(ismember(OverlapIdx(:,2),UniqueFirsts),:) = [];
            [UniqueSeconds,Idx] = unique(OverlapIdx(:,2),'stable');
            OverlapIdx = OverlapIdx(Idx,:);
            OverlapIdx(ismember(OverlapIdx(:,1),UniqueSeconds),:) = [];

            for i = 1:size(OverlapIdx,1)
                PolygonsRefsExpanded2{OverlapIdx(i,1)} = union(PolygonsRefsExpanded2{OverlapIdx(i,1)},PolygonsRefsExpanded2{OverlapIdx(i,2)});
                PolygonsRefsExpanded_b{OverlapIdx(i,1)} = union(PolygonsRefsExpanded_b{OverlapIdx(i,1)},PolygonsRefsExpanded_b{OverlapIdx(i,2)});
            end

            PolygonsRefsExpanded2(OverlapIdx(:,2)) = [];
            PolygonsRefsExpanded_b(OverlapIdx(:,2)) = [];

            OverlappedBgDonuts = triu(overlaps(vertcat(PolygonsRefsExpanded2{:})),1); % The 1 is because we do not care about the diagonal itself.
        end

        PolygonRefExpandedArea2 = cellfun(@(x) area(x),PolygonsRefsExpanded2);
        PolygonsRefsExpanded_bArea = cellfun(@(x) area(x),PolygonsRefsExpanded_b);
        PolygonBgDonutsArea = PolygonRefExpandedArea2 - PolygonsRefsExpanded_bArea;

        TableCell(2:numel(PolygonRefExpandedArea2)+1,14) = num2cell((1:numel(PolygonRefExpandedArea2))');
        TableCell(2:numel(PolygonRefExpandedArea2)+1,15) = num2cell(PolygonBgDonutsArea);
    end
end

warning('on','all')

% Update the waitbar
if Stats ~= 1 || BgExpansion == 0
    waitbar(3/3,wb,['Data pair: ',num2str(counter_waitbar(1)),'/',num2str(counter_waitbar(2)) ' - Step 3b: Extracting coordinates around reference clusters...']);
else
    waitbar(5/5,wb,['Data pair: ',num2str(counter_waitbar(1)),'/',num2str(counter_waitbar(2)) ' - Step 3b: Extracting coordinates around reference clusters...']);
end

% Check if localizations are inside the donut around the reference clusters
IsInsideExpanded = cellfun(@(x) inpolygon(DataOutsideCluster(:,1),DataOutsideCluster(:,2),x.Vertices(:,1),x.Vertices(:,2)),PolygonsRefsExpanded,'UniformOutput',false);
IsInsideExpanded2 = sum(horzcat(IsInsideExpanded{:}),2);
IsInsideExpanded2(IsInsideExpanded2>1) = 1;
IsInsideExpanded2 = logical(IsInsideExpanded2);
DataInsideDonut = DataOutsideCluster(IsInsideExpanded2,:);
DataNotInside = DataOutsideCluster(~IsInsideExpanded2,:);
IsInsideExpanded = cellfun(@(x) sum(x),IsInsideExpanded,'UniformOutput',false);
for i = 1:numel(IsInsideExpanded)
    if IsInsideExpanded{i} == 0
        IsInsideExpanded{i} = NaN;
    end
end

if BgExpansion ~= 0
    IsInsideBg = cellfun(@(x) inpolygon(DataNotInside(:,1),DataNotInside(:,2),x.Vertices(:,1),x.Vertices(:,2)),PolygonsRefsExpanded2,'UniformOutput',false);
    IsInsideBg2 = sum(horzcat(IsInsideBg{:}),2);
    IsInsideBg2(IsInsideBg2>1) = 1;
    IsInsideBg2 = logical(IsInsideBg2);
    DataInsideBgDonut = DataNotInside(IsInsideBg2,:);
    DataNotInside = DataNotInside(~IsInsideBg2,:);
    IsInsideBg = cellfun(@(x) sum(x),IsInsideBg,'UniformOutput',false);
else
    DataInsideBgDonut = [];
end

if Stats == 1

    TableCell(2:end,3) = num2cell(PolygonRefArea);
    TableCell(2:end,4) = IsInsideCluster;
    TableCell(2:end,5) = cellfun(@(x,y) x/y,TableCell(2:end,4),TableCell(2:end,3),'UniformOutput',false);
    TableCell(2:end,8) = num2cell(PolygonRefCircularity);
    TableCell(2:end,9) = num2cell(NucleusDist*0.117);
    TableCell(2:end,10) = num2cell(PolygonRefDonuts);
    TableCell(2:end,11) = IsInsideExpanded;
    TableCell(2:end,12) = cellfun(@(x,y) x/y,TableCell(2:end,11),TableCell(2:end,10),'UniformOutput',false);

    if BgExpansion ~= 0
        TableCell(2:numel(PolygonRefExpandedArea2)+1,16) = IsInsideBg;
        TableCell(2:numel(PolygonRefExpandedArea2)+1,17) = cellfun(@(x,y) x/y,TableCell(2:numel(PolygonRefExpandedArea2)+1,16),TableCell(2:numel(PolygonRefExpandedArea2)+1,15),'UniformOutput',false);
    end

    if ColocThreshold > 0
        if BgExpansion ~= 0
            AverageDensityBg = mean(cellfun(@(x) x, TableCell(:,17)),'omitnan');
            StdDensityBg = std(cellfun(@(x) x, TableCell(:,17)),'omitnan');
        else
            AverageDensityBg = mean(cellfun(@(x) x, TableCell(:,11)),'omitnan');
            StdDensityBg = std(cellfun(@(x) x, TableCell(:,11)),'omitnan');
        end
        DensityRefs = cell2mat(TableCell(2:end,5));
        DensityAbove = find(DensityRefs >= AverageDensityBg + ColocThreshold*StdDensityBg);
        DensityBelow = find(DensityRefs < AverageDensityBg + ColocThreshold*StdDensityBg);
        
        DataInsideCluster_Higher = DataInsideCluster(ismember(DataInsideCluster(:,4),DensityAbove),:);
        DataInsideCluster_Lower = DataInsideCluster(ismember(DataInsideCluster(:,4),DensityBelow),:);

        DensityAll = zeros(numel(DensityRefs),1);
        DensityAll(DensityAbove) = 1;
        DensityAbove = logical(DensityAll);
        DensityAll = zeros(numel(DensityRefs),1);
        DensityAll(DensityBelow) = 1;
        DensityBelow = logical(DensityAll);

        TableCell(2:end,6) = num2cell(double(DensityAbove));
        TableCell(2:end,7) = num2cell(DensityRefs./AverageDensityBg);
    else
        DataInsideCluster_Higher = [];
        DataInsideCluster_Lower = [];

        TableCell(2:end,6) = 0;
    end

    if ~isempty(Chain)
        TableCell(2:end,3:12) = TableCell(Chain,3:12);

        ClustersRef = ClustersRef(Chain-1);
        for i = 1:length(ClustersRef)
            ClustersRef{i}(:,4) = i;
        end
        DensityAbove = DensityAbove(Chain-1);
        DensityBelow = DensityBelow(Chain-1);
    end

end

% Extract data if it is inside the reference clusters
if ~isempty(DataInsideCluster)
    data_inside.x_data = DataInsideCluster(:,1);
    data_inside.y_data = DataInsideCluster(:,2);
    data_inside.area = DataInsideCluster(:,3);
    data_inside.identifier = DataInsideCluster(:,4);
    data_inside.type = 'loc_list';
    data_inside.name = [data_colocalization.name,'_InsideCluster_' num2str(Expansion) 'PixelExpansion_' num2str(BgExpansion) 'BgPixelExpansion'];
    if isfield(data_reference,'coordinates')
        data_inside.coordinates = data_reference.coordinates;
    end
else
    data_inside = [];
end

if ColocThreshold > 0
    % Extract data if it is inside the reference clusters
    if ~isempty(DataInsideCluster_Higher)
        data_insideHigher.x_data = DataInsideCluster_Higher(:,1);
        data_insideHigher.y_data = DataInsideCluster_Higher(:,2);
        data_insideHigher.area = DataInsideCluster_Higher(:,3);
        data_insideHigher.identifier = DataInsideCluster_Higher(:,4);
        data_insideHigher.type = 'loc_list';
        data_insideHigher.name = [data_colocalization.name,'_InsideClusterHigher_' num2str(Expansion) 'PixelExpansion_' num2str(BgExpansion) 'BgPixelExpansion'];
        if isfield(data_reference,'coordinates')
            data_insideHigher.coordinates = data_reference.coordinates;
        end
    else
        data_insideHigher = [];
    end
    
    % Extract data if it is inside the reference clusters
    if ~isempty(DataInsideCluster_Lower)
        data_insideLower.x_data = DataInsideCluster_Lower(:,1);
        data_insideLower.y_data = DataInsideCluster_Lower(:,2);
        data_insideLower.area = DataInsideCluster_Lower(:,3);
        data_insideLower.identifier = DataInsideCluster_Lower(:,4);
        data_insideLower.type = 'loc_list';
        data_insideLower.name = [data_colocalization.name,'_InsideClusterLower_' num2str(Expansion) 'PixelExpansion_' num2str(BgExpansion) 'BgPixelExpansion'];
        if isfield(data_reference,'coordinates')
            data_insideLower.coordinates = data_reference.coordinates;
        end
    else
        data_insideLower = [];
    end
else
    data_insideHigher = [];
    data_insideLower = [];
end

% Extract data if it is around the reference clusters
if ~isempty(DataInsideDonut)
    data_insidedonut.x_data = DataInsideDonut(:,1);
    data_insidedonut.y_data = DataInsideDonut(:,2);
    data_insidedonut.area = DataInsideDonut(:,3);
    data_insidedonut.type = 'loc_list';
    data_insidedonut.name = [data_colocalization.name,'_InsideDonut_' num2str(Expansion) 'PixelExpansion_' num2str(BgExpansion) 'BgPixelExpansion'];
    if isfield(data_reference,'coordinates')
        data_insidedonut.coordinates = data_reference.coordinates;
    end
else
    data_insidedonut = [];
end

% All the rest of the data (not inside or around a given area of the
% reference cluster)
if ~isempty(DataInsideBgDonut)
    data_insideBgdonut.x_data = DataInsideBgDonut(:,1);
    data_insideBgdonut.y_data = DataInsideBgDonut(:,2);
    data_insideBgdonut.area = DataInsideBgDonut(:,3);
    data_insideBgdonut.type = 'loc_list';
    data_insideBgdonut.name = [data_colocalization.name,'_InsideBgDonut_' num2str(Expansion) 'PixelExpansion_' num2str(BgExpansion) 'BgPixelExpansion'];
    if isfield(data_reference,'coordinates')
        data_insideBgdonut.coordinates = data_reference.coordinates;
    end
else
    data_insideBgdonut = [];
end

% All the rest of the data (not inside or around a given area of the
% reference cluster)
if ~isempty(DataNotInside)
    data_notinside.x_data = DataNotInside(:,1);
    data_notinside.y_data = DataNotInside(:,2);
    data_notinside.area = DataNotInside(:,3);
    data_notinside.type = 'loc_list';
    data_notinside.name = [data_colocalization.name,'_NOTInside_' num2str(Expansion) 'PixelExpansion_' num2str(BgExpansion) 'BgPixelExpansion'];
    if isfield(data_reference,'coordinates')
        data_notinside.coordinates = data_reference.coordinates;
    end
else
    data_notinside = [];
end

if sum(double(DensityBelow)) > 0
    EmptyRefs = ClustersRef(DensityBelow);
    EmptyRefs = vertcat(EmptyRefs{:});

    data_ref_none.x_data = EmptyRefs(:,1);
    data_ref_none.y_data = EmptyRefs(:,2);
    data_ref_none.area = EmptyRefs(:,3);
    data_ref_none.identifier = EmptyRefs(:,4);
    data_ref_none.type = 'loc_list';
    data_ref_none.name = [data_reference.name,'_EmptyRefClusters'];
    if isfield(data_reference,'coordinates')
        data_ref_none.coordinates = data_reference.coordinates;
    end
else
    data_ref_none = [];
end

if sum(double(DensityAbove)) > 0
    ColocRefs = ClustersRef(DensityAbove);
    ColocRefs = vertcat(ColocRefs{:});

    data_ref_coloc.x_data = ColocRefs(:,1);
    data_ref_coloc.y_data = ColocRefs(:,2);
    data_ref_coloc.area = ColocRefs(:,3);
    data_ref_coloc.identifier = ColocRefs(:,4);
    data_ref_coloc.type = 'loc_list';
    data_ref_coloc.name = [data_reference.name,'_ColocRefsClusters'];
    if isfield(data_reference,'coordinates')
        data_ref_coloc.coordinates = data_reference.coordinates;
    end
else
    data_ref_coloc = [];
end

if Stats == 0
    TableCell = [];
end

close(wb)
end

function input_values = InputDialog()

    %  Create a figure for the input dialog and show the parameter the user
    %  has to provide (i.e., the expansion factor, in pixels)
    InputFigure = figure('Units','Normalized','Position',[.4 .4 .25 .2],'NumberTitle','off','Name','Localization Extraction','menubar','none');
    uicontrol('Style','text','Units','Normalized','Position',[.05 .85 .6 .1],'String','Ring Expansion (pixels): ','FontSize',10,'HorizontalAlignment','right');
    Expansion = uicontrol('Style','Edit','Units','Normalized','Position',[.72 .85 .12 .1],'String','2','FontSize',10);
    uicontrol('Style','text','Units','Normalized','Position',[.05 .65 .6 .1],'String','Background Ring Expansion (pixels): ','FontSize',10,'HorizontalAlignment','right');
    BgExpansion = uicontrol('Style','Edit','Units','Normalized','Position',[.72 .65 .12 .1],'String','3','FontSize',10);
    uicontrol('Style','text','Units','Normalized','Position',[.05 .45 .6 .1],'String','Colocalization threshold: ','FontSize',10,'HorizontalAlignment','right');
    ColocThreshold = uicontrol('Style','Edit','Units','Normalized','Position',[.72 .45 .12 .1],'String','3','FontSize',10);
    uicontrol('Style','text','Units','Normalized','Position',[.05 .25 .6 .1],'String','Calculate statistics?','FontSize',10,'HorizontalAlignment','right');
    Statistics = uicontrol('Style','checkbox','Units','Normalized','Position',[.75 .25 .1 .1],'Value',1);
    uicontrol('Style','PushButton','Units','Normalized','Position',[.05 .07 .45 .15],'String','OK','CallBack',@DoneCallback);
    uicontrol('Style','PushButton','Units','Normalized','Position',[.52 .07 .45 .15],'String','Cancel','CallBack',@CancelCallback);
    
    % Wait until the user does something with this input dialog
    uiwait(InputFigure)
    
    % Specify the callback of the 'done' button
    function DoneCallback(~,~,~)
        uiresume(InputFigure)
        input_values{1} = get(Expansion,'String');
        input_values{2} = get(BgExpansion,'String');
        input_values{3} = get(ColocThreshold,'String');
        input_values{4} = num2str(get(Statistics,'Value'));
        close(InputFigure)
    end

    % Specify the callback of the 'cancel' button
    function CancelCallback(~,~,~)
        uiresume(InputFigure)
        close(InputFigure)
        input_values = {};
    end

end