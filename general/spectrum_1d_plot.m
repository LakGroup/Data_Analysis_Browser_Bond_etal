function spectrum_1d_plot(data)
figure()
set(gcf,'name','Spectrum 1D','NumberTitle','off','color','w','units','normalized','position',[0.3 0.2 0.4 0.6],'menubar','none','toolbar','figure')
hold on
for i = 1:length(data)
    plot(data{i}.x_data,data{i}.y_data)
    names{i} = data{i}.name;
end
set(gca,'TickLength',[0.02 0.02],'FontName','TimesNewRoman','FontSize',12,'TickLabelInterpreter','latex')
box on
legend(regexprep(names,'_',' '))
end