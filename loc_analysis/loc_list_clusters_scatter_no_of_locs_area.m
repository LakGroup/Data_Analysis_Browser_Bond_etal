function loc_list_clusters_scatter_no_of_locs_area(data)
counter = 0;
for i = 1:length(data)
    data_to = unique(data{i}.area);
    if length(data_to)>1
        counter = counter+1;
        data_to_send{counter} = data{i};
    end
end
if exist('data_to_send','var')
    scatter_locs_area(data_to_send)    
else
    msgbox('there is only one cluster')
end
end

function scatter_locs_area(data)
figure()
set(gcf,'name','clusters-area-no_of_locs','NumberTitle','off','color','w','units','normalized','position',[0.3 0.2 0.4 0.6],'menubar','none','toolbar','figure')

slider_plot_inside(data)

    function slider_plot_inside(data)        
        hold on
        for i = 1:length(data)
            [cnt_unique, unique_a] = hist(data{i}.area,unique(data{i}.area));
            data_table(:,1) = cnt_unique';
            data_table(:,2) = unique_a';
            scatter(data_table(:,1),data_table(:,2),10,'filled')
            clear cnt_unique unique_a data_table
            names{i} = data{i}.name;
        end
        set(gca,'TickLength',[0.02 0.02],'FontName','TimesNewRoman','FontSize',12,'TickLabelInterpreter','latex')
        box on
        legend(regexprep(names,'_',' '))
        xlabel('Clusters No. of Locs','interpreter','latex','fontsize',18)
        ylabel('Clusters Area','interpreter','latex','fontsize',18)
    end
end