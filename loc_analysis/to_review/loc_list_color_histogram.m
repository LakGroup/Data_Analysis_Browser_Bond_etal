function loc_list_color_histogram(data)
input_values = inputdlg({'number of bins:'},'',1,{'100'});
if isempty(input_values)==1
    return    
else
    figure()
    set(gcf,'name','color-histogram-plot','NumberTitle','off','color','w','units','normalized','position',[0.2 0.3 0.6 0.4],'menubar','none','toolbar','figure')
     
    no_of_bins =str2double(input_values{1,1});
    
    if length(data)>1
        slider_step=[1/(length(data)-1),1];
        uicontrol('style','slider','units','normalized','position',[0,0.08,0.03,0.92],'value',1,'min',1,'max',length(data),'sliderstep',slider_step,'Callback',{@sld_callback});
    end
    slider_value=1;
    slider_plot_inside(data{slider_value})
    uicontrol('style','pushbutton','units','normalized','position',[0,0,0.12,0.08],'string','send data to work space','Callback',{@send_data});
end

    function slider_plot_inside(data)
        color = unique(data.color);
        subplot(1,2,1)
        plot(1:length(color),sort(color),'color','b')
        set(gca,'TickDir','out','box','on','BoxStyle','full','TickLabelInterpreter','latex','fontsize',12)
        title({'',regexprep(data.name,'_',' '),['Total Number of Clusters = ',num2str(length(unique(color)))]},'color','k','interpreter','latex','fontsize',14)
        ylabel('Sort(Color Value)','interpreter','latex','fontsize',18)
        
        subplot(1,2,2)
        [counts,centers] = hist(color,no_of_bins);
        bar(centers,counts)
        set(gca,'TickDir', 'out','box','on','BoxStyle','full','TickLabelInterpreter','latex','fontsize',12)
        title('Histogram of Color Data','interpreter','latex','fontsize',18)
        xlabel('Color Value','interpreter','latex','fontsize',18)
        ylabel('Counts','interpreter','latex','fontsize',18)
    end

    function send_data(~,~,~)
        for i = 1:length(data)
            color = unique(data{i}.color);
            data_to_send{i}.x_data = (1:length(color))';
            data_to_send{i}.y_data = color;
            data_to_send{i}.name = [data{i}.name,'_sort_color'];
            data_to_send{i}.type = 'spectrum_1d';
            data_to_send{i}.info = 'NaN';
            clear area
        end
        send_data_to_workspace(data_to_send)
    end

    function sld_callback(hobj,~,~)
        slider_value = round(get(hobj,'Value'));
        slider_plot_inside(data{slider_value})
    end    
end