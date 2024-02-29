function data_aligned = do_alignment_channels(data)

finish = false;
set(gcf,'CurrentCharacter','@'); % set to a dummy character
Counter = 1;
while ~finish

    title(['Please select bead ' num2str(Counter) '. Press ''Q'' to stop, or any other key to select more beads.'],'Color','w');
       
    zoom on
    pause()
    zoom off
    Axis(Counter,:) = axis;
    Counter = Counter + 1;
    % check for keys
    k=get(gcf,'CurrentCharacter');
    if k~='@' % has it changed from the dummy character?
        set(gcf,'CurrentCharacter','@'); % reset the character
        % now process the key as required
        if k=='q', finish=true; end
    end
    zoom out
end

CoordsData = cell(size(Axis,1),1);
for i = 1:numel(data)

    for j = 1:size(Axis,1)
        BoundingboxCoords = [Axis(j,1) Axis(j,3);Axis(j,2) Axis(j,3);Axis(j,2) Axis(j,4);Axis(j,1) Axis(j,4)];
        insideBoundingBox = inpolygon(data{i}.x_data,data{i}.y_data,BoundingboxCoords(:,1),BoundingboxCoords(:,2));
        subsetData = [data{i}.x_data(insideBoundingBox) data{i}.y_data(insideBoundingBox)];

        if size(subsetData,1) > 50
            CoordsData{j}(i,:) = mean(subsetData);
        else
            CoordsData{j}(i,:) = nan(2,1);
        end
    end
end
CoordsData = cellfun(@(x) x - repmat(x(1,:), [numel(data) 1]),CoordsData,'UniformOutput',false);

DriftMatrix = nan(numel(data),2,numel(CoordsData));
for i = 1:numel(CoordsData)
    DriftMatrix(:,:,i) = cell2mat(CoordsData(i));
end
DriftMatrix = mean(DriftMatrix,3,'omitnan');

data_aligned = data;
for i = 1:numel(data)
    data_aligned{i}.x_data = data_aligned{i}.x_data - DriftMatrix(i,1);
    data_aligned{i}.y_data = data_aligned{i}.y_data - DriftMatrix(i,2);
    data_aligned{i}.name = [data{i}.name '_Aligned'];
    data_aligned{i}.DriftMatrix = DriftMatrix;
end
writematrix(DriftMatrix,'alignment.xlsx');

end