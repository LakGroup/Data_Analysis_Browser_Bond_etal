function spt_particles_velocity_correlation(data)
for i=1:length(data)
    input_data = data{i}.tracks;
    for k = 1:length(input_data)
        v_corr{k} = calculate_velocity_correlation(input_data{k});
    end
    velocity_correlation{i}.velocity_correlation = v_corr;
    velocity_correlation{i}.name = data{i}.name;
    velocity_correlation{i}.type = 'spt_velocity_correlation';
    clear input_data v_corr
end
spt_velocity_correlation_plot(velocity_correlation)
end

function data_to_send = calculate_velocity_correlation(data)
x = data(:,2);
y = data(:,3);
t = data(:,1);
for i=1:length(t)-1
    v(i,1) = (x(i+1)-x(i))/(t(i+1)-t(i));
    v(i,2) = (y(i+1)-y(i))/(t(i+1)-t(i));
end
t = t(1:end-1);

v_mean = mean(sum(v.^2,2));

[T1,T2] = meshgrid(t,t);
[v_x_1,v_x_2] = meshgrid(v(:,1),v(:,1));
[v_y_1,v_y_2] = meshgrid(v(:,2),v(:,2));

delays = round(abs(T1-T2),12);
delays = triu(delays,1);
delays = reshape(delays,[1 length(t)*length(t)]);

dr = (v_x_1.*v_x_2+v_y_1.*v_y_2)/v_mean;
dr = triu(dr,1);
dr = reshape(dr,[1 length(t)*length(t)]);

delays_uique = unique(delays);
for i=1:length(delays_uique)
    vel_corr(i) = mean(dr(delays == delays_uique(i)));
end
data_to_send(:,1) = delays_uique;
data_to_send(:,2) = vel_corr;
end

function spt_velocity_correlation_plot(data)
figure()
set(gcf,'name','Particle Velocities Correlation','NumberTitle','off','color','w','units','normalized','position',[0.2 0.2 0.4 0.5],'menubar','none','toolbar','figure')

if length(data)>1
    slider_step_one=[1/(length(data)-1),1];
    slider_one = uicontrol('style','slider','units','normalized','position',[0,0,0.03,1],'value',1,'min',1,'max',length(data),'sliderstep',slider_step_one,'Callback',{@sld_one_callback});
end
slider_one_value=1;

if length(data{slider_one_value}.velocity_correlation)>1
    slider_step_two=[1/(length(data{slider_one_value}.velocity_correlation)-1),1];
    slider_two = uicontrol('style','slider','units','normalized','position',[0.03,0,0.03,1],'value',1,'min',1,'max',length(data{slider_one_value}.velocity_correlation),'sliderstep',slider_step_two,'Callback',{@sld_two_callback});
end
slider_two_value=1;

spt_velocity_histogram_inside(data,slider_one_value,slider_two_value)

uimenu('Text','Calculate Mean Velocity Correlation','ForegroundColor','k','CallBack',@mean_velocity);

    function sld_one_callback(~,~,~)
        slider_one_value = round(slider_one.Value);
        if length(data{slider_one_value}.velocity_correlation)>1
            slider_two.SliderStep = [1/(length(data{slider_one_value}.velocity_correlation)-1),1];
            slider_two.Max = length(data{slider_one_value}.velocity_correlation);
            slider_two.Min = 1;
            slider_two.Value = 1;
        end
        slider_two_value = 1;
        spt_velocity_histogram_inside(data,slider_one_value,slider_two_value)
    end

    function sld_two_callback(~,~,~)
        slider_two_value = round(slider_two.Value);
        spt_velocity_histogram_inside(data,slider_one_value,slider_two_value)
    end

    function mean_velocity(~,~,~)
        spt_compute_mean_velocity_correlation(data)
    end
end

function spt_velocity_histogram_inside(data,slider_one_value,slider_two_value)
input_data = data{slider_one_value}.velocity_correlation;
if isempty(input_data)~=1
    name = data{slider_one_value}.name;
    ax = gca; cla(ax);
    data_to_plot = input_data{slider_two_value};
    plot(data_to_plot(:,1),data_to_plot(:,2),'b')
    title({'',['file name: ',regexprep(name,'_',' ')],[num2str(slider_two_value),'/',num2str(length(input_data)),',   number of frames = ',num2str(size(data_to_plot,1))]},'interpreter','latex','fontsize',14)
    set(gca,'TickLength',[0.02 0.02],'FontName','TimesNewRoman','FontSize',12,'TickLabelInterpreter','latex')
    axtoolbar(gca,{'zoomin','zoomout','restoreview'});
    xlabel(['$v_{x} (blue), v_{y} (red)$','($um/s$)'],'interpreter','latex','FontSize',14)    
end
end