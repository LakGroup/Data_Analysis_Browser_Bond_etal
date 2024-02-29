function image_plot_mouse_up(data,name)
imagesc(data)
colormap(gray)
title({'',regexprep(name,'_',' ')},'Interpreter','latex','fontsize',14)
set(gca,'TickDir','out','TickLength',[0.02 0.02],'FontName','TimesNewRoman','FontSize',12,'TickLabelInterpreter','latex')
box on
end