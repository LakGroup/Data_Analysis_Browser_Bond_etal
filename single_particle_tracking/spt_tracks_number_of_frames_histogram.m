function spt_tracks_number_of_frames_histogram(data)
input_values = inputdlg({'number of bins:'},'',1,{'100'});
if isempty(input_values)==1
    return
else
    number_of_bins = str2double(input_values{1});
    
    figure()
    set(gcf,'name','Tracks Number of Frames Histogram','NumberTitle','off','color','w','units','normalized','position',[0.2 0.3 0.6 0.6],'menubar','none','toolbar','figure')
    
    if length(data)>1
        slider_step=[1/(length(data)-1),1];
        slider = uicontrol('style','slider','units','normalized','position',[0,0,0.03,1],'value',1,'min',1,'max',length(data),'sliderstep',slider_step,'Callback',{@sld_callback});
    end
    slider_value=1;
    
    uimenu('Text','Save Number of Tracks Data (Excel File)','ForegroundColor','k','CallBack',@save_data);
    
    plot_tracks_length_histogram(data{slider_value}.tracks,data{slider_value}.name)
end

    function sld_callback(~,~,~)
        slider_value = round(slider.Value);        
        plot_tracks_length_histogram(data{slider_value}.tracks,data{slider_value}.name)
    end

    function plot_tracks_length_histogram(data,name)
        ax = gca; cla(ax);
        for k=1:length(data)
            tracks_length(k) = size(data{k},1);
        end
        hist(tracks_length,number_of_bins)
        set(gca,'TickLength',[0.02 0.02],'FontName','TimesNewRoman','FontSize',12,'TickLabelInterpreter','latex')
        box on
        title({['File Name = ',regexprep(name,'_',' ')],['Number of Tracks = ',num2str(length(data))],['Average Number of Frames = ',num2str(mean(tracks_length))],['Median Number of Frames = ',num2str(median(tracks_length))],['Maximum Number of Frames = ',num2str(max(tracks_length))],['Minimum Number of Frames = ',num2str(min(tracks_length))]},'interpreter','latex','fontsize',14)
        xlabel('Number of Frames','interpreter','latex','fontsize',18)
        ylabel('Counts','interpreter','latex','fontsize',18)
        pbaspect([1 1 1])
    end

    function save_data(~,~,~)
        save_data_inside(data)
    end

    function save_data_inside(data)
        for i = 1: length(data)
            data_to_perform = data{i}.tracks;
            for k=1:length(data_to_perform)
                tracks_length{i}(k,1) = size(data_to_perform{k},1);
            end
            clear data_to_perform
            names{i} = data{i}.name;
        end
        path = uigetdir(pwd);
        if path~=0
            for i = 1:length(tracks_length)
                [counts,centers] = hist(tracks_length{i},number_of_bins);
                dlmwrite([fullfile(path,names{i}),'.txt'],tracks_length{i})
                dlmwrite([fullfile(path,names{i}),'_hist_data.txt'],[centers',counts'])
            end
        end
    end
end