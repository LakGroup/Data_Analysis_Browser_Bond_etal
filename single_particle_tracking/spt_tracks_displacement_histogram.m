function spt_tracks_displacement_histogram(data)
input_values = inputdlg({'Frame Intervsl (s):','Use Entire Trajectory (0 or 1):','Gaps Allowed (0,1 or 2):','Number of Delays:','Jumps to Consider:','Bin Width','Maximum Jump:','dZ'},'',1,{'0.0075','0','1','8','4','0.01','5.05','0.7'});
if isempty(input_values)==1
    return
else
    Frame_Interval = str2double(input_values{1}); %Exposure time in seconds
    UseEntireTraj = str2double(input_values{2}); % If UseEntireTraj=1, all dispplacements from all trajectories will be used; If UseEntireTraj=0, only the first X displacements will be used.
    GapsAllowed = str2double(input_values{3}); % The number of allowed gaps in the tracking
    TimePoints = str2double(input_values{4})+1; % How many delays to consider: N timepoints yield N-1 delays
    JumpsToConsider = str2double(input_values{5}); % If UseEntireTraj=0, the first JumpsToConsiders displacements for each dT where possible will be used.
    BinWidth = str2double(input_values{6}); % Bin Width for computing histogram in micrometers (only for PDF; Spot-On uses 1 nm bins for CDF)
    MaxJump = str2double(input_values{7}); % the overall maximal displacements to consider in micrometers    
    HistVecJumps = 0:BinWidth:MaxJump; % histogram/PDF displacement bins in micrometers
    HistVecJumpsCDF = 0:0.001:MaxJump; % CDF displacement bins in micrometers
    dZ = str2double(input_values{8}); % The axial observation slice in micrometers; Rougly 0.7 um for the example data (HiLo)
    dT = Frame_Interval;
    [Z_corr_a, Z_corr_b] = MatchZ_corr_coeff(dT, dZ, GapsAllowed);
        f = waitbar(0,'Calculating');
    for i = 1:length(data)      
        data_struct.dT = dT;        
        data_struct.dZ = dZ;
        data_struct.UseEntireTraj = UseEntireTraj;
        data_struct.GapsAllowed = GapsAllowed;
        data_struct.TimePoints = TimePoints;
        data_struct.JumpsToConsider = JumpsToConsider;
        data_struct.BinWidth = BinWidth;
        data_struct.MaxJump = MaxJump;
        data_struct.HistVecJumps = HistVecJumps;
        data_struct.HistVecJumpsCDF = HistVecJumpsCDF;         
        data_struct.trackedPar = convert_tracks_to_SpotOn(data{i}.tracks,Frame_Interval);  
        data_struct.Z_corr_a = Z_corr_a; 
        data_struct.Z_corr_b = Z_corr_b;
        data_struct.name = data{i}.name;
        data_struct = compile_histograms_single_cell(data_struct);
        data_to_send{i} = data_struct;        
        clear data_struct
        waitbar(i/length(data),f,'Calculating');
    end
    close(f)
    spt_tracks_displacement_histogram_plot(data_to_send);
end
end

function trackedPar = convert_tracks_to_SpotOn(trajectory,Frame_interval)
for n=1:length(trajectory)
    trackedPar(n).xy = trajectory{n}(:,2:3);
    trackedPar(n).Frame = round((trajectory{n}(:,1) + Frame_interval)/Frame_interval);
    trackedPar(n).TimeStamp = trajectory{n}(:,1)+Frame_interval;
end
end