%% Data Construction
% Load the data
[file,path] = uigetfile('*.mat','Select the file you want to load'); % Open a dialog so you can specify which file you want to load
selectedfile = fullfile(path,file); % Create the name for the file to load
load(selectedfile); % Load the file
% Clear up the work space
clear file path

% Select the reference and the co-localization channels
List = cellfun(@(x) x.name,data,'UniformOutput',false);
RefIndex = [];
ColocIndex = [];
while isempty(RefIndex) || ~(numel(RefIndex) == numel(ColocIndex))
    % Reference channel selection
    [RefIndex,tf] = listdlg('Name','Select reference channel(s)','PromptString','Select the channel or channels that are refering to the reference data.','ListString',List,'ListSize',[500 300]);
    % Stop the loop if ESC/cancel/X is pressed
    if tf == 0
        break
    end
    
    % Reference channel selection
    [ColocIndex,tf] = listdlg('Name','Select co-localization channel(s)','PromptString',{'Select the channel or channels that are refering to the co-localization data.',['Please select ' num2str(numel(RefIndex)) ' values.']},'ListString',List,'ListSize',[500 300]);
    % Stop the loop if ESC/cancel/X is pressed
    if tf == 0
        break
    end
    
    % Check if the amount of reference and co-localization channels
    % selected is the same
    if ~(numel(RefIndex) == numel(ColocIndex))
        uiwait(msgbox({'The number of reference channels selected is not equal to the number of co-localization channels selected. Please redo the selection.','','Press OK to continue.'}, 'Error','error'));
    end
end
% Stop the program if ESC/cancel/X was pressed
if tf == 0
    clear;clc
    error('The program was cancelled prematurely.')
end

% Clear up the work space
clear List tf

% Show an input dialog for the parameters that can change
input_values = inputdlg('Overlap Percentage Threshold:','',1,{'75'}); % Show up an input dialog
% Extract the input values from the dialog window
ThresholdOverlap = str2double(input_values{1})/100; % The minimum overlap (in %) for it to be co-localized
% Clear up the work space
clear input_values

tic
% Show a wait bar, we start filtering/selection/calculations here
f = waitbar(0,'Step 1 of 3: Extracting reference & co-localization clusters...','Name','Progress of the co-localization process');
set(findall(f),'Units','normalized');
set(f,'Position',[0.3 0.45 0.35 0.075])
pause(0.1)

% Extract the data for the reference channel and co-localziation channel
% Pre-allocate for speed reasons
ClustersRef = cell(numel(RefIndex),1);
% Reference data
for i = 1:numel(RefIndex)
    % Update the wait bar
    waitbar(i/(numel(RefIndex)*2),f, 'Step 1 of 3: Extracting reference & co-localization clusters...');
    
    DataRef = horzcat(data{1,RefIndex(i)}.x_data,data{1,RefIndex(i)}.y_data, data{1,RefIndex(i)}.area); % Set up the reference data
    Groups = findgroups(DataRef(:,3)); % Find unique groups and their number
    ClustersRef{i,:} = splitapply(@(x){(x)},DataRef(:,1:3),Groups);
end
ClustersRefComplete = ClustersRef;
% Clear up the work space
clear i DataRef Groups Ref

% Pre-allocate for speed reasons
ClustersColoc = cell(numel(ColocIndex),1);
% Co-localization data
for i = 1:numel(ColocIndex)
    % Update the wait bar
    waitbar(0.5+i/(numel(ColocIndex)*2),f, 'Step 1 of 3: Extracting reference & co-localization clusters...');
    
    DataColoc = horzcat(data{1,ColocIndex(i)}.x_data,data{1,ColocIndex(i)}.y_data, data{1,ColocIndex(i)}.area); % Extract the data
    Groups = findgroups(DataColoc(:,3)); % Find unique groups and their number
    ClustersColoc{i,:} = splitapply(@(x){(x)},DataColoc(:,1:3),Groups); % Split the clusters into the corresponding groups
end
% Clear up the work space
clear i DataColoc Groups

% Update the wait bar
waitbar(1,f, 'Step 1 of 3: Extracting reference & co-localization clusters... Complete');

%% Filtering step (remove all clusters outside the reference cluster boundaries)
% Update the wait bar
pause(0.2)
waitbar(0,f,'Step 2 of 3: Filtering co-localization clusters...');

% Pre-allocate for speed reasons
PolyLowResRefExpanded = cell(numel(RefIndex),1);
FilteredColoc = cell(numel(RefIndex),1);
SelectedColoc = cell(numel(RefIndex),1);
% Loop over all the reference/co-localization pairs and filter the
% co-localization clusters
for i = 1:numel(RefIndex)
    % Extract the colocalization channel cluster centers
    ColocCenter = cell2mat(cellfun(@(x) mean(x(:,1:2)), ClustersColoc{i},'UniformOutput',false));
    
    % Pre-allocate and initialize for speed and convenience reasons
    PolyLowResRefExpanded{i} = cell(size(ClustersRef{i},1),1);
    PolygonRef = polyshape();
    % Create a set of low-resolution coordinates of all the reference cluster
    % coordinates
    warning('off','all') % Turn off warnings for the creation of the polygons
    for j = 1:size(ClustersRef{i},1)
        % Update the wait bar
        waitbar((i-1)/numel(RefIndex)+(j/size(ClustersRef{i},1))/numel(RefIndex),f,'Step 2 of 3: Filtering co-localization clusters...');
        
        LowResCoords = unique(round(ClustersRef{i}{j}(:,1:2)),'rows'); % Create a low-res version of the reference coordinates
        LowResBoundary = boundary(LowResCoords,1); % Calculate the boundary
        LowResBoundaryCoords = LowResCoords(LowResBoundary,:); % Extract the coordinates from the boundary
        PolyLowResRef = polyshape(LowResBoundaryCoords); % Create a polygon from these coordinates
        PolyLowResRefExpanded{i}{j} = polybuffer(PolyLowResRef,5); % Expand the polygon with 5 pixels
        PolygonRef = union(PolygonRef,PolyLowResRefExpanded{i}{j}); % Create one polygon only
    end
    warning('on','all') % Turn the warnings back on
    % Clear up the work space
    clear j LowResCoords LowResBoundary LowResBoundaryCoords PolyLowResRef
    
    % Update the wait bar
    waitbar(i/numel(RefIndex),f,'Step 2 of 3: Filtering co-localization clusters... This might take a minute...');
    
    % Check if the coordinates of the colocalization channel are inside this
    % polygon
    IsInside = inpolygon(ColocCenter(:,1),ColocCenter(:,2),PolygonRef.Vertices(:,1),PolygonRef.Vertices(:,2));
    FilteredColoc{i} = {ClustersColoc{i}{~IsInside}}';
    SelectedColoc{i} = {ClustersColoc{i}{IsInside}}';
    % Clear up the work space
    clear IsInside PolygonRef ColocCenter
end
% Clear up the work space
clear i ClustersColoc

% Update the wait bar
waitbar(1,f,'Step 2 of 3: Filtering co-localization clusters... Complete');

%% Calculate the overlap between the reference clusters and the co-localization clusters
% Update the wait bar
pause(0.2)
waitbar(0,f,'Step 3 of 3: Calculating overlap...');

% Pre-allocate for speed reasons
PercentageInside = cell(numel(RefIndex),1);
ColocalizedClusters = cell(numel(RefIndex),1);
NotColocalizedClusters = cell(numel(RefIndex),1);
IdxClusters = cell(numel(RefIndex),1);
% Loop over all the reference/co-localization pairs to find all the
% co-localization clusters that potentially overlap with the reference
% clusters and calculate the actual overlap percentage
for i = 1:numel(RefIndex)
    % Determine the possible reference clusters related to the co-localization
    % clusters
    ColocCenter = cell2mat(cellfun(@(x) mean(x(:,1:2)),SelectedColoc{i},'UniformOutput',false));
    IsInside = cellfun(@(x) inpolygon(ColocCenter(:,1),ColocCenter(:,2),x.Vertices(:,1),x.Vertices(:,2)),PolyLowResRefExpanded{i},'UniformOutput',false);
    Idx = cellfun(@(x) find(x), IsInside,'UniformOutput',false);
    % Clear up the work space
    clear ColocCenter IsInside
    
    % Clean up the reference clusters that do not have any potential
    % co-localization clusters associated to them
    SelectRefClusters = cell2mat(cellfun(@(x) ~isempty(x),Idx,'UniformOutput',false));
    ClustersRef{i} = {ClustersRef{i}{SelectRefClusters}}';
    IdxClusters{i} = {Idx{SelectRefClusters}}';
    % Clear up the work space
    clear SelectRefClusters Idx
    
    % Pre-allocate for speed reasons
    PercentageInside{i} = cell(size(ClustersRef{i},1),1);
    % Create alpha shapes of the reference clusters and then check if the
    % coordinates of the selected clusters are inside these.
    for j = 1:size(ClustersRef{i},1)
        % Extract the coordinates of the reference cluster and make an
        % 'alphashape' of it. This alphashape will keep into account the
        % holes inside the reference clusters.
        alpha = 0.8; % This was set with Qing that looked good for her tubulins data
        xRef = ClustersRef{i}{j}(:,1);
        yRef = ClustersRef{i}{j}(:,2);
        shp = alphaShape(xRef,yRef,alpha);
        % Clear up the work space
        clear alpha xRef yRef
        
        % Pre-allocate for speed reasons
        PercentageInside{i}{j} = zeros(size(IdxClusters{i}{j},1),1);
        % Loop over the different potential overlapping clusters and
        % calculate their overlap with the reference cluster
        for k = 1:size(IdxClusters{i}{j},1)
            % Update the wait bar
            waitbar((i-1)/numel(RefIndex)+(j/size(ClustersRef{i},1))/numel(RefIndex),f,['Step 3 of 3: Calculating overlap... - Data set ' num2str(i) ' of ' num2str(numel(RefIndex)) ', Reference cluster ' num2str(j) ' of ' num2str(size(ClustersRef{i},1))]);
            
            % Calculate the actual overlap
            ColocCoords = SelectedColoc{i}{IdxClusters{i}{j}(k)}(:,1:2); % Extract the coordinates for the potentially interesting cluster
            tf = inShape(shp,ColocCoords(:,1),ColocCoords(:,2)); % Calculate the overlap between reference cluster and co-localization channel cluster
            total = numel(tf); % Determine the total number of coordinates
            PercentageInside{i}{j}(k) = sum(tf) / total; % The percentage of overlap is calculated as the number of coordinate pairs that overlap with the reference cluster divided by the total number of coordinate pairs
            % Clear up the work space
            clear ColocCoords tf total
        end
        % Clear up the work space
        clear k shp
    end
    % Clear up the work space
    clear j
    
    % Check if any co-localization cluster got assigned to multiple
    % reference clusters. This is possible due to the expanded boundary
    % region of the reference clusters
    [C,~,IC] = unique(vertcat(IdxClusters{i}{:})); % Find the unique values
    IC = accumarray(IC,1); % Count how many times each unique value occurs
    C(IC==1,:) = []; % Remove the cluster Ids that only occur once
    % Clear up the work space
    clear IC
    % Only do this if there are duplicate assignments
    if ~isempty(C)
        % Find out where the duplicates are, to what reference cluster they
        % are associated and then remove the unimportant contributions
        for j = 1:numel(C)
            % For each duplicate assignment, find out to which reference
            % cluster is was associated
            ClustersWithDuplicates = cellfun(@(x) find(x==C(j)),IdxClusters{i},'UniformOutput',false);
            DuplicateIdx = find(~cellfun(@(x) isempty(x), ClustersWithDuplicates));
            % Pre-allocate for speed reasons
            Percentages = zeros(numel(DuplicateIdx),1);
            % Extract the percentages of overlap so that only the maximum
            % one can be kept
            for k = 1:numel(DuplicateIdx)
                Percentages(k,:) = PercentageInside{i}{DuplicateIdx(k)}(IdxClusters{i}{DuplicateIdx(k)}==C(j));
            end
            [~,Idx] = max(Percentages);
            DuplicateIdx(Idx) = [];
            % Remove the co-localization cluster id from the calculations.
            % Only 1 assignment per co-localization cluster
            for k = 1:numel(DuplicateIdx)
                PercentageInside{i}{DuplicateIdx(k)}(IdxClusters{i}{DuplicateIdx(k)}==C(j)) = [];
                IdxClusters{i}{DuplicateIdx(k)}(IdxClusters{i}{DuplicateIdx(k)}==C(j)) = [];
            end
            % Clear up the work space
            clear k ClustersWithDuplicates DuplicateIdx Idx Percentages
        end
        % Clear up the work space
        clear j C
        % Clean up the reference clusters that do not have any 
        % co-localization clusters associated to them anymore
        SelectRefClusters = cell2mat(cellfun(@(x) ~isempty(x),IdxClusters{i},'UniformOutput',false));
        ClustersRef{i} = {ClustersRef{i}{SelectRefClusters}}';
        PercentageInside{i} = {PercentageInside{i}{SelectRefClusters}}';
        IdxClusters{i} = {IdxClusters{i}{SelectRefClusters}}';
        % Clear up the work space
        clear SelectRefClusters
    end
    
    % Determine whether or not the co-localization clusters pass the
    % threshold to be considered co-localized and then filter the ones that
    % were from the ones that were not.
    ColocalizedOrNot = cellfun(@(x) x>=ThresholdOverlap, PercentageInside{i}, 'UniformOutput',false); % Perform the thresholding to select the ones that were.
    
    % Pre-allocate for speed reasons
    ColocClusterIds = cell(size(IdxClusters{i},1),1);
    % Loop over the different reference clusters to extract the ones that
    % contain co-localized clusters
    for j = 1:size(IdxClusters{i},1)
        ColocClusterIds{j} = IdxClusters{i}{j}(ColocalizedOrNot{j});
    end
    ColocClusterIds = vertcat(ColocClusterIds{:});
    ColocalizedClusters{i} = {SelectedColoc{i}{ColocClusterIds}}';
    NotColocClusterIds = setdiff(1:size(SelectedColoc{i},1),ColocClusterIds)';
    NotColocalizedClusters{i} = vertcat(FilteredColoc{i},{SelectedColoc{i}{NotColocClusterIds}}');
    % Clear up the work space
    clear ColocalizedOrNot ColocClusterIds j NotColocClusterIds
end
% Update the wait bar and then delete it
waitbar(1,f,'Step 3 of 3: Calculating overlap... Complete');
pause(1)
delete(f)
% Clear up the work space
clear i PolyLowResRefExpanded f

%% Plot some figures
% Loop until the user is happy with the threshold
Continue = 1;
while Continue
    % Show a histogram of the co-localization percentages with the current
    % threshold indicated and a scatterplot of the reference data with the
    % co-localized and isolated clusters indicated
    for i = 1:numel(RefIndex)
        % Extract the individual percentages for each data set
        UnfoldedPercentages = cell2mat(PercentageInside{i});
        % Do the actual plotting
        Fig = figure(i);
        set(Fig,'Name',data{1,ColocIndex(i)}.name);
        subplot(1,2,1);
        histogram(UnfoldedPercentages*100,100,'BinLimits',[0 100],'Normalization','cdf');
        axis([0 100 0 1]);axis square;
        xlabel('co-localization overlap [%]','FontWeight','bold');
        ylabel('Cumulative distribution function [-]','FontWeight','bold');
        line([ThresholdOverlap*100 ThresholdOverlap*100],[0 1],'Color','r','LineWidth',2);
        text(ThresholdOverlap*100+0.5,0.975,['Threshold: ' num2str(ThresholdOverlap*100)],'Color','r');
        set(gca,'FontWeight','bold');
        % Clean up the workspace
        clear UnfoldedPercentages
        
        % Unfold all cluster coordinates for plotting
        ReferenceCoordinates = cell2mat(ClustersRefComplete{i});
        ColocalizedCoordinates = cell2mat(ColocalizedClusters{i});
        NotColocalizedCoordinates = cell2mat(NotColocalizedClusters{i});
        % Do the actual plotting
        figure(i);
        subplot(1,2,2);
        plot(ReferenceCoordinates(:,1),ReferenceCoordinates(:,2),'.','MarkerSize',2);
        hold on;
        if ~isempty(ColocalizedCoordinates)
            plot(ColocalizedCoordinates(:,1),ColocalizedCoordinates(:,2),'.g');
        end
        if ~isempty(NotColocalizedCoordinates)
            plot(NotColocalizedCoordinates(:,1),NotColocalizedCoordinates(:,2),'.r');
        end
        xlabel('Pixels in x [-]','FontWeight','bold');
        ylabel('Pixels in y [-]','FontWeight','bold');
        set(gca,'FontWeight','bold');
        title('Blue: Reference data; Green: co-localized clusters; Red: non co-localized clusters','FontWeight','bold');
        axis square;
        hold off;
        % Clean up the workspace
        clear ReferenceCoordinates ColocalizedCoordinates NotColocalizedCoordinates
    end
    
    if numel(RefIndex) ~= 1
        % Unfold all overlaps into a single data set
        UnfoldedPercentages = cell2mat(vertcat(PercentageInside{:}));
        % Plot a global histogram for completeness
        Fig = figure(i+1);
        set(Fig,'Name','Histogram for all opened data sets together');
        histogram(UnfoldedPercentages*100,100,'Normalization','cdf');
        axis([0 100 0 1]);axis square;
        xlabel('co-localization overlap [%]','FontWeight','bold')
        ylabel('Cumulative distribution function [-]','FontWeight','bold')
        line([ThresholdOverlap*100 ThresholdOverlap*100],[0 1],'Color','r','LineWidth',2)
        text(ThresholdOverlap*100+0.5,0.975,['Threshold: ' num2str(ThresholdOverlap*100)],'Color','r')
        set(gca,'FontWeight','bold')
        % Clean up the workspace
        clear UnfoldedPercentages
    end
    
    uiwait(msgbox({'Press OK after inspecting the plots to continue.'}, 'Press OK to continue','help'));
    
    % Ask to keep or change the overlap threshold percentage
    input_values = inputdlg('Overlap Percentage Threshold (cancel to keep current one):','',1,{num2str(ThresholdOverlap*100)}); % Show up an input dialog
    
    % If the current one is kept (i.e., cancel is pressed), then break out
    % of the loop
    if isempty(input_values)
        break
    end
    % If a value ie selected, extract the input values from the dialog 
    % window
    ThresholdOverlap = str2double(input_values{1})/100;
    
    % Redo the co-localization selection
    for i = 1:numel(RefIndex)
        ColocalizedOrNot = cellfun(@(x) x>=ThresholdOverlap, PercentageInside{i}, 'UniformOutput',false); % Perform the thresholding to select the ones that were.
        
        ColocClusterIds = cell(size(IdxClusters{i},1),1);
        for j = 1:size(IdxClusters{i},1)
            ColocClusterIds{j} = IdxClusters{i}{j}(ColocalizedOrNot{j});
        end
        ColocClusterIds = vertcat(ColocClusterIds{:});
        ColocalizedClusters{i} = {SelectedColoc{i}{ColocClusterIds}}';
        NotColocClusterIds = setdiff(1:size(SelectedColoc{i},1),ColocClusterIds)';
        NotColocalizedClusters{i} = vertcat(FilteredColoc{i},{SelectedColoc{i}{NotColocClusterIds}}');
        clear ColocalizedOrNot ColocClusterIds j NotColocClusterIds
    end
    clear i
end
% Clear up the work space
clear i input_values Continue FilteredColoc IdxClusters SelectedColoc ClustersRef

% Store the co-localized and isolated clusters for each data set in the
% session that was loaded before
for i = 1:numel(ColocIndex)
    % Unfold the co-localized and isolated clusters to matrices
    Colocalized = cell2mat(ColocalizedClusters{i});
    NonColocalized = cell2mat(NotColocalizedClusters{i});
    % Append the co-localized clusters to the current data set
    data{1,end+1} = data{1,ColocIndex(i)};
    if ~isempty(Colocalized)
        data{1,end}.x_data = Colocalized(:,1);
        data{1,end}.y_data = Colocalized(:,2);
        data{1,end}.area = Colocalized(:,3);
    else
        data{1,end}.x_data = [];
        data{1,end}.y_data = [];
        data{1,end}.area = [];
    end
    data{1,end}.name = strcat(data{1,end}.name,'_ColocalizedClusters_',num2str(ThresholdOverlap*100),'prOverlap');
    % Append the isolated clusters to the current data set
    data{1,end+1} = data{1,ColocIndex(i)};
    if ~isempty(NonColocalized)
        data{1,end}.x_data = NonColocalized(:,1);
        data{1,end}.y_data = NonColocalized(:,2);
        data{1,end}.area = NonColocalized(:,3);
    else
        data{1,end}.x_data = [];
        data{1,end}.y_data = [];
        data{1,end}.area = [];
    end
    data{1,end}.name = strcat(data{1,end}.name,'_NonColocalizedClusters_',num2str(ThresholdOverlap*100),'prOverlap');
    % Clear up the workspace
    clear Colocalized NonColocalized
end
clearvars -except data selectedfile

% Save the file with a new name
SaveFile = [extractBefore(selectedfile,'.mat') '_Colocalized.mat'];
save(SaveFile,'data');
% Clear up the workspace
clear selectedfile SaveFile