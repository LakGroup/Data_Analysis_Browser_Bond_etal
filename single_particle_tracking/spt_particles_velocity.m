function spt_particles_velocity(data)
for i=1:length(data)
    input_data = data{i}.tracks;
    for k = 1:length(input_data)
        v{k} = calculate_velocity(input_data{k});
    end
    velocity{i}.velocity = v;
    velocity{i}.name = data{i}.name;
    velocity{i}.type = 'spt_velocity';
    clear input_data v
end
spt_velocity_histogram(velocity)
end

function v = calculate_velocity(data)
x = data(:,2);
y = data(:,3);
t = data(:,1);
for i=1:length(t)-1
    v(i,1) = (x(i+1)-x(i))/(t(i+1)-t(i));
    v(i,2) = (y(i+1)-y(i))/(t(i+1)-t(i));
end
end

function spt_velocity_histogram(data)
input_values = inputdlg({'Frame interval (s):'},'',1,{'0.05'});
if isempty(input_values)==1
    return
else
    dT=str2double(input_values{1}); 
end

figure()
set(gcf,'name','Single Particle Velocities Histogram','NumberTitle','off','color','w','units','normalized','position',[0.2 0.2 0.7 0.5],'menubar','none','toolbar','figure')

if length(data)>1
    slider_step_one=[1/(length(data)-1),1];
    slider_one = uicontrol('style','slider','units','normalized','position',[0,0,0.02,1],'value',1,'min',1,'max',length(data),'sliderstep',slider_step_one,'Callback',{@sld_one_callback});
end
slider_one_value=1;

if length(data{slider_one_value}.velocity)>1
    slider_step_two=[1/(length(data{slider_one_value}.velocity)-1),1];
    slider_two = uicontrol('style','slider','units','normalized','position',[0.02,0,0.02,1],'value',1,'min',1,'max',length(data{slider_one_value}.velocity),'sliderstep',slider_step_two,'Callback',{@sld_two_callback});
end
slider_two_value=1;

for i=1:length(data)
    input_data = data{i}.velocity;
    input_data = vertcat(input_data{:});
    diff_est(i,1) = mean(var(input_data)) / 2 * dT;
    clear input_data
end

spt_velocity_histogram_inside(data,slider_one_value,slider_two_value,diff_est)

    function sld_one_callback(~,~,~)
        slider_one_value = round(slider_one.Value);
        if length(data{slider_one_value}.velocity)>1
            slider_two.SliderStep = [1/(length(data{slider_one_value}.velocity)-1),1];
            slider_two.Max = length(data{slider_one_value}.velocity);
            slider_two.Min = 1;
            slider_two.Value = 1;
        end
        slider_two_value = 1;
        spt_velocity_histogram_inside(data,slider_one_value,slider_two_value,diff_est)
    end

    function sld_two_callback(~,~,~)
        slider_two_value = round(slider_two.Value);
        spt_velocity_histogram_inside(data,slider_one_value,slider_two_value,diff_est)
    end
end

function spt_velocity_histogram_inside(data,slider_one_value,slider_two_value,diff_est)
input_data = data{slider_one_value}.velocity;
if isempty(input_data)~=1
    name = data{slider_one_value}.name;
    
    subplot(1,2,1)
    ax = gca; cla(ax);
    data_to_plot = input_data{slider_two_value};
    histogram(data_to_plot(:,1),50,'facecolor','b')
    hold on
    histogram(data_to_plot(:,2),50,'facecolor','r')
    title({'',['file name: ',regexprep(name,'_',' ')],[num2str(slider_two_value),'/',num2str(length(input_data))],['Diffusion Coefficient Esmitation=',num2str(diff_est(slider_one_value))]},'interpreter','latex','fontsize',14)
    set(gca,'TickLength',[0.02 0.02],'FontName','TimesNewRoman','FontSize',12,'TickLabelInterpreter','latex')
    axtoolbar(gca,{'zoomin','zoomout','restoreview'});
    xlabel(['$v_{x} (blue), v_{y} (red)$','($um/s$)'],'interpreter','latex','FontSize',14)    

    subplot(1,2,2)
    ax = gca; cla(ax);
    data_to_plot = input_data{slider_two_value};
    histogram(sqrt(data_to_plot(:,1).^2+data_to_plot(:,2).^2),50,'facecolor','g')
    set(gca,'TickLength',[0.02 0.02],'FontName','TimesNewRoman','FontSize',12,'TickLabelInterpreter','latex')
    axtoolbar(gca,{'zoomin','zoomout','restoreview'});
    xlabel(['$\sqrt{v_{x}{^2}+ v_{y}{^2}}$','($um/s$)'],'interpreter','latex','FontSize',14) 
end
end