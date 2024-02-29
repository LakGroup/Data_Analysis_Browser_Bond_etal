function data = spt_plot(data)
for i = 1:length(data)
    if isfield(data{i},'msd') ~= 1  
        f = waitbar(0,'calculating msd');
        for j = 1:length(data{i}.tracks)
            waitbar(j/length(data{i}.tracks),f,['calculating msd ',num2str(j),'/',num2str(length(data{i}.tracks))]);
            if size(data{i}.tracks{j},1)<3
                data{i}.tracks{j,1} = [];
                data{i}.msd{j,1} = [];
            else
                data{i}.msd{j,1} = compute_msd(data{i}.tracks{j});
            end
        end
        data{i}.msd = data{i}.msd(~cellfun('isempty',data{i}.msd));
        data{i}.tracks = data{i}.tracks(~cellfun('isempty',data{i}.tracks));   
        close(f)
    end
end

figure()
set(gcf,'name','Single Particle Tracking Analysis','NumberTitle','off','color','w','units','normalized','position',[0.15 0.2 0.7 0.6],'menubar','none','toolbar','figure')

if length(data)>1
    slider_step_one=[1/(length(data)-1),1/(length(data)-1)];
    slider_one = uicontrol('style','slider','units','normalized','position',[0,0,0.02,1],'value',1,'min',1,'max',length(data),'sliderstep',slider_step_one,'Callback',{@sld_one_callback});
end
slider_one_value=1;

if length(data{slider_one_value}.tracks)>1
    slider_step_two=[1/(length(data{slider_one_value}.tracks)-1),1/(length(data{slider_one_value}.tracks)-1)];
    slider_two = uicontrol('style','slider','units','normalized','position',[0.02,0,0.98,0.04],'value',1,'min',1,'max',length(data{slider_one_value}.tracks),'sliderstep',slider_step_two,'Callback',{@sld_two_callback});
end
slider_two_value=1;

try
    spt_plot_inside(data{slider_one_value}.tracks{slider_two_value},data{slider_one_value}.msd{slider_two_value},slider_two_value,length(data{slider_one_value}.tracks),data{slider_one_value}.name)
end

    function sld_one_callback(~,~,~)
        slider_one_value = round(slider_one.Value);
        if length(data{slider_one_value}.tracks)>1
            slider_two.SliderStep = [1/(length(data{slider_one_value}.tracks)-1),1/(length(data{slider_one_value}.tracks)-1)];
            slider_two.Max = length(data{slider_one_value}.tracks);
            slider_two.Min = 1;
            slider_two.Value = 1;
        end
        slider_two_value = 1;       
        spt_plot_inside(data{slider_one_value}.tracks{slider_two_value},data{slider_one_value}.msd{slider_two_value},slider_two_value,length(data{slider_one_value}.tracks),data{slider_one_value}.name)
    end

    function sld_two_callback(~,~,~)
        slider_two_value = round(slider_two.Value);        
        spt_plot_inside(data{slider_one_value}.tracks{slider_two_value},data{slider_one_value}.msd{slider_two_value},slider_two_value,length(data{slider_one_value}.tracks),data{slider_one_value}.name)
    end

file_menu=uimenu('Text','File');
uimenu(file_menu,'Text','Send Data to Workspace','ForegroundColor','k','CallBack',@send_data);

basic_analysis_menu=uimenu('Text','Basic Analysis');
uimenu(basic_analysis_menu,'Text','Convert Tracks to Image','ForegroundColor','k','CallBack',@convert_tracks_to_image);
uimenu(basic_analysis_menu,'Text','Tracks Number of Frames Histogram','ForegroundColor','k','CallBack',@tracks_number_of_frames_histogram_callback);
uimenu(basic_analysis_menu,'Text','Tracks Total Distance Traveled Histogram','ForegroundColor','k','CallBack',@tracks_total_distance_traveled_callback);
uimenu(basic_analysis_menu,'Text','Tracks LastFrame-FirstFrame Distance Traveled Histogram','ForegroundColor','k','CallBack',@tracks_last_first_distance_traveled_callback);
uimenu(basic_analysis_menu,'Text','Tracks Maximum Distance Traveled Histogram','ForegroundColor','k','CallBack',@tracks_maximum_distance_traveled_callback);
uimenu(basic_analysis_menu,'Text','Filter Tracks (No. of Frames)','ForegroundColor','k','CallBack',@filter_tracks_callback);
uimenu(basic_analysis_menu,'Text','Combine All Tracks','ForegroundColor','k','CallBack',@combine_tracks_callback);
uimenu(basic_analysis_menu,'Text','Calculate Particles Velocities','ForegroundColor','k','CallBack',@particle_velocity_callback);
uimenu(basic_analysis_menu,'Text','Calculate Particles Velocities Correlation','ForegroundColor','k','CallBack',@particle_velocity_correlation_callback);

msd_analysis_menu=uimenu('Text','MSD Analysis');
uimenu(msd_analysis_menu,'Text','Recalculate MSD','ForegroundColor','k','CallBack',@recalculate_msd_callback);
uimenu(msd_analysis_menu,'Text','Mean MSD','ForegroundColor','k','CallBack',@mean_msd_callback);
uimenu(msd_analysis_menu,'Text','MSD Log-Log Plot','ForegroundColor','k','CallBack',@msd_log_log_plot_callback);
uimenu(msd_analysis_menu,'Text','MSD Linear Fit','ForegroundColor','k','CallBack',@msd_linear_fit_callback);
uimenu(msd_analysis_menu,'Text','MSD Linear Fit - Points','ForegroundColor','k','CallBack',@msd_linear_fit_points_callback);
uimenu(msd_analysis_menu,'Text','MSD Parabolic Fit','ForegroundColor','k','CallBack',@msd_parabolic_fit_callback);
uimenu(msd_analysis_menu,'Text','Motion Classification (Log-Log Linear Fit) - Percentage','ForegroundColor','k','CallBack',@motion_classification_callback);
uimenu(msd_analysis_menu,'Text','Motion Classification (Based on Total Distance)','ForegroundColor','k','CallBack',@motion_classification__distance_callback);
uimenu(msd_analysis_menu,'Text','Motion Classification (Butterfly Trajectories)','ForegroundColor','k','CallBack',@motion_classification_butterfly_callback);

spot_on_menu=uimenu('Text','Spot-On');
uimenu(spot_on_menu,'Text','Displacement Histogram','ForegroundColor','k','CallBack',@tracks_displacement_histogram_callback);

plot_menu=uimenu('Text','Plot');
uimenu(plot_menu,'Text','Plot All Tracks','ForegroundColor','k','CallBack',@plot_all_tracks_callback);
uimenu(plot_menu,'Text','Tracks Video','ForegroundColor','k','CallBack',@plot_video_callback);

    function send_data(~,~)
        spt_send_data_to_workspace(data)
    end

    function plot_all_tracks_callback(~,~,~)
        spt_plot_all_tracks(data)
    end

    function plot_video_callback(~,~,~)
        spt_video_plot(data)
    end

    function tracks_number_of_frames_histogram_callback(~,~,~)
        spt_tracks_number_of_frames_histogram(data)
    end

    function convert_tracks_to_image(~,~,~)
        spt_tracks_convert_tracks_to_image(data)
    end

    function tracks_total_distance_traveled_callback(~,~,~)
        spt_tracks_total_distance_traveled_callback(data)
    end

    function tracks_last_first_distance_traveled_callback(~,~,~)
        spt_tracks_last_first_distance_traveled_callback(data)
    end

    function tracks_maximum_distance_traveled_callback(~,~,~)
        spt_tracks_maximum_distance_traveled_callback(data)
    end

    function filter_tracks_callback(~,~,~)
        spt_filter_tracks(data)
    end

    function combine_tracks_callback(~,~,~)
        spt_combine_tracks(data)
    end

    function particle_velocity_callback(~,~)
        spt_particles_velocity(data)
    end
    function particle_velocity_correlation_callback(~,~)
        spt_particles_velocity_correlation(data)
    end

    function recalculate_msd_callback(~,~)
        for n = 1:length(data)
            f = waitbar(0,'Calculating MSD');
            for m = 1:length(data{n}.tracks)
                data{n}.msd{m,1} = compute_msd(data{n}.tracks{m});
            end
            close(f)
        end
        spt_plot(data);
    end

    function mean_msd_callback(~,~)
        spt_compute_mean_msd(data)
    end

    function msd_log_log_plot_callback(~,~)
        spt_log_log_plot(data)
    end

    function msd_linear_fit_callback(~,~)
        spt_linear_fit(data)
    end

    function msd_linear_fit_points_callback(~,~)
        spt_linear_points_fit(data)
    end

    function msd_parabolic_fit_callback(~,~)
        spt_parabolic_fit(data)
    end

    function motion_classification_callback(~,~)
        spt_motion_classification(data)
    end

    function motion_classification__distance_callback(~,~)
        spt_motion_classification__distance_callback(data)
    end

    function motion_classification_butterfly_callback(~,~)
        spt_motion_classification_butterfly(data)
    end

    function tracks_displacement_histogram_callback(~,~,~)
        spt_tracks_displacement_histogram(data)
    end
end

function spt_plot_inside(track_data,msd_data,track_number,number_of_frames,name)
if isempty(track_data)~=1 
    subplot(1,2,1)
    ax = gca;cla(ax);
    plot(track_data(:,2),track_data(:,3),'b','linewidth',1)
    hold on
    scatter(track_data(1,2),track_data(1,3),30,'r','filled')
    title({'',['File Name = ',regexprep(name,'_',' ')],['Number of Tracks = ',num2str(track_number),'/',num2str(number_of_frames)],['Number of Frames = ',num2str(size(track_data,1))]},'interpreter','latex','fontsize',14)
    %set(gca,'TickLength',[0.02 0.02],'FontName','TimesNewRoman','FontSize',12,'TickLabelInterpreter','latex')    
    xlabel('X','interpreter','latex','fontsize',14)
    ylabel('Y','interpreter','latex','fontsize',14)   
    pbaspect([1 1 1])
    
    subplot(1,2,2)
    ax = gca;cla(ax);    
    plot(msd_data(:,1),msd_data(:,2),'k','linewidth',1)
    %set(gca,'TickLength',[0.02 0.02],'FontName','TimesNewRoman','FontSize',12,'TickLabelInterpreter','latex')
    xlabel('Delays (s)','interpreter','latex','FontSize',14)
    ylabel('MSD (µm²)','interpreter','latex','FontSize',14)
    title({'',['Number of Delays = ',num2str(size(msd_data,1))]},'interpreter','latex','fontsize',14)
    pbaspect([1 1 1])
end
end

function data_to_send = compute_msd(data)
t = data(:,1);
x = data(:,2);
y = data(:,3);
[T1,T2] = meshgrid(t,t);
[x1,x2] = meshgrid(x,x);
[y1,y2] = meshgrid(y,y);

delays = round(abs(T1-T2),12);
delays = triu(delays,1);
delays = reshape(delays,[1 length(t)*length(t)]);

dr = (x1-x2).^2+(y1-y2).^2;
dr = triu(dr,1);
dr = reshape(dr,[1 length(t)*length(t)]);

delays_uique = unique(delays);
for i=1:length(delays_uique)
    msd(i) = mean(dr(delays == delays_uique(i)));
end
data_to_send(:,1) = delays_uique;
data_to_send(:,2) = msd;
end