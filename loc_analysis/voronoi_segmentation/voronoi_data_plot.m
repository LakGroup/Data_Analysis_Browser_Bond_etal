function voronoi_data_plot(data)
percentile_range = [0 95];

f = waitbar(0,'Calculating PDF and CDF..');
for i = 1:length(data)
    waitbar(i/length(data),f,['Calculating PDF and CDF..',num2str(i),'/',num2str(length(data))]);
    [x_pdf{i},y_pdf{i},x_cdf{i},y_cdf{i}] = calculate_pdf_cdf(data{i}.vor.voronoi_areas,percentile_range);
    [x_pdf_norm{i},y_pdf_norm{i},x_cdf_norm{i},y_cdf_norm{i}] = calculate_pdf_cdf_norm(data{i}.vor.voronoi_areas,percentile_range);
    [x_pdf_reverse{i},y_pdf_reverse{i},x_cdf_reverse{i},y_cdf_reverse{i}] = calculate_pdf_cdf_reverse(data{i}.vor.voronoi_areas,percentile_range);
    names{i} = data{i}.name;
end
close(f)

figure()
set(gcf,'name','Voronoi Segmentation','NumberTitle','off','color','w','units','normalized','position',[0.3 0.1 0.4 0.8],'menubar','none','toolbar','figure')

voronoi_data_plot_inside(x_pdf,y_pdf,x_cdf,y_cdf,x_pdf_norm,y_pdf_norm,x_cdf_norm,y_cdf_norm,x_pdf_reverse,y_pdf_reverse,x_cdf_reverse,y_cdf_reverse,names,percentile_range)

file_menu = uimenu('Text','File');
uimenu(file_menu,'Text','Send Data to Workspace','ForegroundColor','b','CallBack',@send_data_callback);

segmentation_menu = uimenu('Text','Start Clustering');
uimenu(segmentation_menu,'Text','Cluster using Voronoi Areas Threshold','ForegroundColor','b','CallBack',@cluster_value_callback);
uimenu(segmentation_menu,'Text','Cluster using Voronoi Areas Threshold (Percentile)','ForegroundColor','b','CallBack',@cluster_percentile_callback);

data_menu = uimenu('Text','Data');
uimenu(data_menu,'Text','Localization Density','ForegroundColor','b','CallBack',@localization_density);
uimenu(data_menu,'Text','Voronoi Area Data','ForegroundColor','b','CallBack',@voronoi_data);
uimenu(data_menu,'Text','CDF Data','ForegroundColor','b','CallBack',@cdf_data);
uimenu(data_menu,'Text','PDF Data','ForegroundColor','b','CallBack',@pdf_data);
uimenu(data_menu,'Text','Voronoi Area Percentiles','ForegroundColor','b','CallBack',@voronoi_area_percentiles);

seperate_menu = uimenu('Text','Seperate Localizations');
uimenu(seperate_menu,'Text','Seperate Localizations Based on Voronoi Areas (Threshold Value)','ForegroundColor','b','CallBack',@seperate_data_value);
uimenu(seperate_menu,'Text','Seperate Localizations Based on Voronoi Areas (Percentile)','ForegroundColor','b','CallBack',@seperate_data_percentile);

    function voronoi_data_plot_inside(x_pdf,y_pdf,x_cdf,y_cdf,x_pdf_norm,y_pdf_norm,x_cdf_norm,y_cdf_norm,x_pdf_reverse,y_pdf_reverse,x_cdf_reverse,y_cdf_reverse,names,percentile_range)
        subplot(3,2,1)
        hold on
        for k = 1:length(x_pdf)
            plot(x_pdf{k},y_pdf{k})
        end
        box on
        grid on
        set(gca,'TickDir','out','TickLength',[0.02 0.02],'FontName','TimesNewRoman','FontSize',12,'TickLabelInterpreter','latex')
        legend(regexprep(names,'_',' '))
        title(['[',num2str(percentile_range), '] Percentile'],'interpreter','latex','fontsize',16)
        xlabel('Voronoi Areas','interpreter','latex','fontsize',16)
        ylabel('PDF','interpreter','latex','fontsize',16)
        
        subplot(3,2,2)
        hold on
        for k = 1:length(x_cdf)
            plot(x_cdf{k},y_cdf{k})
        end
        box on
        grid on
        set(gca,'TickDir','out','TickLength',[0.02 0.02],'FontName','TimesNewRoman','FontSize',12,'TickLabelInterpreter','latex')
        legend(regexprep(names,'_',' '))
        xlabel('Voronoi Areas','interpreter','latex','fontsize',16)
        ylabel('CDF','interpreter','latex','fontsize',16)
        
        subplot(3,2,3)
        hold on
        for k = 1:length(x_cdf)
            plot(x_pdf_norm{k},y_pdf_norm{k})
        end
        box on
        grid on
        set(gca,'TickDir','out','TickLength',[0.02 0.02],'FontName','TimesNewRoman','FontSize',12,'TickLabelInterpreter','latex')
        legend(regexprep(names,'_',' '))
        xlabel('$\frac{Voronoi Areas}{mean(Voronoi Areas)}$','interpreter','latex','fontsize',16)
        ylabel('PDF','interpreter','latex','fontsize',16)        
        
        subplot(3,2,4)
        hold on
        for k = 1:length(x_cdf)
            plot(x_cdf_norm{k},y_cdf_norm{k})
        end
        box on
        grid on
        set(gca,'TickDir','out','TickLength',[0.02 0.02],'FontName','TimesNewRoman','FontSize',12,'TickLabelInterpreter','latex')
        legend(regexprep(names,'_',' '))
        xlabel('$\frac{Voronoi Areas}{mean(Voronoi Areas)}$','interpreter','latex','fontsize',16)
        ylabel('CDF','interpreter','latex','fontsize',16)
        
          subplot(3,2,5)
        hold on
        for k = 1:length(x_cdf)
            plot(x_pdf_reverse{k},y_pdf_reverse{k})
        end
        box on
        grid on
        set(gca,'TickDir','out','TickLength',[0.02 0.02],'FontName','TimesNewRoman','FontSize',12,'TickLabelInterpreter','latex')
        legend(regexprep(names,'_',' '))
        xlabel('$\frac{1}{Voronoi Areas}$','interpreter','latex','fontsize',16)
        ylabel('PDF','interpreter','latex','fontsize',16)        
        
        subplot(3,2,6)
        hold on
        for k = 1:length(x_cdf)
            plot(x_cdf_reverse{k},y_cdf_reverse{k})
        end
        box on
        grid on
        set(gca,'TickDir','out','TickLength',[0.02 0.02],'FontName','TimesNewRoman','FontSize',12,'TickLabelInterpreter','latex')
        legend(regexprep(names,'_',' '))
        xlabel('$\frac{1}{Voronoi Areas}$','interpreter','latex','fontsize',16)
        ylabel('CDF','interpreter','latex','fontsize',16)      

    end

    function send_data_callback(~,~,~)
        send_data_to_workspace(data)
    end

    function cluster_value_callback(~,~,~)
        [data_clustered,data_not_clustered] = voronoi_data_get_voronoi_cluster(data,1);
        loc_list_plot(data_clustered)
        loc_list_plot(data_not_clustered)
    end

    function cluster_percentile_callback(~,~,~)
        [data_clustered,data_not_clustered] = voronoi_data_get_voronoi_cluster(data,2);
        loc_list_plot(data_clustered)
        loc_list_plot(data_not_clustered)
    end

    function localization_density(~,~,~)
        for k = 1:length(data)
            areas =  data{k}.vor.voronoi_areas;
            areas(isnan(areas)) = [];            
            data_table{k,1} = 1/(mean(areas));
            clear areas
            row_names{k} = data{k}.name;
        end
        table_data_plot(data_table,row_names,{'Localization Density'},'Localization Density')
    end

    function voronoi_data(~,~,~)
        for k = 1:length(data)
            data_table{k} = voronoi_data_table(data{k});
        end
        plot_data_table(data_table)
    end

    function cdf_data(~,~,~)
        for k = 1:length(data)
            data_table{k}.data(:,1) = x_cdf{k};
            data_table{k}.data(:,2) = y_cdf{k};
            data_table{k}.data(:,3) = x_cdf_norm{k};
            data_table{k}.data(:,4) = y_cdf_norm{k};
            data_table{k}.name = data{k}.name;
        end
        plot_cdf_data_table(data_table)
    end

    function pdf_data(~,~,~)
        for k = 1:length(data)
            data_table{k}.data(:,1) = x_pdf{k};
            data_table{k}.data(:,2) = y_pdf{k};
            data_table{k}.data(:,3) = x_pdf_norm{k};
            data_table{k}.data(:,4) = y_pdf_norm{k};
            data_table{k}.name = data{k}.name;
        end
        plot_pdf_data_table(data_table)
    end

    function voronoi_area_percentiles(~,~,~)
        voronoi_area_percentiles_inside(data)
    end

    function seperate_data_value(~,~,~)
        loc_list_voronoi_seperate_based_on_value(data)
    end

    function seperate_data_percentile(~,~,~) 
        loc_list_voronoi_seperate_based_on_percentile(data)
    end

end

function data_table = voronoi_data_table(data)
va = data.vor.voronoi_areas;
va_mean = va;
va_mean(isnan(va_mean)) = [];
va_mean = mean(va_mean);
va(:,2) = va/va_mean;
data_table.data = va;
data_table.name = data.name;
end

function plot_data_table(data)
figure()
set(gcf,'name','voronoi_areas_data','NumberTitle','off','color','w','units','normalized','position',[0.3 0.2 0.4 0.6],'menubar','none','toolbar','figure')

if length(data)>1
    slider_step=[1/(length(data)-1),1];
    uicontrol('style','slider','units','normalized','position',[0,0,0.05,0.9],'value',1,'min',1,'max',length(data),'sliderstep',slider_step,'Callback',{@sld_callback});
end
slider_value=1;
slider_plot_inside(data{slider_value})

uimenu('Text','Save Data (.mat file)','ForegroundColor','b','CallBack',@save_data);

    function save_data(~,~,~)
        [file,path] = uiputfile('*.mat');
        if path~=0
            for i = 1:length(data) 
                voronoi_data{i,1} = data{i}.name;
                voronoi_data{i,2} = data{i}.data;                             
            end
            f = waitbar(0,'Saving...');
            save(fullfile(path,file),'voronoi_data')
            waitbar(1,f,'Saving...')
            close(f)
        end
    end

    function sld_callback(hobj,~,~)
        slider_value = round(get(hobj,'Value'));        
        slider_plot_inside(data{slider_value})
    end

    function slider_plot_inside(data)
        axis off
        title(regexprep(data.name,'_',' '),'interpreter','latex','fontsize',18)
        uitable('Data',data.data,'units','normalized','position',[0.05 0 0.95 0.9],'ColumnWidth',{150},'FontSize',12,'ColumnName',{'Voronoi Areas','Normalized Voronoi Areas'});
    end
end

function plot_cdf_data_table(data)
figure()
set(gcf,'name','voronoi_areas_cdf','NumberTitle','off','color','w','units','normalized','position',[0.3 0.2 0.4 0.6],'menubar','none','toolbar','figure')

if length(data)>1
    slider_step=[1/(length(data)-1),1];
    uicontrol('style','slider','units','normalized','position',[0,0,0.05,0.9],'value',1,'min',1,'max',length(data),'sliderstep',slider_step,'Callback',{@sld_callback});
end
slider_value=1;
slider_plot_inside(data{slider_value})

uimenu('Text','Save Data (.mat file)','ForegroundColor','b','CallBack',@save_data);

    function save_data(~,~,~)
        [file,path] = uiputfile('*.mat');
        if path~=0
            for i = 1:length(data) 
                cdf_data{i,1} = data{i}.name;
                cdf_data{i,2} = data{i}.data;                             
            end
            f = waitbar(0,'Saving...');
            save(fullfile(path,file),'cdf_data')
            waitbar(1,f,'Saving...')
            close(f)
        end
    end

    function sld_callback(hobj,~,~)
        slider_value = round(get(hobj,'Value'));        
        slider_plot_inside(data{slider_value})
    end

    function slider_plot_inside(data)
        axis off
        title(regexprep(data.name,'_',' '),'interpreter','latex','fontsize',18)
        uitable('Data',data.data,'units','normalized','position',[0.05 0 0.95 0.9],'ColumnWidth',{150},'FontSize',12,'ColumnName',{'x_CDF','y_CDF','x_CDF_norm','y_CDF_norm'});
    end
end

function plot_pdf_data_table(data)
figure()
set(gcf,'name','voronoi_areas_pdf','NumberTitle','off','color','w','units','normalized','position',[0.3 0.2 0.4 0.6],'menubar','none','toolbar','figure')

if length(data)>1
    slider_step=[1/(length(data)-1),1];
    uicontrol('style','slider','units','normalized','position',[0,0,0.05,0.9],'value',1,'min',1,'max',length(data),'sliderstep',slider_step,'Callback',{@sld_callback});
end
slider_value=1;
slider_plot_inside(data{slider_value})

uimenu('Text','Save Data (.mat file)','ForegroundColor','b','CallBack',@save_data);

    function save_data(~,~,~)
        [file,path] = uiputfile('*.mat');
        if path~=0
            for i = 1:length(data) 
                pdf_data{i,1} = data{i}.name;
                pdf_data{i,2} = data{i}.data;                             
            end
            f = waitbar(0,'Saving...');
            save(fullfile(path,file),'pdf_data')
            waitbar(1,f,'Saving...')
            close(f)
        end
    end

    function sld_callback(hobj,~,~)
        slider_value = round(get(hobj,'Value'));        
        slider_plot_inside(data{slider_value})
    end

    function slider_plot_inside(data)
        axis off
        title(regexprep(data.name,'_',' '),'interpreter','latex','fontsize',18)
        uitable('Data',data.data,'units','normalized','position',[0.05 0 0.95 0.9],'ColumnWidth',{150},'FontSize',12,'ColumnName',{'x_pdf','y_pdf','x_PDF_norm','y_PDF_norm'});
    end
end