function loc_list_save_nucleus(data)

[file,path] = uiputfile('NucleiCoords.xlsx','Please specify a name to save the coordinates as'); % Extract the name of the file given.
name = fullfile(path,file); % Make it a full name to save it as later.

% Delete the file if it exists. Avoid extra entries if the file already 
% existed before.
if exist(name,'file') == 2
    delete(name);
end

EmptyRow = cell(1,2);
EmptyRow(1:end) = {NaN};

for i = 1:length(data)

    if isfield(data{i},'coordinates')

        TableName = horzcat({data{i}.name},EmptyRow);

        for j = 1:numel(data{i}.coordinates)

            if exist('Table_coords','var') == 0
                Table_coords = [TableName; num2cell(repmat(j,[size(data{i}.coordinates{j},1) 1])) num2cell(data{i}.coordinates{j})];
            else
                if j == 1
                    Table_coords = [Table_coords; TableName; num2cell(repmat(j,[size(data{i}.coordinates{j},1) 1])) num2cell(data{i}.coordinates{j})];
                else
                    Table_coords = [Table_coords; num2cell(repmat(j,[size(data{i}.coordinates{j},1) 1])) num2cell(data{i}.coordinates{j})];
                end                    
            end
        end
    end
end

if exist('Table_coords','var') == 1
    Table_coords = cell2table(Table_coords); % Convert the cell to a table.
    Table_coords.Properties.VariableNames = {'Nucleus number','x_coordinate (pixels)','y_coordinates (pixels)'}; % Set the column variable names.
    writetable(Table_coords,name,'sheet','SummarySheet'); % Write the table to the Excel file, in a Summary sheet.
end
end