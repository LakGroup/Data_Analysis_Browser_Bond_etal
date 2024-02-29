function image_plot_right_click(data,name)
ax = gca; cla(ax);
mouse_location = get(gca,'CurrentPoint');
imagesc(data)
colormap(gray)
title({'',regexprep(name,'_',' ')},'Interpreter','latex','fontsize',14)
line([mouse_location(1,1) mouse_location(1,1)],[1 size(image,1)],'Color','r','LineStyle','--')
line([1 size(image,2)],[mouse_location(1,2) mouse_location(1,2)],'Color','r','LineStyle','--')
if mouse_location(1,1)<size(image,2) && mouse_location(1,1)>1 && mouse_location(1,2)<size(image,1) && mouse_location(1,2)>1
    I1 = round(mouse_location(1,1));
    I2 = round(mouse_location(1,2));
    text(mouse_location(1,1),mouse_location(1,2),{strcat('(',num2str(round(mouse_location(1,1),2)),',',num2str(round(mouse_location(1,2),2)),')'),num2str(image(I2,I1))},'Color','w','interpreter','latex','FontSize',22)
end
set(gca,'TickDir','out','TickLength',[0.02 0.02],'FontName','TimesNewRoman','FontSize',12,'TickLabelInterpreter','latex')
end