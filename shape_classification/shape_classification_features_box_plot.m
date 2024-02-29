function shape_classification_features_box_plot(data)
clf(figure())
set(gcf,'name','Features Info','NumberTitle','off','color','w','units','normalized','position',[0.1 0.2 0.4 0.6],'menubar','none','toolbar','none')

no_of_classes = size(data.classes,1);
slider_one_value = 1;
if no_of_classes>1
    slider_one_step=[1/(no_of_classes-1),0.25];
    slider_one = uicontrol('style','slider','units','normalized','position',[0,0,0.05,1],'value',1,'min',1,'max',no_of_classes,'sliderstep',slider_one_step,'Callback',{@sld_one_callback});
end

box_plot(data.classes{slider_one_value,2}(:,[1,2,7,8]));

    function sld_one_callback(~,~,~)
        slider_one_value = round(slider_one.Value);
        box_plot(data.classes{slider_one_value,2}(:,[1,2,7,8]));        
    end

    function box_plot(data)
        if size(data,1)>1
            data = zscore(data);
            boxplot(data)
            set(gca,'TickLabelInterpreter','latex','fontsize',14,'XTicklabel',{'Mass','Area','Length','Width'})
            ylabel('z-score','interpreter','latex','fontsize',18)
            pbaspect([1 0.6 1])
            title({['class number = ',num2str(slider_one_value)]},'interpreter','latex','fontsize',14)
        else
            cla(gca)
            axis off
            title({['class number = ',num2str(slider_one_value)],'feature dimension is one'},'interpreter','latex','fontsize',14)
        end
    end
end