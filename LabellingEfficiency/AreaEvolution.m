function Area = AreaEvolution(Data,StepSize,maxFrame)

oldCritAlpha = Inf;

% Calculate the area for each stepsize
Area = zeros(ceil(maxFrame/StepSize),1);
for i = 1:ceil(maxFrame/StepSize)

    % Extract the localizations for each iteration
    xlocs = Data(Data(:,1) <= min(Data(:,1)) + i*StepSize,2);
    ylocs = Data(Data(:,1) <= min(Data(:,1)) + i*StepSize,3);

    % Try making an alphaShape of the data, but if there are too few
    % points, then the area will just be set to 0.
    try
        % Transform the data into an alphashape.
        ClusterShp = alphaShape(xlocs,ylocs);

        % Determine what the critical alpha is to make the data a single region,
        % and change it in case it is higher than the default one.
        CritAlpha = criticalAlpha(ClusterShp,'one-region');

        if CritAlpha > oldCritAlpha
            CritAlpha = oldCritAlpha;
        end

        % Set the proper alpha value.
        ClusterShp.Alpha = CritAlpha;
        Area(i) = area(ClusterShp);
    catch
        Area(i) = 0;
    end

    oldCritAlpha = CritAlpha;
    
end

end