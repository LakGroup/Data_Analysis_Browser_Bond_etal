% Clean up the workspace.
clear;close all;clc

% -------------------------------------------------------------------------
% Declare the input variables.
StepSize = 500; % The stepsize for how frequently the efficiency has to be calculated.
randRef = 500; % Number of raw curves to be shown for the Ref data.
Groups = 10; % Number of groups in the Coloc data.
randColoc = 500; % Number of raw curves to be shown for the Coloc data.
ChannelNames = {'LAMP1','LAMP2'}; % set the channel names.
% -------------------------------------------------------------------------

% Colors
hex = ['#1f77b4';'#aec7e8';'#00ffff';'#ffbb78';'#2ca02c';'#98df8a';'#d62728';'#ff9896';'#9467bd';'#c5b0d5';'#ff7f0e';'#8c564b';'#c49c94';'#e377c2';'#f7b6d2';'#7f7f7f';'#c7c7c7';'#bcbd22';'#dbdb8d';'#17becf';'#9edae5'];
raw = sscanf(hex.','#%2x%2x%2x',[3,Inf]).';
num = size(raw,1);
Color2 = raw(1+mod(0:Groups-1,num),:) / 255;

% Load the data.
[file,path] = uigetfile({'*.mat'},'Select all the files for a single experiment.','MultiSelect','on'); % Select the files.

if isequal(file,0)
    error('You pressed cancel or did not select any file.'); % Throw an error if nothing was selected or cancel was pressed.
else

    % Make the file name a cell if it is not so the code does not block if
    % only 1 file is selected.
    if ~iscell(file)
        file = {file};
    end

    % Load all the data for each of the files belonging to the same
    % experiment.
    AllRefData = cell(numel(file),1);
    AllColocData = cell(numel(file),1);
    for i = 1:numel(file)

        % Make the full filename so it can be loaded easier.
        name = fullfile(path,file{i});

        % Load the data and extract the correct variables.
        data = load(name);
        AllRefData{i} = data.Ref;
        AllColocData{i} = data.Coloc{1};
    end
    AllRefData = vertcat(AllRefData{:});
    AllColocData = vertcat(AllColocData{:});
    AllColocData(AllColocData(:,50)==0,:) = [];

    % Sort the coloc data into different groups.
    [~,Idx] = sort(AllColocData(:,end),'ascend');
    AllColocData = AllColocData(Idx,:);
%     AllColocData = AllColocData ./ repmat(AllColocData(:,end),[1 size(AllColocData,2)]) * 100;

    Group_Coloc = cell(Groups,1);
    for i = 1:Groups
        Group_Coloc{i} = AllColocData(AllColocData(:,end)>(i-1)*(100/Groups)&AllColocData(:,end)<= i*(100/Groups),:);
    end

    % Calculate the x_axis
    x_axis = StepSize:StepSize:StepSize*size(AllRefData,2);
    shaded_x = [x_axis fliplr(x_axis)];

    % Plot the results
    inBetween = [mean(AllRefData) + std(AllRefData), fliplr(mean(AllRefData) - std(AllRefData))];
    figure('units','normalized','outerposition',[0 0 1 1]);
    set(gcf,'Color','White','InvertHardcopy', 'off');
    hold on;
    randSelected = randperm(size(AllRefData,1),randRef*4);
    NonValidIdx = any(AllRefData(randSelected,:)>100,2);
    randSelected(NonValidIdx) = [];
    randSelected = randSelected(1:randRef);
%     fill(shaded_x,inBetween,'g','facealpha',0.5,'edgecolor','none');
    plot(x_axis,AllRefData(randSelected,:)');xlabel('Frame','FontSize',56,'FontWeight','bold');ylabel('Area [%]','FontSize',56,'FontWeight','bold');set(gca,'FontSize',36,'FontWeight','bold');title(ChannelNames{1},'FontSize',64,'FontWeight','bold');axis([0 StepSize*size(AllRefData,2) 0 110])
    plot(x_axis,mean(AllRefData)','k','LineWidth',4);
    axis square
    print([path ChannelNames{1} '.png'],'-dpng','-r300')

    figure('units','normalized','outerposition',[0 0 1 1]);
    set(gcf,'Color','White','InvertHardcopy', 'off');
    hold on;
%     for i = 1:Groups
%         inBetween = [mean(Group_Coloc{i}) + std(Group_Coloc{i}), fliplr(mean(Group_Coloc{i}) - std(Group_Coloc{i}))];
%         randSelected = randi(size(Group_Coloc{i},1),[randColoc 1]);
%         plot(x_axis,Group_Coloc{i}(randSelected,:)','Color',Color2(i,:),'linewidth',1);xlabel('Frame [-]','FontSize',12,'FontWeight','bold');ylabel('Area [%]','FontSize',12,'FontWeight','bold');set(gca,'FontSize',12,'FontWeight','bold');title(ChannelNames{2},'FontSize',12,'FontWeight','bold');axis([0 StepSize*size(AllColocData,2) 0 105])
%         plot(x_axis,mean(Group_Coloc{i})','k','LineWidth',2);
%     end
    inBetween = [mean(Group_Coloc{i}) + std(Group_Coloc{i}), fliplr(mean(Group_Coloc{i}) - std(Group_Coloc{i}))];
    randSelected = randperm(size(AllColocData,1),randColoc*2);
    NonValidIdx = any(AllColocData(randSelected,:)>100,2);
    randSelected(NonValidIdx) = [];
    randSelected = randSelected(1:randColoc);
    plot(x_axis,AllColocData(randSelected,:)');xlabel('Frame','FontSize',56,'FontWeight','bold');ylabel('Area [%]','FontSize',56,'FontWeight','bold');set(gca,'FontSize',36,'FontWeight','bold');title(ChannelNames{2},'FontSize',64,'FontWeight','bold');axis([0 StepSize*size(AllColocData,2) 0 105])
    plot(x_axis,mean(AllColocData)','k','LineWidth',2);
    axis square
    print([path ChannelNames{2} '.png'],'-dpng','-r300')
end