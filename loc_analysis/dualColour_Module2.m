function dualColour_Module2()

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
uicontrol('style','pushbutton','units','normalized','position',[0.4,0.95,0.2,0.05],'string','Start Dual Colour Analysis','ForegroundColor','b','Callback',{@colocalization_callback},'FontSize',12);

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
        answer = inputdlg({'Overlap Percentage Threshold: '},'Input',[1 50],{'40'});
        MinOverlap = str2double(answer{1})/100;
        [file,path] = uiputfile('*.xlsx','Please specify a name to save the output as'); % Extract the name of the file given.
        name = fullfile(path,file); % Make it a full name to save it as later.

        % Delete the file if it exists. Avoid extra entries if the
        % file already existed before.
        if exist(name,'file') == 2
            delete(name);
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
                Table = cell(length(data_reference),1);
                data_localized = cell(length(data_reference),1);
                data_not_localized = cell(length(data_reference),1);
                shpRef = cell(length(data_reference),1);
                BorderPoints = cell(length(data_reference),1);

                % Start doing the actual calculations.
                % Loop over the different reference data sets, and
                % perform the colocalization (and postprocessing and
                % statistics if selected).
                for i = 1:length(data_reference)
                    % Perform the actual calculations.
                    counter = [i length(data_reference)]; % Set up the counter for the wait bar.
                    [data_localized{i}, data_not_localized{i}, Table{i}, DistanceToBorder_noncoloc{i}, NonColocs{i}, PercentageOverThreshold(i)] = find_dual_colour(data_reference{i},data_colocalization{i},MinOverlap,counter); % See inner function for more explanation.

                    try
                        percentage(i,1) = 100*length(unique(data_localized{i}.area))/length(unique(data_colocalization{i}.area)); % The percentage is calculated as unique areas in the colocalized data, divided by unique areas in the colocalization data (this is the data before the calculation was done). The area is used as a unique identifier for each cluster.
                        percentage(i,2) = 100*PercentageOverThreshold(i)/length(unique(data_colocalization{i}.area)); % The percentage is calculated as unique areas in the colocalized data, divided by unique areas in the colocalization data (this is the data before the calculation was done). The area is used as a unique identifier for each cluster.
                    catch
                        percentage(i,1) = 0; % If the above calculation failed (i.e., cell is empty), overlap = 0.
                        percentage(i,2) = 100*PercentageOverThreshold(i)/length(unique(data_colocalization{i}.area)); % The percentage is calculated as unique areas in the colocalized data, divided by unique areas in the colocalization data (this is the data before the calculation was done). The area is used as a unique identifier for each cluster.
                    end
                    % Set the row names, according to the name of the
                    % colocalization data set.
                    row_names{i} = data_colocalization{i}.name;
                end

                % Set the title of the table being shown, and actually
                % show the table.
                title = 'Colocalization'; % Set the title.
                column_names = {'Percentage of colocalized clusters','Percentage of colocalized clusters over threshold'};
                table_data_plot(percentage,row_names,column_names,title); % Show the table.

                % Remove all the empty cells from the data, to avoid
                % them being shown in the plots.
                data_localized = data_localized(~cellfun('isempty',data_localized)); % Remove empty cells of the colocalized data.
                data_not_localized = data_not_localized(~cellfun('isempty',data_not_localized)); % Remove empty cells of the non-colocalized data.
                
                % Plot the different data sets.
                loc_list_plot(data_localized); % Plot the colocalized data.
                loc_list_plot(data_not_localized); % Plot the noncolocalized data.

                % Make an empty row first, with 1 less column than
                % the total number of columns (to keep a space for
                % the data name).
                EmptyRow = cell(1,11); % Make an empty cell.
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

                    else
                        Table_noPostProcess = [Table_noPostProcess; TableName; num2cell(Table{i})]; % Append the table (before postprocessing) after the name of the reference data.

                    end
                end

                % Make a table out of the cells, set the column
                % variable names and write it as a .xlsx file.
                Table_noPostProcess = cell2table(Table_noPostProcess); % Convert the cell to a table.
                Table_noPostProcess.Properties.VariableNames = {'Cluster_ID','Percentage_Overlap','Area (nm²)','Number_Of_Localizations','Perimeter (nm)','Circularity','MajorAxis (nm)','MinorAxis (nm)','AspectRatio','Distance_To_Closter_Ref_Border (nm)','Area_Ref (nm²)','Number_Of_Localizations_Ref'}; % Set the column variable names.
                writetable(Table_noPostProcess,name,'sheet','SummarySheet'); % Write the table to the Excel file, in a Summary sheet.

                % Write every data set also as an individual sheet
                % in the Excel file. This might be useful for a
                % more detailed analysis. !!This process is slow!!
                for i = 1:length(data_reference)
                    TableName = horzcat({data_reference{i}.name},EmptyRow); % Concatenate the title and the empty columns.
                    IndividualTable = [TableName; num2cell(Table{i})]; % Append the table (before postprocessing) after the name of the reference data.
                    TableSheet = cell2table(IndividualTable); % Convert the table of each reference data set to a table.
                    TableSheet.Properties.VariableNames = {'Cluster_ID','Percentage_Overlap','Area (nm²)','Number_Of_Localizations','Perimeter (nm)','Circularity','MajorAxis (nm)','MinorAxis (nm)','AspectRatio','Distance_To_Closter_Ref_Border (nm)','Area_Ref (nm²)','Number_Of_Localizations_Ref'}; % Set the column variable names.
                    writetable(TableSheet,name,'sheet',['Data ' num2str(i)]); % Write the table to the Excel file, in an individual sheet for each reference data.
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

function [data_localized, data_not_localized, Table, DistanceToBorder_noncoloc, NonColocs, PercentageOverThreshold] = find_dual_colour(data_reference,data_colocalization,MinOverlap,counter_waitbar)

PixelSize = 117;

wb = waitbar(0,['Data pair: ',num2str(counter_waitbar(1)),'/',num2str(counter_waitbar(2)) ' - Step 1: Extracting clusters from data...']);
drawnow

DataRef = horzcat(data_reference.x_data,data_reference.y_data,data_reference.area); % Set up the reference data
Groups = findgroups(DataRef(:,3)); % Find unique groups and their number
ClustersRef = splitapply(@(x){(x)},DataRef(:,1:3),Groups);

DataColoc = horzcat(data_colocalization.x_data,data_colocalization.y_data,data_colocalization.area); % Extract the data
Groups = findgroups(DataColoc(:,3)); % Find unique groups and their number
ClustersColoc = splitapply(@(x){(x)},DataColoc(:,1:3),Groups); % Split the clusters into the corresponding groups

waitbar(1/4,wb,['Data pair: ',num2str(counter_waitbar(1)),'/',num2str(counter_waitbar(2)) ' - Step 2: Filtering co-localization clusters...']);

% Extract the colocalization channel cluster centers
ColocCenter = cell2mat(cellfun(@(x) mean(x(:,1:2)), ClustersColoc,'UniformOutput',false));

% Pre-allocate and initialize for speed and convenience reasons
PolyLowResRefExpanded = cell(size(ClustersRef,1),1);

% Create a set of low-resolution coordinates of all the reference cluster
% coordinates
warning('off','all') % Turn off warnings for the creation of the polygons
for j = 1:size(ClustersRef,1)
    % Update the wait bar
    waitbar(1/4+(j/size(ClustersRef,1))/4,wb,['Data pair: ',num2str(counter_waitbar(1)),'/',num2str(counter_waitbar(2)) ' - Step 3: Filtering co-localization clusters...']);

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


waitbar(2/4,wb,['Data pair: ',num2str(counter_waitbar(1)),'/',num2str(counter_waitbar(2)) ' - Step 4: Performing dual colour analysis...']);

% Pre-allocate for speed reasons
PercentageInside = cell(size(ClustersRef,1),1);
shpRef = cell(size(ClustersRef,1),1);

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

    % Pre-allocate for speed reasons
    PercentageInside{j} = zeros(size(IdxClusters{j},1),1);
    % Loop over the different potential overlapping clusters and
    % calculate their overlap with the reference cluster
    for k = 1:size(IdxClusters{j},1)
        % Update the wait bar
        waitbar(2/4+(j/size(ClustersRef,1))/4,wb,['Data pair: ',num2str(counter_waitbar(1)),'/',num2str(counter_waitbar(2)) ' - Step 3: Calculating overlap... - Reference cluster ' num2str(j) ' of ' num2str(size(ClustersRef,1))]);

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
    shpRef = {shpRef{SelectRefClusters}}'; % Reference alpha shape selection
end

% Determine whether or not the co-localization clusters pass the
% threshold to be considered co-localized and then filter the ones that
% were from the ones that were not.
ColocalizedOrNot = cellfun(@(x) x>0, PercentageInside, 'UniformOutput',false); % Perform the thresholding to select the ones that were.
ColocalizedOrNot2 = cellfun(@(x) x>=MinOverlap, PercentageInside, 'UniformOutput',false);
ColocalizedOrNot2 = vertcat(ColocalizedOrNot2{:});
PercentageOverThreshold = sum(ColocalizedOrNot2);


% Extract the clusters that contain co-localized clusters and remove the
% reference clusters that do not contain any of them anymore.
IdxClusters_colocalized = cellfun(@(x,y) x(y),IdxClusters,ColocalizedOrNot,'UniformOutput',false);
Percentages_colocalized = cellfun(@(x,y) x(y),PercentageInside,ColocalizedOrNot,'UniformOutput',false);
nonEmpty = find(~cellfun(@isempty,IdxClusters_colocalized));
IdxClusters_colocalized = {IdxClusters_colocalized{nonEmpty}}';
Percentages_colocalized = {Percentages_colocalized{nonEmpty}}';

% Assign the clusters to be co-localized or not co-localized
ColocClusterIds = vertcat(IdxClusters_colocalized{:}); % Make one big column to extract it more easily
data_colocalized = {ClustersColoc{ColocClusterIds}}';
Percentages_colocalized = vertcat(Percentages_colocalized{:});Percentages_colocalized = Percentages_colocalized * 100;
NotColocClusterIds = setdiff(1:size(ClustersColoc,1),ColocClusterIds)';
data_not_colocalized = {ClustersColoc{NotColocClusterIds}}';

if ~isempty(data_not_colocalized)
    data_not_colocalized = vertcat(data_not_colocalized{:});
    data_not_localized.x_data = data_not_colocalized(:,1);
    data_not_localized.y_data = data_not_colocalized(:,2);
    data_not_localized.area = data_not_colocalized(:,3);
    data_not_localized.type = 'loc_list';
    data_not_localized.name = [data_colocalization.name,'_not_colocalized'];
else
    data_not_localized = [];
end
if ~isempty(data_colocalized)
    data_colocalized = vertcat(data_colocalized{:});
    data_localized.x_data = data_colocalized(:,1);
    data_localized.y_data = data_colocalized(:,2);
    data_localized.area = data_colocalized(:,3);
    data_localized.type = 'loc_list';
    data_localized.name = [data_colocalization.name,'_colocalized'];
else
    data_localized = [];
end

waitbar(3.5/4,wb,['Data pair: ',num2str(counter_waitbar(1)),'/',num2str(counter_waitbar(2)) ' - Step 5: Calculating statistics...']);

[Percentages_coloc,Idx] = sort(Percentages_colocalized,'descend');
ColocClusterIds = ColocClusterIds(Idx);
Percentages_noncoloc = zeros(numel(NotColocClusterIds),1);

Area_coloc = zeros(size(ColocClusterIds,1),1);
Locs_coloc = zeros(size(ColocClusterIds,1),1);
Perim_coloc = zeros(size(ColocClusterIds,1),1);
Circ_coloc = zeros(size(ColocClusterIds,1),1);
MajorAxis_coloc = zeros(size(ColocClusterIds,1),1);
MinorAxis_coloc = zeros(size(ColocClusterIds,1),1);
AspectRatio_coloc = zeros(size(ColocClusterIds,1),1);
DistanceToBorder_coloc = zeros(size(ColocClusterIds,1),1);
Area_coloc_Dummy = NaN(size(ColocClusterIds,1),1);
Locs_coloc_Dummy = NaN(size(ColocClusterIds,1),1);

for j = 1:size(ColocClusterIds,1)

    ColocCoords = ClustersColoc{ColocClusterIds(j)}(:,1:2);
    shpColoc = alphaShape(ColocCoords(:,1),ColocCoords(:,2));

    Area_coloc(j,1) = area(shpColoc)*PixelSize*PixelSize; % Pixel size is 117 nm
    Locs_coloc(j,1) = size(ColocCoords,1);

    I = boundary(shpColoc.Points,0);
    BorderPoints = shpColoc.Points(I,:);
    PolygonBorderPoints = polyshape(BorderPoints(:,1),BorderPoints(:,2));
    Area_polygon = area(PolygonBorderPoints)*PixelSize*PixelSize;
    Perim_coloc(j,1) = perimeter(PolygonBorderPoints)*PixelSize;
    Circ_coloc(j,1) = 4*pi*Area_polygon/Perim_coloc(j,1)^2;

    [~,RotatedData] = pca(ColocCoords); % To rotate the data into the biggest possible major axis & smallest possible minor axis
    x_length = max(RotatedData(:,1))-min(RotatedData(:,1));
    y_length = max(RotatedData(:,2))-min(RotatedData(:,2));
    MajorAxis_coloc(j,1) = max([x_length,y_length])*PixelSize;
    MinorAxis_coloc(j,1) = min([x_length,y_length])*PixelSize;
    AspectRatio_coloc(j,1) = MajorAxis_coloc(j,1) / MinorAxis_coloc(j,1);

end

DataRef = horzcat(data_reference.x_data,data_reference.y_data,data_reference.area); % Set up the reference data
Groups = findgroups(DataRef(:,3)); % Find unique groups and their number
ClustersRef = splitapply(@(x){(x)},DataRef(:,1:3),Groups);
CentersRef = cell2mat(cellfun(@(x) x(:,1:2),cellfun(@mean,ClustersRef,'UniformOutput',false),'UniformOutput',false));
NonColocs = {ClustersColoc{NotColocClusterIds}};
NonColocs = cellfun(@(x) x(:,1:3), NonColocs, 'UniformOutput', false);

for j = 1:size(ClustersRef,1)

    xRef = ClustersRef{j}(:,1);
    yRef = ClustersRef{j}(:,2);
    shpRef{j,1} = alphaShape(xRef,yRef);
    CritAlpha = criticalAlpha(shpRef{j},'one-region');
    shpRef{j}.Alpha = CritAlpha;

end

Area_noncoloc = zeros(size(NotColocClusterIds,1),1);
Locs_noncoloc = zeros(size(NotColocClusterIds,1),1);
Perim_noncoloc = zeros(size(NotColocClusterIds,1),1);
Circ_noncoloc = zeros(size(NotColocClusterIds,1),1);
MajorAxis_noncoloc = zeros(size(NotColocClusterIds,1),1);
MinorAxis_noncoloc = zeros(size(NotColocClusterIds,1),1);
AspectRatio_noncoloc = zeros(size(NotColocClusterIds,1),1);
DistanceToBorder_noncoloc = zeros(size(NotColocClusterIds,1),1);
Area_noncoloc_Dummy = NaN(size(NotColocClusterIds,1),1);
Locs_noncoloc_Dummy = NaN(size(NotColocClusterIds,1),1);

for j = 1:size(NonColocs,2)

    shpNonColoc = alphaShape(NonColocs{j}(:,1),NonColocs{j}(:,2));

    Area_noncoloc(j,1) = area(shpNonColoc)*PixelSize*PixelSize; % Pixel size is 117 nm
    Locs_noncoloc(j,1) = size(NonColocs{j},1);

    I = boundary(shpNonColoc.Points,0);
    BorderPoints = shpNonColoc.Points(I,:);
    PolygonBorderPoints = polyshape(BorderPoints(:,1),BorderPoints(:,2));
    Area_polygon = area(PolygonBorderPoints)*PixelSize*PixelSize;
    Perim_noncoloc(j,1) = perimeter(PolygonBorderPoints)*PixelSize;
    Circ_noncoloc(j,1) = 4*pi*Area_polygon/Perim_noncoloc(j,1)^2;

    [~,RotatedData] = pca(NonColocs{j}(:,1:2)); % To rotate the data into the biggest possible major axis & smallest possible minor axis
    x_length = max(RotatedData(:,1))-min(RotatedData(:,1));
    y_length = max(RotatedData(:,2))-min(RotatedData(:,2));
    MajorAxis_noncoloc(j,1) = max([x_length,y_length])*PixelSize;
    MinorAxis_noncoloc(j,1) = min([x_length,y_length])*PixelSize;
    AspectRatio_noncoloc(j,1) = MajorAxis_noncoloc(j,1) / MinorAxis_noncoloc(j,1);

    IdxToRef = knnsearch(CentersRef,mean(BorderPoints),'K',10);
    BoundariesDist = zeros(numel(IdxToRef),1);
    for k = 1:size(shpRef,1)

        [~,Distances] = nearestNeighbor(shpRef{k}, BorderPoints);
        BoundariesDist(k) = min(Distances);

    end
    DistanceToBorder_noncoloc(j,1) = min(BoundariesDist)*PixelSize;

end

Percentages_Ref = NaN(size(shpRef,1),1);
Area_Ref_Dummy = NaN(size(shpRef,1),1);
Locs_Ref_Dummy = NaN(size(shpRef,1),1);
Perim_Ref = NaN(size(shpRef,1),1);
Circ_Ref = NaN(size(shpRef,1),1);
MajorAxis_Ref = NaN(size(shpRef,1),1);
MinorAxis_Ref = NaN(size(shpRef,1),1);
AspectRatio_Ref = NaN(size(shpRef,1),1);
DistanceToBorder_Ref = NaN(size(shpRef,1),1);
ClusterID_Ref = NaN(size(shpRef,1),1);
Area_Ref = cellfun(@(x) area(x),shpRef,'UniformOutput',false);
Area_Ref = vertcat(Area_Ref{:})*117*117;
Locs_Ref = cellfun(@(x) size(x.Points,1),shpRef,'UniformOutput',false);
Locs_Ref = vertcat(Locs_Ref{:});

Percentages = vertcat(Percentages_coloc,Percentages_noncoloc,Percentages_Ref);
Area = vertcat(Area_coloc,Area_noncoloc,Area_Ref_Dummy);
Locs = vertcat(Locs_coloc,Locs_noncoloc,Locs_Ref_Dummy);
Perim = vertcat(Perim_coloc,Perim_noncoloc,Perim_Ref);
Circ = vertcat(Circ_coloc,Circ_noncoloc,Circ_Ref);
MajorAxis = vertcat(MajorAxis_coloc,MajorAxis_noncoloc,MajorAxis_Ref);
MinorAxis = vertcat(MinorAxis_coloc,MinorAxis_noncoloc,MinorAxis_Ref);
AspectRatio = vertcat(AspectRatio_coloc,AspectRatio_noncoloc,AspectRatio_Ref);
DistanceToBorder = vertcat(DistanceToBorder_coloc,DistanceToBorder_noncoloc,DistanceToBorder_Ref);
ClusterID = vertcat(ColocClusterIds,NotColocClusterIds,ClusterID_Ref);
Area_Ref_2 = vertcat(Area_coloc_Dummy,Area_noncoloc_Dummy,Area_Ref);
Locs_Ref_2 = vertcat(Locs_coloc_Dummy,Locs_noncoloc_Dummy,Locs_Ref);

Table = [ClusterID Percentages Area Locs Perim Circ MajorAxis MinorAxis AspectRatio DistanceToBorder Area_Ref_2 Locs_Ref_2];

waitbar(4/4,wb,['Data pair: ',num2str(counter_waitbar(1)),'/',num2str(counter_waitbar(2)) ' - Done...']);
pause(0.5)
close(wb)
warning('on','all') % Turn the warnings back on

end