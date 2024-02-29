function shape_classification_plot(data)
global minX maxX minY maxY AutoAxesVal AdrianaAxesVal SizeWindow

AutoAxesVal = 1;
AdrianaAxesVal = 0;
SizeWindow = 25;

fig = clf(figure());
set(gcf,'name','Shape Classification','NumberTitle','off','color','w','units','normalized','position',[0.3 0.2 0.4 0.6],'menubar','none','toolbar','none')
set(fig,'CloseRequestFcn', @closereq)

file_menu = uimenu('Text','File');
uimenu(file_menu,'Text','Send Data to Workspace','Callback',@send_data);
uimenu(file_menu,'Text','Save Data as bin','Callback',@save_bin_callback);
uimenu(file_menu,'Text','Save Data as jpg','Callback',@save_jpg_callback);
uimenu(file_menu,'Text','Save Data as jpg (random selection)','Callback',@save_jpg_selected_clusters_callback);

features_menu = uimenu('Text','Features');
uimenu(features_menu,'Text','Features Information','Callback',@features_info);
uimenu(features_menu,'Text','Box Plot','Callback',@features_box_plot);
uimenu(features_menu,'Text','PCA Analysis','Callback',@pca_analysis);
uimenu(features_menu,'Text','Class Coefficient of Variation','Callback',@coeff_of_variation);

classification_menu = uimenu('Text','Classification');
uimenu(classification_menu,'Text','Gravitational Clustering','Callback',@gravitational_clustering);
uimenu(classification_menu,'Text','Decision Boundary Plot','Callback',@decision_boundary_plot);
uimenu(classification_menu,'Text','Dendrogram Graph','Callback',@dendrogram);
uimenu(classification_menu,'Text','Network Graph','Callback',@network);
uimenu(classification_menu,'Text','Clustergram','Callback',@clustergram);
uimenu(classification_menu,'Text','K-means','Callback',@kmeans);
uimenu(classification_menu,'Text','Hierarchical','Callback',@hierarchical);
uimenu(classification_menu,'Text','Self Organizing Map','Callback',@som);
uimenu(classification_menu,'Text','Supervised Classification','Callback',@supervised);
uimenu(classification_menu,'Text','Iterative Classification (Based on Linkage)','Callback',@iterative_linkage);
uimenu(classification_menu,'Text','Iterative Classification (Based on Distance)','Callback',@iterative_distance);
uimenu(classification_menu,'Text','Iterative Classification (Based on Linkage) Coeff Variation','Callback',@iterative_linkage_coeff_var);
uimenu(classification_menu,'Text','Iterative Classification (Based on Distance) Coeff Variation','Callback',@iterative_distance_coeff_var);
%uimenu(classification_menu,'Text','Iterative Pairwise clustering','Callback',@iterative_pairwise_clustering);

filter_menu = uimenu('Text','Filter');
uimenu(filter_menu,'Text','Filter Mass','Callback',@filter_mass);
uimenu(filter_menu,'Text','Filter Area','Callback',@filter_area);
uimenu(filter_menu,'Text','Filter Aspect Ratio','Callback',@filter_aspect_ratio);

plot_menu = uimenu('Text','Plot');
uimenu(plot_menu,'Text','Ellipses Graph','Callback',@ellipses_plot);
uimenu(plot_menu,'Text','Axes limits','ForegroundColor','b','CallBack',@axes_limits);

extract_class = uimenu('Text','Exctract Classes');
uimenu(extract_class,'Text','Extract Classes','Callback',@extract_classes);
uimenu(extract_class,'Text','Class distribution','Callback',@class_distribution);

for i=1:size(data.classes,1)
    total_no_of_clusters(i) = length(data.classes{i,1});
end
no_of_classes = size(data.classes,1);

slider_one_value = 1;
slider_two_value = 1;
if  no_of_classes>1
    slider_one_step=[1/(no_of_classes-1),0.25];
else
    slider_one_step = [0 0];
end
if no_of_classes>1
    slider_one = uicontrol('style','slider','units','normalized','position',[0.01,0.1,0.04,0.8],'value',1,'min',1,'max',no_of_classes,'sliderstep',slider_one_step,'Callback',{@sld_one_callback});
end

if length(data.classes{slider_one_value,1})>1
    slider_two_step=[1/(length(data.classes{slider_one_value,1})-1),1/(length(data.classes{slider_one_value,1})-1)];
    slider_two = uicontrol('style','slider','units','normalized','position',[0.05,0.1,0.04,0.8],'value',1,'min',1,'max',length(data.classes{slider_one_value,1}),'sliderstep',slider_two_step,'Callback',{@sld_two_callback});
else
    slider_two_step=[0,0];
    slider_two = uicontrol('style','slider','units','normalized','position',[0.05,0.1,0.04,0.8],'value',1,'min',1,'max',1,'sliderstep',slider_two_step,'Callback',{@sld_two_callback});
end
AllCoords = data.classes{1};
minData = cellfun(@(x) min(x),AllCoords,'UniformOutput',false);
maxData = cellfun(@(x) max(x),AllCoords,'UniformOutput',false);
minData = floor(min(vertcat(minData{:})));
maxData = ceil(max(vertcat(maxData{:})));

shape_classification_plot_inside(data.classes,slider_one_value,slider_two_value,total_no_of_clusters,no_of_classes,data.name)

    function sld_one_callback(~,~,~)
        slider_one_value = round(slider_one.Value);
        slider_two_value= 1;
        if length(data.classes{slider_one_value,1})>1            
            slider_two_step=[1/(length(data.classes{slider_one_value,1})-1),1/(length(data.classes{slider_one_value,1})-1)];
            slider_two.Value = slider_two_value;
            slider_two.Min = 1;
            slider_two.Max = length(data.classes{slider_one_value,1});
            slider_two.SliderStep = slider_two_step;  
            slider_two.Position = [0.05,0.1,0.04,0.8];
        else
            slider_two.Position = [-0.2,0.1,0.04,0.8];
        end
        shape_classification_plot_inside(data.classes,slider_one_value,slider_two_value,total_no_of_clusters,no_of_classes,data.name)
    end

    function sld_two_callback(~,~,~)
        if length(data.classes{slider_one_value,1})>1
            slider_two_value = round(slider_two.Value);
            shape_classification_plot_inside(data.classes,slider_one_value,slider_two_value,total_no_of_clusters,no_of_classes,data.name)
        end
    end 
  
    function send_data(~,~,~)
        send_data_to_workspace(data)
    end

    function save_bin_callback(~,~,~)
        shape_classification_save_results_bin(data)
    end

    function save_jpg_callback(~,~,~)
        shape_classification_save_results_jpg(data)
    end

    function save_jpg_selected_clusters_callback(~,~,~)
        shape_classification_save_results_selected_clusters(data)
    end

    function features_info(~,~,~)
        shape_classification_features_info(data)
    end

    function features_box_plot(~,~,~)
        shape_classification_features_box_plot(data)
    end

    function pca_analysis(~,~,~)
        shape_classification_pca_analysis(data)
    end

    function coeff_of_variation(~,~,~)
        shape_classification_coeff_of_variation(data)
    end

    function gravitational_clustering(~,~,~)
        shape_classification_gravitational_clustering(data)
    end

    function decision_boundary_plot(~,~,~)
        shape_classification_decision_boundary_plot(data)
    end

    function dendrogram(~,~,~)
        shape_classification_dendrogram_graph(data)
    end

    function network(~,~,~)
        shape_classification_network_graph(data.classes)
    end

    function clustergram(~,~,~)
        shape_classification_clustergram(data.classes)
    end

    function kmeans(~,~,~)
        shape_classification_kmeans(data)
    end

    function hierarchical(~,~,~)
        shape_classification_hierarchical(data)
    end

    function som(~,~,~)
        shape_classification_som(data)
    end

    function supervised(~,~,~)
        shape_classification_supervised_clustering(data)
    end

    function iterative_linkage(~,~,~)
        shape_classification_iterative_linkage_clustering(data)
    end 

    function iterative_distance(~,~,~)
        shape_classification_iterative_distance_clustering(data)
    end 

    function iterative_linkage_coeff_var(~,~,~)
        shape_classification_iterative_linkage_coeff_var_clustering(data)
    end 

    function iterative_distance_coeff_var(~,~,~)
        shape_classification_iterative_distance_coeff_var_clustering(data)
    end 

    function iterative_pairwise_clustering(~,~,~)
        shape_classification_iterative_pairwise_clustering(data)
    end 

    function filter_mass(~,~,~)
        shape_classification_filter_mass(data)
    end

    function filter_area(~,~,~)
        shape_classification_filter_area(data)
    end

    function filter_aspect_ratio(~,~,~)
        shape_classification_filter_aspect_ratio(data)
    end

    function ellipses_plot(~,~,~)
        shape_classification_ellipses_plot(data)
    end

    function extract_classes(~,~,~)
        shape_classification_extract_classes(data)
    end

    function axes_limits(~,~,~)
        
        global data_to_plot ax ScatterShape
        
        disp(['The minimum and maximum of the overall data is: [' num2str(minData(1)) ', ' num2str(maxData(1)) ', ' num2str(minData(2)) ', ' num2str(maxData(2)) ']'])
        
        if AutoAxesVal == 1
            Enabled = {'on','on','off','off','off','off','off','off','off','off'};
            AutoVal = 1;
            AdrianaVal = 0;
        elseif AdrianaAxesVal == 1
            Enabled = {'off','off','on','on','off','off','off','off','off','off'};
            AutoVal = 0;
            AdrianaVal = 1;
        else
            Enabled = {'on','on','on','on','on','on','on','on','on','on'};
            AutoVal = 0;
            AdrianaVal = 0;
        end
        
        InputFigure = figure('Units','Normalized','Position',[.4 .4 .18 .2],'NumberTitle','off','Name','Axes limits','menubar','none');
        
        CurrentAxis = ['Current axes: [' num2str(floor(ax.XLim(1))) ',' num2str(ceil(ax.XLim(2))) ',' num2str(floor(ax.YLim(1))) ',' num2str(ceil(ax.YLim(2))) ']'];
        CurrentAxis_text = uicontrol('Style','text','Units','Normalized','Position',[.05 .85 .9 .13],'String',CurrentAxis,'FontSize',10,'FontWeight','bold');
        
        AutoAxes_text = uicontrol('Style','text','Units','Normalized','Position',[.17 .72 .6 .1],'String','Automatic axes','HorizontalAlignment','left','FontSize',10,'Enable',Enabled{1});
        AutoAxes = uicontrol('Style','checkbox','Units','Normalized','Position',[.1 .72 .05 .1],'Value',AutoVal,'Enable',Enabled{2},'CallBack',@LimitsCallback);
        
        AdrianaAxes_text = uicontrol('Style','text','Units','Normalized','Position',[.62 .72 .6 .1],'String','Adriana only','HorizontalAlignment','left','FontSize',10,'Enable',Enabled{3});
        AdrianaAxes = uicontrol('Style','checkbox','Units','Normalized','Position',[.55 .72 .05 .1],'Value',AdrianaVal,'Enable',Enabled{4},'CallBack',@AdrianaCallback);
        
        xAxisLimits_text = uicontrol('Style','text','Units','Normalized','Position',[.11 .5 .3 .1],'String','x-axis limits: ','HorizontalAlignment','left','Enable',Enabled{5},'FontSize',10);
        xAxisLimits1 = uicontrol('Style','Edit','Units','Normalized','Position',[.45 .5 .15 .1],'Enable',Enabled{6},'FontSize',10);
        xAxisLimits2 = uicontrol('Style','Edit','Units','Normalized','Position',[.7 .5 .15 .1],'Enable',Enabled{7},'FontSize',10);
        
        yAxisLimits_text = uicontrol('Style','text','Units','Normalized','Position',[.11 .35 .3 .1],'String','y-axis limits: ','HorizontalAlignment','left','Enable',Enabled{8},'FontSize',10);
        yAxisLimits1 = uicontrol('Style','Edit','Units','Normalized','Position',[.45 .35 .15 .1],'Enable',Enabled{9},'FontSize',10);
        yAxisLimits2 = uicontrol('Style','Edit','Units','Normalized','Position',[.7 .35 .15 .1],'Enable',Enabled{10},'FontSize',10);
        
        Done = uicontrol('Style','PushButton','Units','Normalized','Position',[.25 .1 .2 .13],'String','OK','CallBack',@DoneCallback);
        Cancel = uicontrol('Style','PushButton','Units','Normalized','Position',[.55 .1 .2 .13],'String','Cancel','CallBack',@CancelCallback);
        
        uiwait(InputFigure)
        
        function LimitsCallback(~,~,~)
            if AutoAxes.Value == 0
                xAxisLimits_text.Enable = 'on';
                xAxisLimits1.Enable = 'on';
                xAxisLimits2.Enable = 'on';
                
                yAxisLimits_text.Enable = 'on';
                yAxisLimits1.Enable = 'on';
                yAxisLimits2.Enable = 'on';
                
                AdrianaAxes_text.Enable = 'on';
                AdrianaAxes.Enable = 'on';
                
                AutoVal = 1;
            elseif AutoAxes.Value == 1
                xAxisLimits_text.Enable = 'off';
                xAxisLimits1.Enable = 'off';
                xAxisLimits2.Enable = 'off';
                
                yAxisLimits_text.Enable = 'off';
                yAxisLimits1.Enable = 'off';
                yAxisLimits2.Enable = 'off';
                
                AdrianaAxes_text.Enable = 'off';
                AdrianaAxes.Enable = 'off';
                
                AutoVal = 0;
            end
        end
        
        function AdrianaCallback(~,~,~)
            if AdrianaAxes.Value == 0
                xAxisLimits_text.Enable = 'on';
                xAxisLimits1.Enable = 'on';
                xAxisLimits2.Enable = 'on';
                
                yAxisLimits_text.Enable = 'on';
                yAxisLimits1.Enable = 'on';
                yAxisLimits2.Enable = 'on';
                
                AutoAxes_text.Enable = 'on';
                AutoAxes.Enable = 'on';
            elseif AdrianaAxes.Value == 1
                xAxisLimits_text.Enable = 'off';
                xAxisLimits1.Enable = 'off';
                xAxisLimits2.Enable = 'off';
                
                yAxisLimits_text.Enable = 'off';
                yAxisLimits1.Enable = 'off';
                yAxisLimits2.Enable = 'off';
                
                AutoAxes_text.Enable = 'off';
                AutoAxes.Enable = 'off';
            end
        end
        
        function DoneCallback(~,~,~)
            uiresume(InputFigure)
            
            if AdrianaAxes.Value == 1
                ScatterShape.XData = ScatterShape.XData - min(ScatterShape.XData);
                ScatterShape.YData = ScatterShape.YData - min(ScatterShape.YData);
                 
                minX = -SizeWindow+max(ScatterShape.XData)/2;
                maxX = SizeWindow+max(ScatterShape.XData)/2;
                minY = -SizeWindow+max(ScatterShape.YData)/2;
                maxY = SizeWindow+max(ScatterShape.YData)/2;
                
                AutoAxesVal = 0;
                AdrianaAxesVal = 1;
            elseif AutoAxes.Value == 1
                ScatterShape.XData = data_to_plot(:,1);
                ScatterShape.YData = data_to_plot(:,2);
                
                minX = min(data_to_plot(:,1));
                maxX = max(data_to_plot(:,1));
                minY = min(data_to_plot(:,2));
                maxY = max(data_to_plot(:,2));
                
                AutoAxesVal = 1;
                AdrianaAxesVal = 0;
            elseif AutoAxes.Value == 0
                ScatterShape.XData = data_to_plot(:,1);
                ScatterShape.YData = data_to_plot(:,2);
                
                minX = str2double(xAxisLimits1.String);
                maxX = str2double(xAxisLimits2.String);
                minY = str2double(yAxisLimits1.String);
                maxY = str2double(yAxisLimits2.String);
                
                AutoAxesVal = 0;
                AdrianaAxesVal = 0;
            end
            xlim(ax,[minX maxX])
            ylim(ax,[minY maxY])
            drawnow
            pbaspect(ax,[1 1 1])
            axis(ax,'off')
            close(InputFigure)
        end
        
        function CancelCallback(~,~,~)
            uiresume(InputFigure)
            close(InputFigure)
        end
        
    end

    function class_distribution(~,~,~)

        InputFigure = figure('Units','Normalized','Position',[.4 .4 .3 .15],'NumberTitle','off','Name','Class distribution','menubar','none');

        NmbLocalizations_text = uicontrol('Style','text','Units','Normalized','Position',[.15 .8 .3 .12],'String','Number of localizations','HorizontalAlignment','left','FontSize',10);
        NmbLocalizations = uicontrol('Style','checkbox','Units','Normalized','Position',[.1 .8 .05 .1],'Value',0);

        AreaCluster_text = uicontrol('Style','text','Units','Normalized','Position',[.15 .6 .3 .12],'String','Cluster area','HorizontalAlignment','left','FontSize',10);
        AreaCluster = uicontrol('Style','checkbox','Units','Normalized','Position',[.1 .6 .05 .1],'Value',0);

        MajorAxis_text = uicontrol('Style','text','Units','Normalized','Position',[.15 .4 .3 .12],'String','Major Axis','HorizontalAlignment','left','FontSize',10);
        MajorAxis = uicontrol('Style','checkbox','Units','Normalized','Position',[.1 .4 .05 .1],'Value',0);

        MinorAxis_text = uicontrol('Style','text','Units','Normalized','Position',[.65 .8 .3 .12],'String','Minor Axis','HorizontalAlignment','left','FontSize',10);
        MinorAxis = uicontrol('Style','checkbox','Units','Normalized','Position',[.6 .8 .05 .1],'Value',0);

        AspectRatio_text = uicontrol('Style','text','Units','Normalized','Position',[.65 .6 .3 .12],'String','Aspect Ratio','HorizontalAlignment','left','FontSize',10);
        AspectRatio = uicontrol('Style','checkbox','Units','Normalized','Position',[.6 .6 .05 .1],'Value',0);

        Done = uicontrol('Style','PushButton','Units','Normalized','Position',[.1 .1 .35 .15],'String','OK','CallBack',@DoneDistCallback);
        Cancel = uicontrol('Style','PushButton','Units','Normalized','Position',[.55 .1 .35 .15],'String','Cancel','CallBack',@CancelDistCallback);

        uiwait(InputFigure)

        function DoneDistCallback(~,~,~)
            uiresume(InputFigure)
            VariablesDist = [NmbLocalizations.Value AreaCluster.Value*2 MajorAxis.Value*7 MinorAxis.Value*8 AspectRatio.Value*9];
            close(InputFigure)
            
            ParametersSelected = data.classes{1,2}; % Select the parameters
            VariablesDist(VariablesDist==0) = []; % Remove the columns that do not have to be selected
            ParametersSelected(:,9) = ParametersSelected(:,7) ./ ParametersSelected(:,8); % Calculate the aspect ratio (major axis / minor axis)
            ParametersSelected = ParametersSelected(:,VariablesDist); % Extract the parameters to use
            
            AutoScaled_Params = normalize(ParametersSelected); % Autoscale the variables (if the variance is not the same, one variable will have a higher weight in the calculation and bias everything)
            Classmean = mean(AutoScaled_Params); % Calculate the mean
            ClassesDistance = pdist2(AutoScaled_Params,Classmean,'Euclidean'); % Calculate the distance with respect to the mean
            
            if sum(VariablesDist) ~= 0
                shape_classification_plot_distribution(data,ClassesDistance);
            else
                msgbox('At least one parameter has to be selected to continue!')
            end
        end

        function CancelDistCallback(~,~,~)
            uiresume(InputFigure)
            close(InputFigure)
        end

    end

    function closereq(~,~,~)
        minX = [];
        maxX = [];
        minY = [];
        maxY = [];
        AutoAxesVal = 1;
        AdrianaAxesVal = 0;
        
        close(fig)
    end
end

function shape_classification_plot_inside(classes,slider_one_value,slider_two_value,total_no_of_clusters,no_of_classes,name)

global minX maxX minY maxY data_to_plot ScatterShape AutoAxesVal AdrianaAxesVal SizeWindow ax

data_to_plot = classes{slider_one_value,1}{slider_two_value};
parameters = classes{slider_one_value,2};
group = classes{slider_one_value,4}{slider_two_value};

%data_to_plot(:,1) = data_to_plot(:,1)-min(data_to_plot(:,1));
%data_to_plot(:,2) = data_to_plot(:,2)-min(data_to_plot(:,2));

if AutoAxesVal == 1 || isempty(minX)
    minX = min(data_to_plot(:,1));
    maxX = max(data_to_plot(:,1));
    minY = min(data_to_plot(:,2));
    maxY = max(data_to_plot(:,2));
end

for i = 1:size(classes,1)
    colors{i} = unique(cell2mat(classes{i,4}));
end
colors = unique(vertcat(colors{:}));
c_map = colormap(jet);
c_map = interp1(1:size(c_map,1),c_map,linspace(1,size(c_map,1),max(colors)));

if AdrianaAxesVal ~= 1
    ScatterShape = scatter(data_to_plot(:,1),data_to_plot(:,2),5,c_map(group,:),'filled');
else
    ScatterShape = scatter(data_to_plot(:,1)-min(data_to_plot(:,1)),data_to_plot(:,2)-min(data_to_plot(:,2)),5,c_map(group,:),'filled');
    
    minX = -SizeWindow+max(ScatterShape.XData)/2;
    maxX = SizeWindow+max(ScatterShape.XData)/2;
    minY = -SizeWindow+max(ScatterShape.YData)/2;
    maxY = SizeWindow+max(ScatterShape.YData)/2;
end

ax = gca;
set(ax,'color','k')

xlim(ax,[minX maxX])
ylim(ax,[minY maxY])
pbaspect(ax,[1 1 1])
axis(ax,'off')

title({'','',['File Name = ',regexprep(name,'_',' ')],['Total number of clusters = ',num2str(sum(total_no_of_clusters))],['Class Color = ',num2str(classes{slider_one_value,4}{slider_two_value})],['Class numer = ',num2str(slider_one_value),' / ',num2str(no_of_classes)],['Cluster number = ',num2str(slider_two_value),'/',num2str(length(classes{slider_one_value,1}))],['Mass = ',num2str(size(data_to_plot,1)),'  Area = ',num2str(classes{slider_one_value,2}(slider_two_value,2))],['Length = ',num2str(classes{slider_one_value,2}(slider_two_value,7)),'  Width = ',num2str(classes{slider_one_value,2}(slider_two_value,8))]},'interpreter','latex','fontsize',12)
end