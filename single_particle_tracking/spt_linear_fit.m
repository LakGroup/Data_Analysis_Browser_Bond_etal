function spt_linear_fit(data)
input_values = inputdlg({'percentage of data to fit:'},'',1,{'25'});
if isempty(input_values)==1
    return
else
    percentage=str2double(input_values{1});    
    for i=1:length(data)
        [data{i}.a,data{i}.b,data{i}.r2] = msd_fit_linear_msd_inside(data{i}.msd,percentage);         
    end    
    msd_fit_linear_msd_plot(data)
end
end

function [a,b,r2] = msd_fit_linear_msd_inside(data,percentage)
ft = fittype('a*x + b');
f = waitbar(0,'Fitting Linear Function');
for i=1:length(data)  
    if (size(data{i},1)*percentage)/100>2        
        data_to_fit = data{i}(1:floor((size(data{i},1)*percentage)/100),:);
    else
        data_to_fit = data{i}(1:2,:);
    end        
    [fo, gof] = fit(data_to_fit(:,1), data_to_fit(:,2), ft, 'StartPoint', [0 0]);
    r2{i} = gof.rsquare;
    a{i} = fo.a;
    b{i} = fo.b;
    clear data_to_fit fo gof    
    waitbar(i/length(data),f,'Fitting Linear Function')
end
close(f)
end

function msd_fit_linear_msd_plot(data)
figure()
set(gcf,'name','MSD Linear Fit','NumberTitle','off','color','w','units','normalized','position',[0.4 0.3 0.5 0.6],'menubar','none','toolbar','figure')

if length(data)>1
    slider_step_one=[1/(length(data)-1),1];
    slider_one = uicontrol('style','slider','units','normalized','position',[0,0,0.04,1],'value',1,'min',1,'max',length(data),'sliderstep',slider_step_one,'Callback',{@sld_one_callback});
end
slider_one_value=1;

if length(data{slider_one_value}.msd)>1
    slider_step_two=[1/(length(data{slider_one_value}.msd)-1),1];
    slider_two = uicontrol('style','slider','units','normalized','position',[0.04,0,0.96,0.04],'value',1,'min',1,'max',length(data{slider_one_value}.msd),'sliderstep',slider_step_two,'Callback',{@sld_two_callback});
end
slider_two_value=1;

msd_fit_linear_msd_plot_inside(data,slider_one_value,slider_two_value)

uimenu('Text','Find Average Diffusion Coefficient (Threshold on r-squared)','ForegroundColor','k','CallBack',@avg_d_callback);
uimenu('Text','Diffusion Coefficients Distribution','ForegroundColor','k','CallBack',@d_distribution);
uimenu('Text','Save Data','ForegroundColor','k','CallBack',@save_data);

    function sld_one_callback(~,~,~)
        slider_one_value = round(slider_one.Value);
        if length(data{slider_one_value}.msd)>1
            slider_two.SliderStep = [1/(length(data{slider_one_value}.msd)-1),1];
            slider_two.Max = length(data{slider_one_value}.msd);
            slider_two.Min = 1;
            slider_two.Value = 1;
        end
        slider_two_value = 1;
        msd_fit_linear_msd_plot_inside(data,slider_one_value,slider_two_value)
    end

    function sld_two_callback(~,~,~)
        slider_two_value = round(slider_two.Value);        
        msd_fit_linear_msd_plot_inside(data,slider_one_value,slider_two_value)
    end

    function avg_d_callback(~,~,~)
        input_values = inputdlg({'r-squared threshold:'},'',1,{'0.9'});
        if isempty(input_values)==1
            return
        else
            r2_threshold=str2double(input_values{1});
            for i=1:length(data)
                r2_values = data{i}.r2;
                a = data{i}.a;
                r2_values = horzcat(r2_values{:});
                names{i} = data{i}.name;
                a = horzcat(a{:});
                I = r2_values >= r2_threshold;
                a = a(I);
                diffusion_coefficient{i} = mean(a)/4;
                clear r2_values a I                
            end
            figure('name','average diffusion coefficient','NumberTitle','off','units','normalized','position',[0 0.1 1 0.4],'menubar','none','toolbar','figure');
            column_width = {200};
            uitable('Data',diffusion_coefficient','units','normalized','position',[0.05 0.05 0.95 0.95],'FontSize',12,'RowName',names,'columnwidth',column_width);
        end
    end

    function d_distribution(~,~,~)
        input_values = inputdlg({'r-squared threshold:','number of bins:'},'',1,{'0.9','100'});
        if isempty(input_values)==1
            return
        else
            r2_threshold = str2double(input_values{1});
            no_of_bins = str2double(input_values{2});
            for i=1:length(data)
                r2_values = data{i}.r2;
                a = data{i}.a;
                r2_values = horzcat(r2_values{:});
                names{i} = data{i}.name;
                a = horzcat(a{:});
                I = r2_values >= r2_threshold;
                a = a(I);
                diffusion_coefficient{i} = a/4;
                clear r2_values a I                
            end
            for i = 1:length(data)
                figure('name','diffusion coefficient distribution','NumberTitle','off','position',[100 200 900 500],'menubar','none','toolbar','figure');
                hist(diffusion_coefficient{i},no_of_bins)
            end
        end
    end

    function save_data(~,~,~)
        path = uigetdir();
        if path~=0
            for i = 1:length(data)
                data_to_save(:,1) = cell2mat(data{i}.a);
                data_to_save(:,2) = cell2mat(data{i}.r2);
                table_data = array2table(data_to_save,'VariableNames',{'a','r2'});
                f = waitbar(0,'Saving...');
                writetable(table_data,fullfile(path,[data{i}.name,'.csv']))
                waitbar(1,f,'Saving...')
                close(f)
                clear data_to_save table_data
            end            
        end       
    end
end

function msd_fit_linear_msd_plot_inside(data,slider_one_value,slider_two_value)
subplot(1,2,2)
ax = gca; cla(ax);
hold on
input_data = data{slider_one_value}.msd;
data_to_plot = input_data{slider_two_value};

a = data{slider_one_value}.a;
a = a{slider_two_value};

b = data{slider_one_value}.b;
b = b{slider_two_value};

r2 = data{slider_one_value}.r2;
r2 = r2{slider_two_value};

name = data{slider_one_value}.name;

diffusion_coefficient = a/4;

plot(data_to_plot(:,1),data_to_plot(:,2),'b','linewidth',1)
x_fit = linspace(data_to_plot(1,1),data_to_plot(end,1),100);
y_fit = a*x_fit+b;
plot(x_fit,y_fit,'r','linewidth',1)
xlabel('Delays (s)','interpreter','latex','FontSize',14)
ylabel('MSD ($um^2/s$)','interpreter','latex','FontSize',14)
title({'',['$r{^2} = $',num2str(r2),'  ,a = ',num2str(a),'  ,b = ',num2str(b),'$,  ax+b$'],['Diffusion Coefficient (a/4) = ',num2str(diffusion_coefficient)],['File Name = ',regexprep(name,'_',' ')],['Track Number = ',num2str(slider_two_value),'/',num2str(length(input_data))]},'interpreter','latex','fontsize',14)
set(gca,'TickLength',[0.02 0.02],'FontName','TimesNewRoman','FontSize',12,'TickLabelInterpreter','latex','box','on','boxstyle','full')

subplot(1,2,1)
ax = gca; cla(ax);
input_data = data{slider_one_value}.tracks;
track_data = input_data{slider_two_value};
plot(track_data(:,2),track_data(:,3),'b','linewidth',1)
hold on
scatter(track_data(1,2),track_data(1,3),30,'r','filled')
xlabel('X','interpreter','latex','fontsize',14)
ylabel('Y','interpreter','latex','fontsize',14)
pbaspect([1 1 1])
end