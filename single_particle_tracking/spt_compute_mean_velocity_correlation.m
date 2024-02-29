function spt_compute_mean_velocity_correlation(data)
f = waitbar(0,'calculating mean msd');
for i=1:length(data)
    mean_velocity_correlation{1} = calculate_mean_velocity_correlation(data{i}.velocity_correlation);
    data_to_send{i}.velocity_correlation = mean_velocity_correlation;
    data_to_send{i}.name = [data{i}.name,'_mean_velocity_correlation'];
    data_to_send{i}.type = 'msd';
    waitbar(1,f,'calculating mean msd')
    clear mean_velocity_correlation
end
close(f)
spt_velocity_correlation_plot(data_to_send)
end

function mean_velocity_correlation = calculate_mean_velocity_correlation(data)
for i=1:length(data)
    time{i} = data{i}(:,1);
    corr{i} = data{i}(:,2);   
end
time = vertcat(time{:});
corr = vertcat(corr{:});

time_unique = unique(time);
for i=1:length(time_unique)
    wanted = corr(time == time_unique(i));    
    mean_corr(i) = mean(wanted);    
    clear wanted
end
mean_velocity_correlation(:,1) = time_unique;
mean_velocity_correlation(:,2) = mean_corr';
end