function spt_simulate_brownian_motion()
global stop_simulation_val diffusion_coefficient_val num_of_particles_val data listbox

index = listdlg('ListString',{'Simulate Random Brownian Motion','Simulate Directed Brownian Motion','Simulate Confined Brownian Motion'},'SelectionMode','single','ListSize',[400 300] );
if isempty(index)~=1
    
    if index == 1        
        input_values = inputdlg({'time_step:','motion size:'},'',1,{'0.015','1'});
        if isempty(input_values)==1
            return
        else
            dt = str2double(input_values{1});
            size_motion = str2double(input_values{2});  
            vm = 0;
            Ltrap = Inf;
            name_simulation = 'Random Brownian Motion';
        end
    end
    
    if index == 2
        input_values = inputdlg({'time_step:','motion size:','mean velocity'},'',1,{'0.015','1','0.05'});
        if isempty(input_values)==1
            return
        else
            dt = str2double(input_values{1});
            size_motion = str2double(input_values{2});
            vm = str2double(input_values{3});
            Ltrap = Inf;
            name_simulation = 'Directed Brownian Motion';
        end
    end    
    
    if index == 3
        input_values = inputdlg({'time_step:','motion size:','trap diameter'},'',1,{'0.015','5','0.05'});
        if isempty(input_values)==1
            return
        else
            dt = str2double(input_values{1});
            size_motion = str2double(input_values{2});
            vm = 0;
            Ltrap = str2double(input_values{3});
            name_simulation = 'Confined Brownian Motion';
        end
    end
    
    figure()
    set(gcf,'name','Brownian Motion Simulation','NumberTitle','off','color','w','units','normalized','position',[0.3 0.2 0.4 0.6],'menubar','none','toolbar','none')
    
    uicontrol('style','text','units','normalized','position',[0,0.95,0.3,0.05],'string','Number of Particles','BackgroundColor','w','Fontsize',12);
    num_of_particles = uicontrol('style','edit','units','normalized','position',[0,0.9,0.3,0.05],'string','50','BackgroundColor','w','Fontsize',12,'callback',{@num_part_callback});
    
    uicontrol('style','text','units','normalized','position',[0.3,0.95,0.3,0.05],'string','Diffusion Coefficient','BackgroundColor','w','Fontsize',12);
    diffusion_coefficient = uicontrol('style','slider','units','normalized','position',[0.3,0.9,0.3,0.05],'Min',0,'Max',1,'Value',0.001,'sliderste',[1/(1000-1),1],'callback',{@slider_callback});
    
    start = uicontrol('style','pushbutton','units','normalized','position',[0.6,0.9,0.4,0.05],'string','Start Simulation','BackgroundColor','w','Fontsize',12,'callback',{@start_simulation});
    stop = uicontrol('style','pushbutton','units','normalized','position',[-0.6,0.9,0.4,0.05],'string','Stop Simulation','BackgroundColor','w','Fontsize',12,'callback',{@stop_simulation});
    send = uicontrol('style','pushbutton','units','normalized','position',[-0.8,0.9,0.2,0.05],'string','Send Data','BackgroundColor','w','Fontsize',12,'callback',{@send_data});
    
    dim = 2;
    stop_simulation_val = 1;
    num_of_particles_val = str2double(num_of_particles.String);
    diffusion_coefficient_val = diffusion_coefficient.Value;
    
    X0 = size_motion*rand(num_of_particles_val, dim)-size_motion/2;    
    
    theta =  2*pi*rand(num_of_particles_val,1);
    dX_directed = vm * (1 + 1/4*randn)*dt*[cos(theta) sin(theta)];
    
    Fx = @(x) - (diffusion_coefficient_val / Ltrap^2) * (x - X0);
    
    temp = X0-X0;
    tracks_x = temp(:,1);
    tracks_y = temp(:,1);
    t = -dt;
end

    function start_simulation(~,~,~)
        stop_simulation_val = 0;
        start.Position = [-0.6,0.9,0.4,0.05];
        stop.Position = [0.6,0.9,0.4,0.05];
        send.Position = [-0.8,0.85,0.2,0.05];
        i = 0;                
        while stop_simulation_val~=1
            i = i+1;
            t = t+dt;
            k = sqrt(2*diffusion_coefficient_val*dt);                       
            dX = k * randn(num_of_particles_val, dim);     
            dX_trap = - Fx(X0)*dt; 
            X0 = X0+dX+dX_directed-dX_trap;
            ax = gca; cla(ax);
            scatter(X0(:,1),X0(:,2),10,'b','filled')
            set(gca,'TickLength',[0.02 0.02],'FontName','TimesNewRoman','FontSize',12,'TickLabelInterpreter','latex','box','on','units','normalized','Position',[0.11 0.1 0.8 0.7])
            axis equal
            title({['diffusion coefficient = ',num2str(diffusion_coefficient_val)],['t=',num2str(t)]},'interpreter','latex','fontsize',14)
            xlim([-2*size_motion 2*size_motion])
            ylim([-2*size_motion 2*size_motion])
            drawnow            
            tracks_x = [tracks_x,X0(:,1)];
            tracks_y = [tracks_y,X0(:,2)];
        end
    end

    function slider_callback(~,~,~)
        diffusion_coefficient_val = diffusion_coefficient.Value;
        title(['diffusion coefficient = ',num2str(diffusion_coefficient_val)],'interpreter','latex','fontsize',14)
        set(gca,'TickLength',[0.02 0.02],'FontName','TimesNewRoman','FontSize',12,'TickLabelInterpreter','latex','box','on','units','normalized','Position',[0.11 0.1 0.8 0.7])
        axis equal
        xlim([-2*size_motion 2*size_motion])
        ylim([-2*size_motion 2*size_motion])
    end

    function num_part_callback(~,~,~)
        num_of_particles_val = str2double(num_of_particles.String);
        X0 = size_motion*rand(num_of_particles_val, dim)-size_motion/2;    
        theta =  2*pi*rand(num_of_particles_val,1);
        dX_directed = vm * (1 + 1/4*randn)*dt*[cos(theta) sin(theta)];        
        Fx = @(x) - (diffusion_coefficient_val / Ltrap^2) * (x - X0); 
        temp = X0-X0;
        tracks_x = temp(:,1);
        tracks_y = temp(:,1);
    end

    function stop_simulation(~,~,~)
        stop_simulation_val = 1;
        start.Position = [0.6,0.9,0.4,0.05];
        stop.Position = [-0.6,0.9,0.4,0.05];
        send.Position = [0.8,0.85,0.2,0.05];
    end

    function send_data(~,~,~)
        tracks_x = tracks_x(:,2:end);
        tracks_y = tracks_y(:,2:end);
        time = 0:dt:0+(size(tracks_x,2)-1)*dt';
        for i=1:num_of_particles_val
            tracks{i,1}(:,1) = time;
            tracks{i,1}(:,2) =  tracks_x(i,:)';
            tracks{i,1}(:,3) =  tracks_y(i,:)';
        end
        data_to_send{1}.tracks = tracks;
        data_to_send{1}.name = name_simulation;  
        data_to_send{1}.type = 'spt';        
        if isempty(data)==1
            data=data_to_send;
        else
            data= horzcat(data,data_to_send);
        end
        listbox = set_listbox_names(listbox);
    end
end

function listbox = set_listbox_names(listbox)
global data
if isempty(data)==1
    listbox.String = 'NaN';
else
    for i=1:size(data,2)
        names{i} = data{i}.name;
    end
    listbox.String = names;
end
end