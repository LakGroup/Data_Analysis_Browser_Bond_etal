% Clear all the workspace and so on
% clc;clear;close all;

% -------------------------------------------------------------------------
% Default values (can change if you want to)
nBins = 100; % The number of bins for your histogram
normType = {'count','probability','cumcount','cdf'}; % Possibilities: 'count' | 'probability' | 'pdf' | 'cumcount' | 'cdf'
% Filter = [0 0.25 0.75 1]; % The filter for including data.
Filter = linspace(0,1,11); % For bins that are 10% wide
% ------------------------------------------------------------------------

% Default value for filter
if isempty(Filter)
    Filter = linspace(0,1,nBins+1);
end

% Load the data
[file,path] = uigetfile('*.xlsx','Please select the file in distances are saved'); % Extract the name of the file given.
name = fullfile(path,file); % Make it a full name to save it as later.
data = readtable(name);

% Separate the data into individual cells
Idx = find(isnan(table2array(data(:,6))));
Idx = vertcat(0,Idx,size(data,1));

distance_file = cell(1,numel(Idx)-1);
for i = 1:numel(Idx)-1
    distance_file{i} = table2array(data(Idx(i)+1:Idx(i+1)-1,[6 9]));
    distance_file{i}(:,2) = distance_file{i}(:,2) ./ max(distance_file{i}(:,2)); % Normalize to the maximum distance for that cell
end

% Separate the data into points that were colocalized or not
NonColoc  = cell(1,size(distance_file,2));
Coloc  = cell(1,size(distance_file,2));
for i = 1:size(distance_file,2)
    NonColoc{i} = distance_file{i}(distance_file{i}(:,1)==0,2);
    Coloc{i} = distance_file{i}(distance_file{i}(:,1)==1,2);
end
NonColoc = vertcat(NonColoc{:});
Coloc = vertcat(Coloc{:});

% % Filter if needed
% NonColoc = NonColoc(NonColoc>=Filter(1) & NonColoc<=Filter(2));
% Coloc = Coloc(Coloc>=Filter(1) & Coloc<=Filter(2));

% Do the actual plotting
[nColoc,~] = histcounts(Coloc,Filter);
[nNonColoc,Edges] = histcounts(NonColoc,Filter);

% Normalize to total
nTotal = numel([Coloc; NonColoc]);
nColoc = nColoc./nTotal;
nNonColoc = nNonColoc./nTotal;

% Make the figure(s)
figure;
for i = 1:numel(normType)
    if numel(normType) == 1
        subplot(1,2,i)
    elseif numel(normType) == 2
        subplot(1,3,i)
    elseif numel(normType) == 3
        subplot(2,2,i)
    elseif numel(normType) == 4 || numel(normType) == 5
        subplot(2,3,i)
    end
    histogram(Coloc,Edges,'Normalization',normType{i});hold on;histogram(NonColoc,Edges,'Normalization',normType{i});
    legend({'Colocalized','Not colocalized'},'Location','best');
    xlabel('Normalized distance to the nucleus','FontSize',12,'FontWeight','bold')
    ylabel(normType{i},'FontSize',12,'FontWeight','bold')
    set(gca,'FontSize',12,'FontWeight','bold')
end
if numel(normType) == 1
    subplot(1,2,1);xLim = xlim;
    subplot(1,2,i+1)
elseif numel(normType) == 2
    subplot(1,3,1);xLim = xlim;
    subplot(1,3,i+1)
elseif numel(normType) == 3
    subplot(2,2,1);xLim = xlim;
    subplot(2,2,i+1)
elseif numel(normType) == 4 || numel(normType) == 5
    subplot(2,3,1);xLim = xlim;
    subplot(2,3,i+1)
end
i = 1;
patch([Edges(i) Edges(i+1) Edges(i+1) Edges(i)],[0 0 nColoc(i) nColoc(i)],[0 0.4470 0.7410],'Facealpha',0.6);hold on;
patch([Edges(i) Edges(i+1) Edges(i+1) Edges(i)],[0 0 nNonColoc(i) nNonColoc(i)],[0.8500 0.3250 0.0980],'Facealpha',0.6);hold on
newLegend = horzcat({'Colocalized'},{'NonColocalized'});
legend(newLegend,'Location','best','AutoUpdate','off');
for i = 2:numel(nColoc)
    patch([Edges(i) Edges(i+1) Edges(i+1) Edges(i)],[0 0 nColoc(i) nColoc(i)],[0 0.4470 0.7410],'Facealpha',0.6);hold on;
end
for i = 2:numel(nNonColoc)
    patch([Edges(i) Edges(i+1) Edges(i+1) Edges(i)],[0 0 nNonColoc(i) nNonColoc(i)],[0.8500 0.3250 0.0980],'Facealpha',0.6);hold on
end
xlim(xLim)
xlabel('Normalized distance to the nucleus','FontSize',12,'FontWeight','bold')
ylabel('Probability w.r.t. total number of lysosomes','FontSize',12,'FontWeight','bold')
set(gca,'FontSize',12,'FontWeight','bold')