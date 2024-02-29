function voronoi_area_percentiles_inside(data)
input = inputdlg({'Number of Percentiles'},'',1,{'2'});
if isempty(input)~=1
    no_of_percentile_ranges = str2double(input{1});    
    for i=1:no_of_percentile_ranges
        prompt{i} = ['cell ',num2str(i),' percentile range'];
        default_input{i} = '10 90';
    end
    answer = inputdlg(prompt,'Input space separated numbers',1,default_input);
    
    if isempty(answer)~=1
        f = waitbar(0,'Calculating CDF');
        for i=1:length(data)
            waitbar(i/length(data),f,['Calculating CDF...',num2str(i),'/',num2str(length(data))]);             
            [data_cdf_pdf{i},data_cdf_pdf_norm{i}] = find_cdf_pdf(data{i}.vor.voronoi_areas,answer);
            names{i} = data{i}.name;
        end
        close(f)        
        plot_data_cdf_pdf(data_cdf_pdf,data_cdf_pdf_norm,names)
        plot_data_table(data_cdf_pdf,names)
        plot_data_table_norm(data_cdf_pdf_norm,names)
    end
end

    function [data_cdf_pdf,data_cdf_pdf_norm] = find_cdf_pdf(areas,percentile)
        for m = 1:length(percentile)
            range = str2num(percentile{m});            
            I1 = prctile(areas,range(1));
            I2 = prctile(areas,range(2));
            wanted = areas(areas<I2 & areas>I1);               
            
            x_hist = linspace(min(wanted),max(wanted),5000);
            y_pdf = histcounts(wanted,x_hist,'normalization','probability');
            y_cdf = histcounts(wanted,x_hist,'normalization','cdf');
            x_pdf = x_hist(1:end-1);
            x_cdf = x_hist(1:end-1);
            
            area_norm = areas;
            area_norm(isnan(area_norm)) = [];
            area_norm = wanted/mean(area_norm);
            I1_norm = prctile(area_norm,range(1));
            I2_norm = prctile(area_norm,range(2));
            wanted_norm = areas(areas<I2_norm & areas>I1_norm);  
            x_hist_norm = linspace(min(wanted_norm),max(wanted_norm),5000);
            y_pdf_norm = histcounts(wanted_norm,x_hist_norm,'normalization','probability');
            y_cdf_norm = histcounts(wanted_norm,x_hist_norm,'normalization','cdf');
            x_pdf_norm = x_hist_norm(1:end-1);
            x_cdf_norm = x_hist_norm(1:end-1);             
            
            data_cdf_pdf{1,m}(:,1) = x_cdf;
            data_cdf_pdf{1,m}(:,2) = y_cdf;
            data_cdf_pdf{2,m} = [I1,I2];
            data_cdf_pdf{3,m} = range;
            data_cdf_pdf{4,m}(:,1) = x_pdf;
            data_cdf_pdf{4,m}(:,2) = y_pdf;         
            
            data_cdf_pdf_norm{1,m}(:,1) = x_cdf_norm;
            data_cdf_pdf_norm{1,m}(:,2) = y_cdf_norm;
            data_cdf_pdf_norm{2,m} = [I1_norm,I2_norm];
            data_cdf_pdf_norm{3,m} = range;
            data_cdf_pdf_norm{4,m}(:,1) = x_pdf_norm;
            data_cdf_pdf_norm{4,m}(:,2) = y_pdf_norm; 
            clear range I1 I2 wanted x_hist x_pdf y_pdf x_cdf y_cdf x_pdf_norm y_pdf_norm x_cdf_norm y_cdf_norm I1_norm I2_norm wanted_norm
         end 
    end
end

function plot_data_cdf_pdf(data,data_norm,name)
figure()
set(gcf,'name','Voronoi Areas Percentiles','NumberTitle','off','color','w','units','normalized','position',[0.15 0.2 0.7 0.5],'menubar','none','toolbar','figure')

if length(data)>1
    slider_step=[1/(length(data)-1),1];
    uicontrol('style','slider','units','normalized','position',[0,0,0.03,1],'value',1,'min',1,'max',length(data),'sliderstep',slider_step,'Callback',{@sld_callback});
end
slider_value=1;
slider_plot_inside(data{slider_value},data_norm{slider_value},name{slider_value})


    function sld_callback(hobj,~,~)
        slider_value = round(get(hobj,'Value'));        
        slider_plot_inside(data{slider_value},data_norm{slider_value},name{slider_value})
    end

    function slider_plot_inside(data,data_norm,name)   
        subplot(2,2,1)
        ax = gca; cla(ax);
        hold on
        for i = 1:size(data,2)
            plot(data{4,i}(:,1),data{4,i}(:,2))
            percentiles{i} = [num2str(data{3,i}(1)),' percentile:',num2str(data{2,i}(1)),'/',num2str(data{3,i}(2)),' percentile:',num2str(data{2,i}(2))];
        end
        legend(percentiles)
        title(regexprep(name,'_',' '),'interpreter','latex','fontsize',16)
        set(gca,'TickLength',[0.02 0.02],'FontName','TimesNewRoman','FontSize',12,'TickLabelInterpreter','latex')
        box on
        xlabel('Voronoi Areas','interpreter','latex','fontsize',16)
        ylabel('PDF','interpreter','latex','fontsize',16)
        
        subplot(2,2,2)
        ax = gca; cla(ax);
        hold on
        for i = 1:size(data,2)
            plot(data{1,i}(:,1),data{1,i}(:,2))
        end                
        set(gca,'TickLength',[0.02 0.02],'FontName','TimesNewRoman','FontSize',12,'TickLabelInterpreter','latex')
        box on
        xlabel('Voronoi Areas','interpreter','latex','fontsize',16)
        ylabel('CDF','interpreter','latex','fontsize',16)
        
        subplot(2,2,3)
        ax = gca; cla(ax);
        hold on
        for i = 1:size(data_norm,2)
            plot(data_norm{4,i}(:,1),data_norm{4,i}(:,2))      
            percentiles_norm{i} = [num2str(data_norm{3,i}(1)),' percentile:',num2str(data_norm{2,i}(1)),'/',num2str(data_norm{3,i}(2)),' percentile:',num2str(data_norm{2,i}(2))];
        end  
        legend(percentiles_norm)
        set(gca,'TickLength',[0.02 0.02],'FontName','TimesNewRoman','FontSize',12,'TickLabelInterpreter','latex')
        box on
        xlabel('Voronoi Areas (Norm)','interpreter','latex','fontsize',16)
        ylabel('PDF','interpreter','latex','fontsize',16)
        
        subplot(2,2,4)
        ax = gca; cla(ax);
        hold on
        for i = 1:size(data_norm,2)
            plot(data_norm{1,i}(:,1),data_norm{1,i}(:,2))
        end        
        set(gca,'TickLength',[0.02 0.02],'FontName','TimesNewRoman','FontSize',12,'TickLabelInterpreter','latex')
        box on
        xlabel('Voronoi Areas (Norm)','interpreter','latex','fontsize',16)
        ylabel('CDF','interpreter','latex','fontsize',16)
    end
end

function plot_data_table(data,names)
figure()
set(gcf,'name','Percentiles Table','NumberTitle','off','color','w','units','normalized','position',[0.15 0.2 0.8 0.6],'menubar','none','toolbar','figure')

column_names = data{1}(3,:);
column_names = horzcat(column_names{:});
for k = 1:length(data)
    I{k} = data{k}(2,:);      
end
for k = 1:length(I)
    I{k} = horzcat(I{k}{:});    
end
I = vertcat(I{:});

axis off
title('Voronoi Areas','interpreter','latex','fontsize',18)
uitable('Data',I,'units','normalized','position',[0 0 1 0.9],'ColumnWidth',{100},'FontSize',12,'ColumnName',column_names,'RowName',names);

uimenu('Text','Save Data (.csv file)','ForegroundColor','b','CallBack',@save_data);

    function save_data(~,~,~)
        [file,path] = uiputfile('*.csv');
        if path~=0
            for i = 1:length(column_names)
                variable_names{i} = num2str(column_names(i));
            end
            table_data = array2table(I,'VariableNames',variable_names,'RowNames',names);
            f = waitbar(0,'Saving...');
            writetable(table_data,fullfile(path,file))
            waitbar(1,f,'Saving...')
            close(f)
        end
    end
end
function plot_data_table_norm(data,names)
figure()
set(gcf,'name','Percentiles Table','NumberTitle','off','color','w','units','normalized','position',[0.15 0.2 0.8 0.6],'menubar','none','toolbar','figure')

column_names = data{1}(3,:);
column_names = horzcat(column_names{:});
for k = 1:length(data)
    I{k} = data{k}(2,:);      
end
for k = 1:length(I)
    I{k} = horzcat(I{k}{:});    
end
I = vertcat(I{:});

axis off
title('Norm Voronoi Areas','interpreter','latex','fontsize',18)
uitable('Data',I,'units','normalized','position',[0 0 1 0.9],'ColumnWidth',{100},'FontSize',12,'ColumnName',column_names,'RowName',names);

uimenu('Text','Save Data (.csv file)','ForegroundColor','b','CallBack',@save_data);

    function save_data(~,~,~)
        [file,path] = uiputfile('*.csv');
        if path~=0
            for i = 1:length(column_names)
                variable_names{i} = num2str(column_names(i));
            end
            table_data = array2table(I,'VariableNames',variable_names,'RowNames',names);
            f = waitbar(0,'Saving...');
            writetable(table_data,fullfile(path,file))
            waitbar(1,f,'Saving...')
            close(f)
        end
    end
end