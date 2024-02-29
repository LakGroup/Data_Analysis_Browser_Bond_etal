% Clear the workspace.
clc;clear;close all;

% -------------------------------------------------------------------------
% Default values (can change if you want to).
nBins = 100; % The number of bins for your histogram.
Filter = [0 0.25 0.75 1]; % The filter for including data.
ColumnNames{1} = 'Coloc_Higher_Than_Background_(1=yes)'; % The name of the column that indicates whether or not the data is colocalized.
ColumnNames{2} = 'Distance to Nucleus (nm)'; % The name of the column that contains the distance to the nucleus.
Multiplier = [1 1]; % The multiplier for the nBins plots and Filter plots, respectively (1.96: 95% CI; 1: std).
newLegend = horzcat({''},{'LAMP1'},{''},{'LAMP1 & CD63'});
% ------------------------------------------------------------------------

% Default value for Filter.
if isempty(Filter)
    Filter = linspace(0,1,nBins+1);
end

% Select the data file to analyze.
[file,path] = uigetfile('*.xlsx','Please select the file in distances are saved','MultiSelect','on');

% Show an error message if cancel or escape was pressed.
if ~iscell(file) && sum(file) == 0
    error("You did not select a file for the analysis");
end

% Convert to a cell if a single file is selected.
if ~iscell(file)
    file = {file};
end

% Load the data.
for fileNumber = 1:numel(file)
    name = fullfile(path,file{fileNumber});
    data = readtable(name,'VariableNamingRule','preserve');
    FileNumbers = readtable(name,'Sheet','QuickMaths','VariableNamingRule','preserve');
    
    % Extract the columns containing the names we want to look at.
    VariableNames = data.Properties.VariableNames;
    VariablePositions = zeros(numel(ColumnNames),1);
    for i = 1:numel(ColumnNames)
        VariablePositions(i) = find(cell2mat(cellfun(@(x) strcmp(x,ColumnNames{i}),VariableNames,'UniformOutput',false)));
    end
    
    % Clear the workspace.
    clear VariableNames i
    
    % Find the indices of the different individual cells.
    Idx = find(isnan(table2array(data(:,VariablePositions(1)))));
    Idx = vertcat(Idx,size(data,1)+1);
    
    % Separate the data into individual cells.
    distance_file = cell(1,numel(Idx)-1);
    for i = 1:numel(Idx)-1
        distance_file{i} = table2array(data(Idx(i)+1:Idx(i+1)-1,VariablePositions));
        distance_file{i}(:,2) = distance_file{i}(:,2) ./ max(distance_file{i}(:,2)); % Normalize to the maximum distance for that cell
    end
    
    % Clear the workspace.
    clear data Idx VariablePositions
    
    % Extract the number of bioreplicates and how many for each type.
    BioReplicates = table2cell(FileNumbers(:,1));
    BR_pos = cellfun(@(x) strfind(x,'_BR')+3,BioReplicates,'UniformOutput',false);
    BR = cellfun(@(x,y) str2double(x(y)),BioReplicates,BR_pos);
    [~,BR_Idx] = unique(BR);
    BR_Idx = vertcat(BR_Idx,size(BR_pos,1)+1);
    BR_num = diff(BR_Idx);
    
    % Clear the workspace.
    clear FileNumbers BioReplicates BR_pos BR
    
    % Separate the data into clusters that were colocalized or not.
    NonColoc = cell(1,size(distance_file,2));
    Coloc = cell(1,size(distance_file,2));
    for i = 1:size(distance_file,2)
        NonColoc{i} = distance_file{i}(distance_file{i}(:,1)==0,2);
        Coloc{i} = distance_file{i}(distance_file{i}(:,1)==1,2);
    end
    
    % Clear the workspace.
    clear distance_file i
    
    % Divide the two groups per bioreplicate.
    NonColoc_BR = cell(1,size(BR_Idx,1)-1);
    Coloc_BR = cell(1,size(BR_Idx,1)-1);
    for i = 1:size(BR_Idx,1)-1
        NonColoc_BR_tmp = NonColoc(BR_Idx(i):BR_Idx(i+1)-1);
        NonColoc_BR{i} = vertcat(NonColoc_BR_tmp{:});
        Coloc_BR_tmp = Coloc(BR_Idx(i):BR_Idx(i+1)-1);
        Coloc_BR{i} = vertcat(Coloc_BR_tmp{:});
    end
    
    % Clear the workspace.
    clear BR_Idx NonColoc_BR_tmp Coloc_BR_tmp NonColoc Coloc i
    
    % Prepare for the plotting.
    nNonColoc_nBins = zeros(numel(BR_num),nBins);
    nColoc_nBins = zeros(numel(BR_num),nBins);
    nNonColoc_Filt = zeros(numel(BR_num),size(Filter,2)-1);
    nColoc_Filt = zeros(numel(BR_num),size(Filter,2)-1);
    for i = 1:numel(BR_num)
        nNonColoc_nBins(i,:) = histcounts(NonColoc_BR{i},nBins);
        nNonColoc_Filt(i,:) = histcounts(NonColoc_BR{i},Filter);
        nColoc_nBins(i,:) = histcounts(Coloc_BR{i},nBins);
        nColoc_Filt(i,:) = histcounts(Coloc_BR{i},Filter);
    end
    
    % Create the x axis values for each plot
    x_nBins = linspace(0,1,nBins+1);x_nBins = x_nBins(1:end-1) + diff(x_nBins);
    x_Filt = 1:size(Filter,2)-1;
    x_Filt_Name = cell(size(Filter,2)-1,1);
    for i = 1:size(Filter,2)-1
        x_Filt_Name{i} = [num2str(Filter(i)) ' - ' num2str(Filter(i+1))];
    end
    
    % Clear the workspace.
    clear NonColoc_BR Coloc_BR i
    
    % Normalize to the total of all distances (i.e., both Coloc and
    % NonColoc), and also normalize per group.
    nNonColoc_nBins_group = cumsum(nNonColoc_nBins./sum(nNonColoc_nBins,2),2);
    nNonColoc_nBins_total = cumsum(nNonColoc_nBins./sum([nNonColoc_nBins nColoc_nBins],2),2);
    nNonColoc_Filt_group = nNonColoc_Filt./sum(nNonColoc_Filt,2);
    nNonColoc_Filt_total = nNonColoc_Filt./sum([nNonColoc_Filt nColoc_Filt],2);
    nColoc_nBins_group = cumsum(nColoc_nBins./sum(nColoc_nBins,2),2);
    nColoc_nBins_total = cumsum(nColoc_nBins./sum([nNonColoc_nBins nColoc_nBins],2),2);
    nColoc_Filt_group = nColoc_Filt./sum(nColoc_Filt,2);
    nColoc_Filt_total = nColoc_Filt./sum([nNonColoc_Filt nColoc_Filt],2);
    
    % Normalize per Filter type
    nNonColoc_Filt_byType = nNonColoc_Filt./(nNonColoc_Filt+nColoc_Filt);
    nColoc_Filt_byType = nColoc_Filt./(nNonColoc_Filt+nColoc_Filt);
    
    % Prepare the plots
    [mean_nNonColoc_nBins_group,~,std_up_nNonColoc_nBins_group,std_lo_nNonColoc_nBins_group] = meanstd(nNonColoc_nBins_group,Multiplier(1));
    [mean_nNonColoc_nBins_total,~,std_up_nNonColoc_nBins_total,std_lo_nNonColoc_nBins_total] = meanstd(nNonColoc_nBins_total,Multiplier(1));
    [mean_nNonColoc_Filt_group,std_nNonColoc_Filt_group] = meanstd(nNonColoc_Filt_group,Multiplier(2));
    [mean_nNonColoc_Filt_total,std_nNonColoc_Filt_total] = meanstd(nNonColoc_Filt_total,Multiplier(2));
    [mean_nNonColoc_Filt_byType,std_nNonColoc_Filt_byType] = meanstd(nNonColoc_Filt_byType,Multiplier(2));
    [mean_nColoc_nBins_group,~,std_up_nColoc_nBins_group,std_lo_nColoc_nBins_group] = meanstd(nColoc_nBins_group,Multiplier(1));
    [mean_nColoc_nBins_total,~,std_up_nColoc_nBins_total,std_lo_nColoc_nBins_total] = meanstd(nColoc_nBins_total,Multiplier(1));
    [mean_nColoc_Filt_group,std_nColoc_Filt_group] = meanstd(nColoc_Filt_group,Multiplier(2));
    [mean_nColoc_Filt_total,std_nColoc_Filt_total] = meanstd(nColoc_Filt_total,Multiplier(2));
    [mean_nColoc_Filt_byType,std_nColoc_Filt_byType] = meanstd(nColoc_Filt_byType,Multiplier(2));
    
    % Prepare the title, depending on the number of bioreplicates
    title_br = '(';
    for i = 1:numel(BR_num)
        title_br = [title_br 'BR' num2str(i) ': ' num2str(BR_num(i)) ' cells; '];
    end
    title_br = [title_br(1:end-2) ')'];
    
    % Clear the workspace.
    clear BR_num
    
    % Make the plot of the CDFs.
    figure('Units','Normalized','OuterPosition',[0 0 1 1]);
    set(gcf,'color','white','InvertHardCopy','off');
    
%     subplot(1,2,1);
    patch([x_nBins fliplr(x_nBins)], [std_lo_nNonColoc_nBins_group fliplr(std_up_nNonColoc_nBins_group)], [0 0 1], 'FaceAlpha',0.4, 'EdgeColor','none');
    hold on;
    plot(x_nBins,mean_nNonColoc_nBins_group,'b','LineWidth',2)
    patch([x_nBins fliplr(x_nBins)], [std_lo_nColoc_nBins_group fliplr(std_up_nColoc_nBins_group)], [1 0 0], 'FaceAlpha',0.4, 'EdgeColor','none');
    plot(x_nBins,mean_nColoc_nBins_group,'r','LineWidth',2);
    set(gca,'LineWidth',2,'FontSize',36,'FontWeight','bold');
    xlabel('Normalized distance to the nucleus','FontSize',36,'FontWeight','bold');
    ylabel('Cumulative Density Function','FontSize',36,'FontWeight','bold');
%     title(['Normalized by type ' title_br],'FontSize',12,'FontWeight','bold');
    legend(newLegend,'Location','southeast','AutoUpdate','off','FontSize',24,'FontWeight','bold');
    legend boxoff 
    axis square;
    axis([0 1 min([std_lo_nNonColoc_nBins_group std_lo_nColoc_nBins_group 0]) max([std_up_nNonColoc_nBins_group std_up_nColoc_nBins_group 1])])
    
%     subplot(1,2,2);
%     patch([x_nBins fliplr(x_nBins)], [std_lo_nNonColoc_nBins_total fliplr(std_up_nNonColoc_nBins_total)], [0 0 1], 'FaceAlpha',0.4, 'EdgeColor','none');
%     hold on;
%     plot(x_nBins,mean_nNonColoc_nBins_total,'b','LineWidth',2)
%     patch([x_nBins fliplr(x_nBins)], [std_lo_nColoc_nBins_total fliplr(std_up_nColoc_nBins_total)], [1 0 0], 'FaceAlpha',0.4, 'EdgeColor','none');
%     plot(x_nBins,mean_nColoc_nBins_total,'r','LineWidth',2);
%     set(gca,'LineWidth',2,'FontSize',12,'FontWeight','bold');
%     xlabel('Normalized distance to the nucleus','FontSize',12,'FontWeight','bold');
%     ylabel('CDF','FontSize',12,'FontWeight','bold');
%     title(['Normalized to the total ' title_br],'FontSize',12,'FontWeight','bold');
%     legend(newLegend,'Location','best','AutoUpdate','off');
%     legend boxoff 
%     axis square;
%     axis([0 1 min([std_lo_nNonColoc_nBins_total std_lo_nColoc_nBins_total 0]) max([std_up_nNonColoc_nBins_total std_up_nColoc_nBins_total 1])])
    print([name(1:end-5) '_CDFPlots.png'],'-dpng','-r300');
%     
%     % Make the plot of the different zones.
%     figure('Units','Normalized','OuterPosition',[0 0 1 1]);
%     set(gcf,'color','white','InvertHardCopy','off');
%     
%     subplot(1,2,1);
%     hold on;
%     bar(x_Filt-0.4/2,mean_nNonColoc_Filt_group,0.39,'FaceColor',[0 0 1]);
%     bar(x_Filt+0.4/2,mean_nColoc_Filt_group,0.39,'FaceColor',[1 0 0]);
%     errorbar(x_Filt-0.4/2,mean_nNonColoc_Filt_group,std_nNonColoc_Filt_group,'Color','k','LineStyle','none','LineWidth',3)
%     errorbar(x_Filt+0.4/2,mean_nColoc_Filt_group,std_nColoc_Filt_group,'Color','k','LineStyle','none','LineWidth',3)
%     for i = 1:numel(x_Filt)
%         x1 = linspace(x_Filt(i)-0.4,x_Filt(i),numel(x_Filt)+2);
%         x2 = linspace(x_Filt(i),x_Filt(i)+0.4,numel(x_Filt)+2);
%         plot(x1(2:end-1),nNonColoc_Filt_group(:,i),'sk','MarkerSize',10,'MarkerFaceColor',[0 0 0])
%         plot(x2(2:end-1),nColoc_Filt_group(:,i),'sk','MarkerSize',10,'MarkerFaceColor',[0 0 0])
%     end
%     set(gca,'LineWidth',2,'FontSize',12,'FontWeight','bold');
%     xticks(x_Filt);xticklabels(x_Filt_Name);
%     xlabel('Fraction of normalized distance to the nucleus','FontSize',12,'FontWeight','bold');
%     ylabel('Probability','FontSize',12,'FontWeight','bold');
%     title(['Normalized by type ' title_br],'FontSize',12,'FontWeight','bold');
%     legend(newLegend,'Location','best','AutoUpdate','off');
%     legend boxoff 
%     axis square;
%     axis([x_Filt(1)-0.6 x_Filt(end)+0.6 min([mean_nNonColoc_Filt_group-std_nNonColoc_Filt_group mean_nColoc_Filt_group-std_nColoc_Filt_group 0]) max([mean_nNonColoc_Filt_group+std_nNonColoc_Filt_group mean_nColoc_Filt_group+std_nColoc_Filt_group 1])])
%     
%     subplot(1,2,2);
%     hold on;
%     bar(x_Filt-0.4/2,mean_nNonColoc_Filt_total,0.39,'FaceColor',[0 0 1]);
%     bar(x_Filt+0.4/2,mean_nColoc_Filt_total,0.39,'FaceColor',[1 0 0]);
%     errorbar(x_Filt-0.4/2,mean_nNonColoc_Filt_total,std_nNonColoc_Filt_total,'Color','k','LineStyle','none','LineWidth',3)
%     errorbar(x_Filt+0.4/2,mean_nColoc_Filt_total,std_nColoc_Filt_total,'Color','k','LineStyle','none','LineWidth',3)
%     for i = 1:numel(x_Filt)
%         x1 = linspace(x_Filt(i)-0.4,x_Filt(i),numel(x_Filt)+2);
%         x2 = linspace(x_Filt(i),x_Filt(i)+0.4,numel(x_Filt)+2);
%         plot(x1(2:end-1),nNonColoc_Filt_total(:,i),'sk','MarkerSize',10,'MarkerFaceColor',[0 0 0])
%         plot(x2(2:end-1),nColoc_Filt_total(:,i),'sk','MarkerSize',10,'MarkerFaceColor',[0 0 0])
%     end
%     set(gca,'LineWidth',2,'FontSize',12,'FontWeight','bold');
%     xticks(x_Filt);xticklabels(x_Filt_Name);
%     xlabel('Fraction of normalized distance to the nucleus','FontSize',12,'FontWeight','bold');
%     ylabel('Probability','FontSize',12,'FontWeight','bold');
%     title(['Normalized to the total ' title_br],'FontSize',12,'FontWeight','bold');
%     legend(newLegend,'Location','best','AutoUpdate','off');
%     legend boxoff 
%     axis square;
%     axis([x_Filt(1)-0.6 x_Filt(end)+0.6 min([mean_nNonColoc_Filt_total-std_nNonColoc_Filt_total mean_nColoc_Filt_total-std_nColoc_Filt_total 0]) max([mean_nNonColoc_Filt_total+std_nNonColoc_Filt_total mean_nColoc_Filt_total+std_nColoc_Filt_total 1])])
%     print([name(1:end-5) '_PDFPlots.png'],'-dpng','-r300');
%     
%     % Make the plot of the different zones normalized by zone.
%     figure('Units','Normalized','OuterPosition',[0.25 0.25 0.7 0.7]);
%     set(gcf,'color','white','InvertHardCopy','off');
%     
%     hold on;
%     bar(x_Filt-0.4/2,mean_nNonColoc_Filt_byType,0.39,'FaceColor',[0 0 1]);
%     bar(x_Filt+0.4/2,mean_nColoc_Filt_byType,0.39,'FaceColor',[1 0 0]);
%     errorbar(x_Filt-0.4/2,mean_nNonColoc_Filt_byType,std_nNonColoc_Filt_byType,'Color','k','LineStyle','none','LineWidth',3)
%     errorbar(x_Filt+0.4/2,mean_nColoc_Filt_byType,std_nColoc_Filt_byType,'Color','k','LineStyle','none','LineWidth',3)
%     for i = 1:numel(x_Filt)
%         x1 = linspace(x_Filt(i)-0.4,x_Filt(i),numel(x_Filt)+2);
%         x2 = linspace(x_Filt(i),x_Filt(i)+0.4,numel(x_Filt)+2);
%         plot(x1(2:end-1),nNonColoc_Filt_byType(:,i),'sk','MarkerSize',10,'MarkerFaceColor',[0 0 0])
%         plot(x2(2:end-1),nColoc_Filt_byType(:,i),'sk','MarkerSize',10,'MarkerFaceColor',[0 0 0])
%     end
%     set(gca,'LineWidth',2,'FontSize',12,'FontWeight','bold');
%     xticks(x_Filt);xticklabels(x_Filt_Name);
%     xlabel('Fraction of normalized distance to the nucleus','FontSize',12,'FontWeight','bold');
%     ylabel('Probability','FontSize',12,'FontWeight','bold');
%     title('Normalized by region','FontSize',12,'FontWeight','bold');
%     legend(newLegend,'Location','best','AutoUpdate','off');
%     legend boxoff 
%     axis square;
%     axis([x_Filt(1)-0.6 x_Filt(end)+0.6 min([mean_nNonColoc_Filt_byType-std_nNonColoc_Filt_byType mean_nColoc_Filt_byType-std_nColoc_Filt_byType 0]) max([mean_nNonColoc_Filt_byType+std_nNonColoc_Filt_byType mean_nColoc_Filt_byType+std_nColoc_Filt_byType 1])])
%     print([name(1:end-5) '_Probability_By_TypePlot.png'],'-dpng','-r300');

    % Close all the plots
    close all
end