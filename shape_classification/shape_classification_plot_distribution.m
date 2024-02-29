function shape_classification_plot_distribution(dataClass,ClassesDistance)

fig = clf(figure());
set(fig,'name','Class distribution','NumberTitle','off','color','w','units','normalized','position',[0.275 0.175 0.4 0.4],'menubar','none','toolbar','none')

CurrentAutomaticAxes = 1;
CurrentBox = 0;
CurrentGrid = 0;
CurrentMinorGrid = 0;

file_menu = uimenu('Text','File');
uimenu(file_menu,'Text','Save histogram as .png','Callback',@save_png_callback);
uimenu(file_menu,'Text','Save histogram as .tiff','Callback',@save_tiff_callback);
uimenu(file_menu,'Text','Save raw data as .csv','Callback',@save_data_callback);

display_menu = uimenu('Text','Histogram layout');
uimenu(display_menu,'Text','Default histogram','Callback',@default_settings);
uimenu(display_menu,'Text','Change histogram','Callback',@change_settings);
uimenu(display_menu,'Text','Change plot layout','Callback',@change_plot_settings);

visualization_menu = uimenu('Text','Visualize classes');
uimenu(visualization_menu,'Text','Visualize classes (%)','Callback',@visualize_perc_classes);
uimenu(visualization_menu,'Text','Visualize classes (Distance)','Callback',@visualize_dist_classes);

shape_classification_plot_distribution_inside(ClassesDistance)


    function save_data_callback(~,~,~)
        sortedData = sort(ClassesDistance);
        
        ParameterNames = {'Number of localizations','Cluster area','','','','','Major axis','Minor axis','Aspect ratio'};
        ParameterNames = strjoin(ParameterNames(VariablesDist),' / ');
        ParameterNames = {horzcat('Distance to the class mean based on ',ParameterNames)};
        
        Table = array2table([ParameterNames;num2cell(sortedData)]);
        
        [file,path] = uiputfile('*.csv','Please specify a name to save the statistics as');
        name = fullfile(path,file);
        writetable(Table,name,'WriteVariableNames',false);
    end

    function save_png_callback(~,~,~)
        [file,path] = uiputfile('*.png','Please specify a name to save the histogram');
        name = fullfile(path,file);
        print(gcf,name,'-dpng','-r300');
    end

    function save_tiff_callback(~,~,~)
        [file,path] = uiputfile('*.tiff','Please specify a name to save the histogram');
        name = fullfile(path,file);
        print(gcf,name,'-dtiff','-r300');
    end

    function default_settings(~,~,~)
        shape_classification_plot_distribution_inside(ClassesDistance)
    end

    function change_settings(~,~,~)
        
        global HistDist HistFigure
        
        ColorChoiceStr = {'Auto','Black','Red','Green','Blue','Cyan','Magenta','Yellow'};
        ColorChoice = {'Auto','000','100','010','001','011','101','110'};
        NormalizationStr = {'Probability','Count','Countdensity','Pdf','Cumcount','Cdf'};
        
        CurrentBins = HistDist.NumBins;
        CurrentBinWidth = HistDist.BinWidth;
        
        CurrentNorm = HistDist.Normalization;
        NormString = horzcat(NormalizationStr(strcmpi(NormalizationStr,CurrentNorm)),NormalizationStr(~strcmpi(NormalizationStr,CurrentNorm)));
        
        CurrentDispStyle = HistDist.DisplayStyle;
        CurrentLnWidth = HistDist.LineWidth;
        
        CurrentEdgeColor = strrep(num2str(HistDist.EdgeColor),' ','');
        CurrentEdgeAlpha = HistDist.EdgeAlpha;
        EdgeColor = horzcat(ColorChoiceStr(strcmpi(ColorChoice,CurrentEdgeColor)),ColorChoiceStr(~strcmpi(ColorChoice,CurrentEdgeColor)));
        EdgeColor(2) = [];
        
        CurrentFaceColor = strrep(num2str(HistDist.FaceColor),' ','');
        CurrentFaceAlpha = HistDist.FaceAlpha;
        FaceColor = horzcat(ColorChoiceStr(strcmpi(ColorChoice,CurrentFaceColor)),ColorChoiceStr(~strcmpi(ColorChoice,CurrentFaceColor)));        
        
        
        ColorChoiceStr2 = {'Auto','Black','Red','Green','Blue','Cyan','Magenta','Yellow'};
        ColorChoice2 = {'0.150.150.15','000','100','010','001','011','101','110'};
        ColorChoiceVec = [0.15 0.15 0.15;0 0 0;1 0 0;0 1 0;0 0 1;0 1 1; 1 0 1; 1 1 0];
        
        FontList = listfonts;
        FontStyle = {'Normal','bold'};
        
        if CurrentAutomaticAxes == 1
            Enabled = 'off';
        else
            Enabled = 'on';
        end
        
        if CurrentGrid == 1
            EnabledmGrid = 'on';
        else
            EnabledmGrid = 'off';
        end
        
        CurrentLnWidth2 = HistFigure.LineWidth;
        CurrentAxisColor = strrep(num2str(HistFigure.XColor),' ','');
        AxisColor = horzcat(ColorChoiceStr2(strcmpi(ColorChoice2,CurrentAxisColor)),ColorChoiceStr2(~strcmpi(ColorChoice2,CurrentAxisColor)));
        AxisColorOrder = [find(strcmpi(ColorChoice2,CurrentAxisColor)) find(~strcmpi(ColorChoice2,CurrentAxisColor))];
        ColorChoiceVec = ColorChoiceVec(AxisColorOrder,:);
        ColorChoiceStr2 = ColorChoiceStr2(AxisColorOrder);
        
        CurrentfntName = HistFigure.FontName;
        FntName = vertcat(FontList(strcmpi(FontList,CurrentfntName)),FontList(~strcmpi(FontList,CurrentfntName)));
        CurrentfntSize = HistFigure.FontSize;
        CurrentfntWeight = HistFigure.FontWeight;
        FntWght = horzcat(FontStyle(strcmpi(FontStyle,CurrentfntWeight)),FontStyle(~strcmpi(FontStyle,CurrentfntWeight)));
        
        CurrentXLim = HistFigure.XLim;
        CurrentYLim = HistFigure.YLim;
        
        
        InputFigure = figure('Units','Normalized','Position',[fig.Position(1)+fig.Position(3) fig.Position(2) .3 .43],'NumberTitle','off','Name','Histogram display settings','menubar','none');
        
        Histogrampanel = uipanel(InputFigure,'Units','Normalized','Position',[0.05 0.555 0.9 0.4]);
        uicontrol('Style','text','Units','Normalized','Position',[.075 .925 .28 .05],'String','Histogram options: ','HorizontalAlignment','left','FontSize',10,'FontWeight','bold');
                
        uicontrol(Histogrampanel,'Style','text','Units','Normalized','Position',[.1 .805 .25 .12],'String','Number of bins: ','HorizontalAlignment','left','FontSize',10);
        NumBins = uicontrol(Histogrampanel,'Style','Edit','Units','Normalized','Position',[.34 .805 .1 .12],'String',num2str(CurrentBins),'callback',@binsCallback);
        
        uicontrol(Histogrampanel,'Style','text','Units','Normalized','Position',[.55 .805 .25 .12],'String','BinWidth: ','HorizontalAlignment','left','FontSize',10);
        BinWidth = uicontrol(Histogrampanel,'Style','Edit','Units','Normalized','Position',[.73 .805 .1 .12],'String',num2str(CurrentBinWidth),'callback',@binWidthCallback);
        
        uicontrol(Histogrampanel,'Style','text','Units','Normalized','Position',[.1 .63 .22 .12],'String','Normalization: ','HorizontalAlignment','left','FontSize',10);
        Normalization = uicontrol(Histogrampanel,'Style','popupmenu','Units','Normalized','Position',[.34 .63 .2 .12],'String',NormString,'callback',@normCallback);
        
        uicontrol(Histogrampanel,'Style','text','Units','Normalized','Position',[.1 .43 .2 .12],'String','Display style: ','HorizontalAlignment','left','FontSize',10);
        if strcmp(CurrentDispStyle,'bar')
            DispStyle = uicontrol(Histogrampanel,'Style','popupmenu','Units','Normalized','Position',[.34 .43 .2 .12],'String',{'Bar','Stairs'},'callback',@dispStyleCallback);
        else
            DispStyle = uicontrol(Histogrampanel,'Style','popupmenu','Units','Normalized','Position',[.34 .43 .2 .12],'String',{'Stairs','Bar'},'callback',@dispStyleCallback);
        end
        if strcmp(CurrentDispStyle,'bar')
            LnWidth_text = uicontrol(Histogrampanel,'Style','text','Units','Normalized','Position',[.55 .43 .25 .12],'String','LineWidth: ','HorizontalAlignment','left','FontSize',10,'Enable','off');
            LnWidth = uicontrol(Histogrampanel,'Style','Edit','Units','Normalized','Position',[.73 .43 .1 .12],'String',num2str(CurrentLnWidth),'Enable','off','callback',@LnWidthCallback);
        else
            LnWidth_text = uicontrol(Histogrampanel,'Style','text','Units','Normalized','Position',[.55 .43 .25 .12],'String','LineWidth: ','HorizontalAlignment','left','FontSize',10,'Enable','on');
            LnWidth = uicontrol(Histogrampanel,'Style','Edit','Units','Normalized','Position',[.73 .43 .1 .12],'String',num2str(CurrentLnWidth),'Enable','on','callback',@LnWidthCallback);
        end
        
        uicontrol(Histogrampanel,'Style','text','Units','Normalized','Position',[.1 .23 .2 .12],'String','Edge colour: ','HorizontalAlignment','left','FontSize',10);
        EdgeCol = uicontrol(Histogrampanel,'Style','popupmenu','Units','Normalized','Position',[.34 .23 .2 .12],'String',EdgeColor,'callback',@edgeColCallback);
        
        uicontrol(Histogrampanel,'Style','text','Units','Normalized','Position',[.55 .23 .2 .12],'String','Edge alpha: ','HorizontalAlignment','left','FontSize',10);
        EdgeColAlpha = uicontrol(Histogrampanel,'Style','Slider','Units','Normalized','Position',[.73 .23 .2 .12],'Value',CurrentEdgeAlpha,'Min',0,'Max',1,'SliderStep',[0.1 0.25],'callback',@edgeColAlphaCallback);
        
        if strcmp(CurrentDispStyle,'bar')
            FaceCol_text = uicontrol(Histogrampanel,'Style','text','Units','Normalized','Position',[.1 .08 .2 .12],'String','Face colour: ','HorizontalAlignment','left','FontSize',10,'Enable','on');
            FaceCol = uicontrol(Histogrampanel,'Style','popupmenu','Units','Normalized','Position',[.34 .08 .2 .12],'String',FaceColor,'Enable','on','callback',@faceColCallback);
         
            FaceColAlpha_text = uicontrol(Histogrampanel,'Style','text','Units','Normalized','Position',[.55 .08 .2 .12],'String','Face alpha: ','HorizontalAlignment','left','FontSize',10,'Enable','on');
            FaceColAlpha = uicontrol(Histogrampanel,'Style','Slider','Units','Normalized','Position',[.73 .08 .2 .12],'Value',CurrentFaceAlpha,'Min',0,'Max',1,'SliderStep',[0.1 0.25],'Enable','on','callback',@faceColAlphaCallback);
        else
            FaceCol_text = uicontrol(Histogrampanel,'Style','text','Units','Normalized','Position',[.1 .08 .2 .12],'String','Face colour: ','HorizontalAlignment','left','FontSize',10,'Enable','off');
            FaceCol = uicontrol(Histogrampanel,'Style','popupmenu','Units','Normalized','Position',[.34 .08 .2 .12],'String',FaceColor,'Enable','off','callback',@faceColCallback);
         
            FaceColAlpha_text = uicontrol(Histogrampanel,'Style','text','Units','Normalized','Position',[.55 .08 .2 .12],'String','Face alpha: ','HorizontalAlignment','left','FontSize',10,'Enable','off');
            FaceColAlpha = uicontrol(Histogrampanel,'Style','Slider','Units','Normalized','Position',[.73 .08 .2 .12],'Value',CurrentFaceAlpha,'Min',0,'Max',1,'SliderStep',[0.1 0.25],'Enable','off','callback',@faceColAlphaCallback);
        end
        
        
        Axispanel = uipanel(InputFigure,'Units','Normalized','Position',[0.05 0.05 0.9 0.465]);
        uicontrol('Style','text','Units','Normalized','Position',[.075 .485 .19 .05],'String','Axis options: ','HorizontalAlignment','left','FontSize',10,'FontWeight','bold');
        
        uicontrol(Axispanel,'Style','text','Units','Normalized','Position',[.1 .83 .2 .1],'String','Thickness: ','HorizontalAlignment','left','FontSize',10);
        LnWidth2 = uicontrol(Axispanel,'Style','Edit','Units','Normalized','Position',[.3 .83 .1 .1],'String',num2str(CurrentLnWidth2),'callback',@LnWidth2Callback);
        
        uicontrol(Axispanel,'Style','text','Units','Normalized','Position',[.475 .83 .2 .1],'String','Axis colour: ','HorizontalAlignment','left','FontSize',10);
        AxCol = uicontrol(Axispanel,'Style','popupmenu','Units','Normalized','Position',[.675 .83 .2 .1],'String',AxisColor,'callback',@AxisColorCallback);
        
        uicontrol(Axispanel,'Style','text','Units','Normalized','Position',[.1 .67 .2 .1],'String','Font: ','HorizontalAlignment','left','FontSize',10);
        FntNameVal = uicontrol(Axispanel,'Style','popupmenu','Units','Normalized','Position',[.3 .67 .45 .1],'String',FntName,'callback',@FontNameCallback);
        
        uicontrol(Axispanel,'Style','text','Units','Normalized','Position',[.1 .54 .2 .1],'String','Font Size: ','HorizontalAlignment','left','FontSize',10);
        FntSizeVal = uicontrol(Axispanel,'Style','Edit','Units','Normalized','Position',[.3 .54 .1 .1],'String',num2str(CurrentfntSize),'callback',@FontSizeCallback);
        
        uicontrol(Axispanel,'Style','text','Units','Normalized','Position',[.475 .54 .2 .1],'String','Font style: ','HorizontalAlignment','left','FontSize',10);
        FntWghtVal = uicontrol(Axispanel,'Style','popupmenu','Units','Normalized','Position',[.675 .54 .2 .1],'String',FntWght,'callback',@FontWeightCallback);
        
        uicontrol(Axispanel,'Style','text','Units','Normalized','Position',[.15 .38 .3 .1],'String','Automatic axis limits','HorizontalAlignment','left','FontSize',10);
        AutomAxes = uicontrol(Axispanel,'Style','checkbox','Units','Normalized','Position',[.1 .38 .05 .1],'Value',CurrentAutomaticAxes,'callback',@AutomaticAxesCallback);
        
        minText = uicontrol(Axispanel,'Style','text','Units','Normalized','Position',[.3 .28 .1 .1],'String','min','HorizontalAlignment','center','Enable',Enabled,'FontSize',10);
        maxText = uicontrol(Axispanel,'Style','text','Units','Normalized','Position',[.425 .28 .1 .1],'String','max','HorizontalAlignment','center','Enable',Enabled,'FontSize',10);
        
        xAxisLimits_text = uicontrol(Axispanel,'Style','text','Units','Normalized','Position',[.1 .17 .3 .1],'String','x-axis limits: ','HorizontalAlignment','left','Enable',Enabled,'FontSize',10);
        xAxisLimits1 = uicontrol(Axispanel,'Style','Edit','Units','Normalized','Position',[.3 .17 .1 .1],'String',num2str(CurrentXLim(1)),'Enable',Enabled,'FontSize',10,'callback',@xLim1Callback);
        xAxisLimits2 = uicontrol(Axispanel,'Style','Edit','Units','Normalized','Position',[.425 .17 .1 .1],'String',num2str(CurrentXLim(2)),'Enable',Enabled,'FontSize',10,'callback',@xLim2Callback);
        
        yAxisLimits_text = uicontrol(Axispanel,'Style','text','Units','Normalized','Position',[.1 .05 .3 .1],'String','y-axis limits: ','HorizontalAlignment','left','Enable',Enabled,'FontSize',10);
        yAxisLimits1 = uicontrol(Axispanel,'Style','Edit','Units','Normalized','Position',[.3 .05 .1 .1],'String',num2str(CurrentYLim(1)),'Enable',Enabled,'FontSize',10,'callback',@yLim1Callback);
        yAxisLimits2 = uicontrol(Axispanel,'Style','Edit','Units','Normalized','Position',[.425 .05 .1 .1],'String',num2str(CurrentYLim(2)),'Enable',Enabled,'FontSize',10,'callback',@yLim2Callback);
        
        uicontrol(Axispanel,'Style','text','Units','Normalized','Position',[.725 .3 .3 .1],'String','Box','HorizontalAlignment','left','FontSize',10);
        Boxes = uicontrol(Axispanel,'Style','checkbox','Units','Normalized','Position',[.675 .3 .05 .1],'Value',CurrentBox,'callback',@boxCallback);
        
        uicontrol(Axispanel,'Style','text','Units','Normalized','Position',[.725 .2 .3 .1],'String','Grid','HorizontalAlignment','left','FontSize',10);
        Grids = uicontrol(Axispanel,'Style','checkbox','Units','Normalized','Position',[.675 .2 .05 .1],'Value',CurrentGrid,'callback',@gridCallback);
        
        MinorGrids_text = uicontrol(Axispanel,'Style','text','Units','Normalized','Position',[.725 .1 .3 .1],'String','Minor grid','HorizontalAlignment','left','FontSize',10);
        MinorGrids = uicontrol(Axispanel,'Style','checkbox','Units','Normalized','Position',[.675 .1 .05 .1],'Value',CurrentMinorGrid,'Enable',EnabledmGrid,'callback',@minorgridCallback);
        
        
        function binsCallback(~,~,~)
            HistDist.NumBins = str2double(NumBins.String);
            CurrentBinWidth = HistDist.BinWidth;
            BinWidth.String = CurrentBinWidth;
        end
        
        function binWidthCallback(~,~,~)
            HistDist.BinWidth = str2double(BinWidth.String);
            CurrentBins = HistDist.NumBins;
            NumBins.String = CurrentBins;
        end
        
        function normCallback(~,~,~)
            HistDist.Normalization = Normalization.String{Normalization.Value};
            ylabel(HistFigure,Normalization.String{Normalization.Value},'FontWeight','bold','FontSize',10);
            
            CurrentXLim = HistFigure.XLim;
            CurrentYLim = HistFigure.YLim;
            xAxisLimits1.String = num2str(HistFigure.XLim(1));
            xAxisLimits2.String = num2str(HistFigure.XLim(2));
            yAxisLimits1.String = num2str(HistFigure.YLim(1));
            yAxisLimits2.String = num2str(HistFigure.YLim(2));
        end
        
        function dispStyleCallback(~,~,~)
            HistDist.DisplayStyle = DispStyle.String{DispStyle.Value};
            if strcmp(HistDist.DisplayStyle,'stairs')
                FaceCol.Enable = 'off';
                FaceColAlpha.Enable = 'off';
                FaceCol_text.Enable = 'off';
                FaceColAlpha_text.Enable = 'off';
                LnWidth_text.Enable = 'on';
                LnWidth.Enable = 'on';
            else
                FaceCol.Enable = 'on';
                FaceColAlpha.Enable = 'on';
                FaceCol_text.Enable = 'on';
                FaceColAlpha_text.Enable = 'on';
                LnWidth_text.Enable = 'off';
                LnWidth.Enable = 'off';
            end
        end
        
        function LnWidthCallback(~,~,~)
            HistDist.LineWidth = str2double(LnWidth.String);
        end
        
        function edgeColCallback(~,~,~)
            HistDist.EdgeColor = EdgeCol.String{EdgeCol.Value};
        end
        
        function faceColCallback(~,~,~)
            HistDist.FaceColor = FaceCol.String{FaceCol.Value};
        end
        
        function edgeColAlphaCallback(~,~,~)
            HistDist.EdgeAlpha = EdgeColAlpha.Value;
        end
        
        function faceColAlphaCallback(~,~,~)
            HistDist.FaceAlpha = FaceColAlpha.Value;
        end
        
                
        function LnWidth2Callback(~,~,~)
            HistFigure.LineWidth = str2double(LnWidth2.String);
        end
        
        function AxisColorCallback(~,~,~)
            HistFigure.XColor = ColorChoiceVec(AxCol.Value,:);
            HistFigure.YColor = ColorChoiceVec(AxCol.Value,:);
        end
        
        function FontNameCallback(~,~,~)
            HistFigure.FontName = FntNameVal.String{FntNameVal.Value};
        end
        
        function FontSizeCallback(~,~,~)
            HistFigure.FontSize = str2double(FntSizeVal.String);
        end
        
        function FontWeightCallback(~,~,~)
            HistFigure.FontWeight = FntWghtVal.String{FntWghtVal.Value};
        end
        
        function AutomaticAxesCallback(~,~,~)
            if AutomAxes.Value == 0
                CurrentAutomaticAxes = 0;
                
                minText.Enable = 'on';
                maxText.Enable = 'on';
                xAxisLimits_text.Enable = 'on';
                xAxisLimits1.Enable = 'on';
                xAxisLimits2.Enable = 'on';
                yAxisLimits_text.Enable = 'on';
                yAxisLimits1.Enable = 'on';
                yAxisLimits2.Enable = 'on';
            else
                CurrentAutomaticAxes = 1;
                axis(HistFigure,'auto')
                
                xAxisLimits1.String = num2str(HistFigure.XLim(1));
                xAxisLimits2.String = num2str(HistFigure.XLim(2));
                yAxisLimits1.String = num2str(HistFigure.YLim(1));
                yAxisLimits2.String = num2str(HistFigure.YLim(2));
                
                minText.Enable = 'off';
                maxText.Enable = 'off';
                xAxisLimits_text.Enable = 'off';
                xAxisLimits1.Enable = 'off';
                xAxisLimits2.Enable = 'off';
                yAxisLimits_text.Enable = 'off';
                yAxisLimits1.Enable = 'off';
                yAxisLimits2.Enable = 'off';
            end                
        end
        
        function xLim1Callback(~,~,~)
            if str2double(xAxisLimits1.String) >= 0 && str2double(xAxisLimits1.String) < CurrentXLim(2)
                CurrentXLim = [str2double(xAxisLimits1.String) CurrentXLim(2)];
                HistFigure.XLim = CurrentXLim;
            else
                msgbox(['The entered value for the minimum x limit should be between 0 and ' num2str(CurrentXLim(2)) '.']);
            end
        end
        
        function xLim2Callback(~,~,~)
            if str2double(xAxisLimits2.String) > CurrentXLim(1)
                CurrentXLim = [CurrentXLim(1) str2double(xAxisLimits2.String)];
                HistFigure.XLim = CurrentXLim;
            else
                msgbox(['The entered value for the maximum x limit should be between ' num2str(CurrentXLim(1)) ' and Inf.']);
            end
        end
        
        function yLim1Callback(~,~,~)
            if str2double(yAxisLimits1.String) >= 0 && str2double(yAxisLimits1.String) < CurrentYLim(2)
                CurrentYLim = [str2double(yAxisLimits1.String) CurrentYLim(2)];
                HistFigure.YLim = CurrentYLim;
            else
                msgbox(['The entered value for the minimum y limit should be between 0 and ' num2str(CurrentYLim(2)) '.']);
            end
        end
        
        function yLim2Callback(~,~,~)
            if str2double(yAxisLimits2.String) > CurrentYLim(1)
                CurrentYLim = [CurrentYLim(1) str2double(yAxisLimits2.String)];
                HistFigure.YLim = CurrentYLim;
            else
                msgbox(['The entered value for the maximum y limit should be between ' num2str(CurrentYLim(1)) ' and Inf.']);
            end
        end
        
        function boxCallback(~,~,~)
            if Boxes.Value == 1
                box(HistFigure,'on')
                CurrentBox = 1;
            else
                box(HistFigure,'off')
                CurrentBox = 0;
            end
        end
        
        function gridCallback(~,~,~)
            if Grids.Value == 1
                grid(HistFigure,'on')
                CurrentGrid = 1;
                
                MinorGrids_text.Enable = 'on';
                MinorGrids.Enable = 'on';
            else
                grid(HistFigure,'off')
                CurrentGrid = 0;
                
                MinorGrids_text.Enable = 'off';
                MinorGrids.Enable = 'off';
                MinorGrids.Value = 0;
                CurrentMinorGrid = 0;
            end
        end
        
        function minorgridCallback(~,~,~)
            if MinorGrids.Value == 1
                HistFigure.XMinorGrid = 'on';
                CurrentMinorGrid = 1;
            else
                HistFigure.XMinorGrid = 'off';
                CurrentMinorGrid = 0;
            end
        end
        
    end

    function visualize_perc_classes(~,~,~)
        
        Input_Values = inputdlg({'Minimum percentage (in %):','Maximum percentage (in %):'},'',1,{'0','100'});
        if isempty(Input_Values)
            return
        else
            minSelect = round(str2double(Input_Values{1})/100*size(ClassesDistance,1))+1;
            maxSelect = round(str2double(Input_Values{2})/100*size(ClassesDistance,1));
            
            [~,I] = sort(ClassesDistance);
            I = I(minSelect:maxSelect);
            ClassesSelected = ClassesDistance(I);
            
            data_to_plot.classes{1} = dataClass.classes{1}(I);
            data_to_plot.classes{2} = dataClass.classes{2}(I,:);
            data_to_plot.classes{3} = dataClass.classes{3};
            data_to_plot.classes{4} = dataClass.classes{4}(I);
            
            Name = ['_distribution_' Input_Values{1} '_perc_to_' Input_Values{2} '_perc'];
            data_to_plot.name = horzcat(dataClass.name,Name);
            data_to_plot.type = 'shape_class';
            shape_classification_plot(data_to_plot)
            shape_classification_plot_distribution(dataClass,ClassesSelected)
        end
    end

    function visualize_dist_classes(~,~,~)
        
        Input_Values = inputdlg({'Minimum distance:','Maximum distance:'},'',1,{'0',num2str(max(ClassesDistance))});
        if isempty(Input_Values)
            return
        else
            minSelect = str2double(Input_Values{1});
            maxSelect = str2double(Input_Values{2});
            
            
            I = find(ClassesDistance>=minSelect&ClassesDistance<=maxSelect);
            ClassesSelected = ClassesDistance(I);
            
            data_to_plot.classes{1} = dataClass.classes{1}(I);
            data_to_plot.classes{2} = dataClass.classes{2}(I,:);
            data_to_plot.classes{3} = dataClass.classes{3};
            data_to_plot.classes{4} = dataClass.classes{4}(I);
            
            Name = ['_distribution_' Input_Values{1} '_to_' Input_Values{2}];
            data_to_plot.name = horzcat(dataClass.name,Name);
            data_to_plot.type = 'shape_class';
            shape_classification_plot(data_to_plot)
            shape_classification_plot_distribution(dataClass,ClassesSelected)
        end
    end

end

function shape_classification_plot_distribution_inside(ClassesDistance)

global HistDist HistFigure

HistDist = histogram(ClassesDistance,round(size(ClassesDistance,1)/5),'Normalization','probability');
xlabel('Distance to class center','FontWeight','bold','FontSize',10);ylabel('Probability','FontWeight','bold','FontSize',10);
set(gca,'FontWeight','bold','FontSize',10,'LineWidth',2);box off;
pbaspect([2 1 1])
HistFigure = gca;

end