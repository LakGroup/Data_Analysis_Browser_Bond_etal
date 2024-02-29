function spt_plot_all_tracks(data)
figure()
set(gcf,'name','All Tracks Plot','NumberTitle','off','color','w','units','normalized','position',[0.2 0.3 0.6 0.6],'menubar','none','toolbar','figure')

if length(data)>1
    slider_step=[1/(length(data)-1),1];
    slider = uicontrol('style','slider','units','normalized','position',[0,0,0.03,1],'value',1,'min',1,'max',length(data),'sliderstep',slider_step,'Callback',{@sld_callback});
end
slider_value=1;

plot_all_tracks_inside(data{slider_value}.tracks,data{slider_value}.name)

    function sld_callback(~,~,~)
        slider_value = round(slider.Value);          
        plot_all_tracks_inside(data{slider_value}.tracks,data{slider_value}.name)
    end

    function plot_all_tracks_inside(data,name)
        ax = gca; cla(ax);
        hold on
        cellfun(@(C1) plot(C1(:,2),C1(:,3),'linewidth',1), data);
        title({['File Name = ',regexprep(name,'_',' ')],['Number of Tracks = ',num2str(length(data))]},'interpreter','latex','fontsize',14)
        set(gca,'TickLength',[0.02 0.02],'FontName','TimesNewRoman','FontSize',12,'TickLabelInterpreter','latex')
        box on
        pbaspect([1 1 1])
    end
end