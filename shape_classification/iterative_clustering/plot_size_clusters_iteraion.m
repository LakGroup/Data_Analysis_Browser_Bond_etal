function plot_size_clusters_iteraion(size_classes)
    figure();
    set(gcf,'color','w','name','Iterative_clustering','NumberTitle','off','color','w','units','normalized','position',[0.1 0.3 0.3 0.5])
    scatter(1:length(size_classes),size_classes,10,'b','filled')
    hold on
    plot(1:length(size_classes),size_classes,'color','b')
    set(gca,'color',[1,1,1],'TickLength',[0.02 0.02],'TickDir','out','box','on','BoxStyle','full','fontsize',18,'TickLabelInterpreter','latex');
    xlabel('Number of Iterations','interpreter','latex','fontsize',18)
    ylabel('Number of Clusters','interpreter','latex','fontsize',18)
end