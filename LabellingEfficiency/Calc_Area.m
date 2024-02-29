function Area = Calc_Area(data)

% Transform the data into an alphashape
ClusterShp = alphaShape(data(:,1),data(:,2));

% Determine what the critical alpha is to make the data a single region,
% and change it in case it is higher than the default one.
CritAlpha = criticalAlpha(ClusterShp,'one-region');
if CritAlpha > ClusterShp.Alpha
    ClusterShp.Alpha = CritAlpha;
end

% Calculate the area of the cluster using the alphashape calculation (very
% accurate).
Area = area(ClusterShp);

end