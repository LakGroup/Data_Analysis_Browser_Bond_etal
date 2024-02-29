function shape_classification_features_info(data)
clf(figure())
set(gcf,'name','Features Info','NumberTitle','off','color','w','units','normalized','position',[0.1 0.2 0.4 0.6],'menubar','none','toolbar','none')

no_of_classes = size(data.classes,1);
slider_one_value = 1;
if no_of_classes>1
    slider_one_step=[1/(no_of_classes-1),0.25];
    slider_one = uicontrol('style','slider','units','normalized','position',[0,0,0.05,1],'value',1,'min',1,'max',no_of_classes,'sliderstep',slider_one_step,'Callback',{@sld_one_callback});
end

feature_table(data.classes{slider_one_value,2});

feature_all = data.classes(:,2);
feature_all = vertcat(feature_all{:});
feature_table_all(feature_all);

feature_mean = data.classes(:,3);
feature_mean = vertcat(feature_mean{:});
feature_table_mean(feature_mean);

    function sld_one_callback(~,~,~)
        slider_one_value = round(slider_one.Value);
        feature_table(data.classes{slider_one_value,2});
        
    end

    function feature_table(data)         
        data(end+1,:) = abs(std(data,0,1)./mean(data,1));
        uitable('Data',data,'units','normalized','Position',[0.05 0 0.95 0.9],'FontSize',12);
        title({['class number = ',num2str(slider_one_value)],['number of clusters =',num2str(size(data,1))],['features dimension =',num2str(size(data,2))]},'interpreter','latex','fontsize',14)
    end

    function feature_table_all(data)
        figure()
        axis off
        set(gcf,'name','Features Info (all features)','NumberTitle','off','color','w','units','normalized','position',[0.2 0.2 0.4 0.6],'menubar','none','toolbar','none')
        uitable('Data',data,'units','normalized','Position',[0 0 1 0.9],'FontSize',12);
        title({['number of clusters =',num2str(size(data,1))],['features dimension =',num2str(size(data,2))]},'interpreter','latex','fontsize',14)
    end

    function feature_table_mean(data)
        figure()
        axis off
        set(gcf,'name','Features Info (mean claases features)','NumberTitle','off','color','w','units','normalized','position',[0.3 0.2 0.4 0.6],'menubar','none','toolbar','none')
        uitable('Data',data,'units','normalized','Position',[0 0 1 0.9],'FontSize',12);
        title({['number of classes =',num2str(size(data,1))],['features dimension =',num2str(size(data,2))]},'interpreter','latex','fontsize',14)
    end
end