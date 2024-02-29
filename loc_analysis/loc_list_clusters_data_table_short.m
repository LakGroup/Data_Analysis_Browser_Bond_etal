function loc_list_clusters_data_table_short(data)
counter = 0;
for i = 1:length(data)
    data_to = unique(data{i}.area);
    if length(data_to)>1
        counter = counter+1;
        data_to_send{counter} = data{i};
    end
end
if exist('data_to_send','var')
    f = waitbar(0,'Extracting Data Table Information...');
    for i = 1:length(data_to_send)
        data_table{i} = clusters_extract_statistics(data_to_send{i});
        waitbar(i/length(data_to_send),f,['Extracting Data Table Information...',num2str(i),'/',num2str(length(data_to_send))]);
    end
    close(f)
    plot_data_table(data_table)
else
    msgbox('there is only one cluster')
end
end

function data_table = clusters_extract_statistics(data)
data_table.name = data.name;
clusters = loc_list_extract_clusters_from_data(data);
for i = 1:length(clusters)
    data_table.data(i,1) = size(clusters{i},1);
   
    xRef = clusters{i}(:,1);
    yRef = clusters{i}(:,2);
    shpRef{i,1} = alphaShape(xRef,yRef);
    CritAlpha = criticalAlpha(shpRef{i},'one-region');
    shpRef{i}.Alpha = CritAlpha;
    data_table.data(i,2) = area(shpRef{i});
    
end
temp = data_table.data(:,1)./data_table.data(:,2);
temp(temp==Inf) = 0;
data_table.data(:,3) = temp;
data_table.data(:,4) = data_table.data(:,3)./mean(data_table.data(:,3));
data_table.data = sortrows(data_table.data,1);
end

function plot_data_table(data)
figure()
set(gcf,'name','clusters_statistics_table','NumberTitle','off','color','w','units','normalized','position',[0.15 0.2 0.7 0.6],'menubar','none','toolbar','figure')

if length(data)>1
    slider_step=[1/(length(data)-1),1];
    uicontrol('style','slider','units','normalized','position',[0,0,0.05,0.9],'value',1,'min',1,'max',length(data),'sliderstep',slider_step,'Callback',{@sld_callback});
end
slider_value=1;
slider_plot_inside(data{slider_value})

uimenu('Text','Send Data to Excel Sheet','ForegroundColor','b','CallBack',@save_data);

    function save_data(~,~,~)
        [file,path] = uiputfile('*.xlsx');
        if path~=0            
            save_to = fullfile(path,file);
            for i = 1:length(data)                  
                data_table = array2table(data{i}.data);
                data_table.Properties.VariableNames = {'Locs','Area','Locs/Area (Density)','Normalized Density'};
                name = data{i}.name;
                name = erase(name,'_');
                name = erase(name,'\');
                name = erase(name,'/');
                name = erase(name,'?');
                name = erase(name,'*');
                name = erase(name,'?');
                name = erase(name,']');
                name = erase(name,'[');
                name = erase(name,':');
                name = name(1:30);
                writetable(data_table,save_to,'sheet',name)                
            end
        end
    end

    function sld_callback(hobj,~,~)
        slider_value = round(get(hobj,'Value'));        
        slider_plot_inside(data{slider_value})
    end

    function slider_plot_inside(data)
        axis off
        title(regexprep(data.name,'_',' '),'interpreter','latex','fontsize',18)
        uitable('Data',data.data,'units','normalized','position',[0.05 0 0.95 0.9],'ColumnWidth',{150},'FontSize',12,'ColumnName',{'Locs','Area','Locs/Area (Density)','Normalized Density'});
    end
end