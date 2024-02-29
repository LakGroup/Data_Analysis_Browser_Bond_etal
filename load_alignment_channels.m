function data_aligned = load_alignment_channels(data)

[file,path] = uigetfile('*.xlsx','Load the alignment details.');
data_aligned = data;

if isempty(file)
    disp('no files were selected');
else

    DriftMatrix = table2array(readtable(fullfile(path,file),'VariableNamingRule','preserve'));

    if size(DriftMatrix) ~= numel(data)
        disp("The channel alignment matrix and the data do not have the same size.")
    else

        for i = 1:numel(data)
            data_aligned{i}.x_data = data_aligned{i}.x_data - DriftMatrix(i,1);
            data_aligned{i}.y_data = data_aligned{i}.y_data - DriftMatrix(i,2);
            data_aligned{i}.name = [data{i}.name '_Aligned'];
        end

    end

end
end