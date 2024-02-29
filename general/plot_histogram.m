function plot_histogram(x_pdf,y_pdf,x_cdf,y_cdf,names,x_label,percentile)
figure()
set(gcf,'name','histogram','NumberTitle','off','color','w','units','normalized','position',[0.15 0.2 0.7 0.5],'menubar','none','toolbar','figure')

subplot(1,2,1)
hold on
for i = 1:length(x_pdf)    
    plot(x_pdf{i},y_pdf{i})
end
set(gca,'TickDir', 'out','box','on','BoxStyle','full','TickLabelInterpreter','latex','fontsize',12)
legend(regexprep(names,'_',' '))
xlabel([x_label,' [',num2str(percentile),'] Percentile'],'interpreter','latex','fontsize',18)
ylabel('PDF','interpreter','latex','fontsize',18)

subplot(1,2,2)
hold on
for i = 1:length(x_cdf)    
    plot(x_cdf{i},y_cdf{i})
end
set(gca,'TickDir', 'out','box','on','BoxStyle','full','TickLabelInterpreter','latex','fontsize',12)
legend(regexprep(names,'_',' '))
xlabel([x_label,' [',num2str(percentile),'] Percentile'],'interpreter','latex','fontsize',18)
ylabel('CDF','interpreter','latex','fontsize',18)
end