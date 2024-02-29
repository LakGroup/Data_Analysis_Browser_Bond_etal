function spt_combine_tracks(data)
for i = 1:length(data)
    to_combine_tracks{i,1} = data{i}.tracks;
    to_combine_msd{i,1} = data{i}.msd;    
end
to_combine_tracks = vertcat(to_combine_tracks{:});
to_combine_msd = vertcat(to_combine_msd{:});
data_combined{1}.tracks = to_combine_tracks;
data_combined{1}.msd = to_combine_msd;
data_combined{1}.name = 'combined_tracks';
data_combined{1}.type = 'spt';
spt_plot(data_combined);
end