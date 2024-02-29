function [data_clustered,data_not_clustered] = loc_list_voronoi_monte_carlo(data)
answer = inputdlg({'Number of Iterations:','nm per Pixel:','Analysis Pixel Size:','MC Confidence Bounds:','Maximum Number of Thresholds:','Minimum number of Localizations per Cluster:'},'Input',[1 50],{'5','116','20','99.5','8','5'});
if isempty(answer)~=1
    iter = str2double(answer{1});
    signif = str2double(answer{4});
    pixVals(1) = str2double(answer{2});
    pixVals(2) = str2double(answer{3});
    maxloop = str2double(answer{5});
    min_number_of_localizations = str2double(answer{6});    
    for i = 1:length(data)
        counter(1) = i;
        counter(2) = length(data);
        [data_clustered,data_not_clustered] = voronoi_data_voronoi_monte_carlo_inside(data{i},iter,signif,pixVals,maxloop,min_number_of_localizations,counter);       
    end
else
    data_clustered = [];
    data_not_clustered = [];
end
end

function [data_clustered,data_not_clustered] = voronoi_data_voronoi_monte_carlo_inside(data,iter,signif,pixVals,maxloop,min_number_of_localizations,counter)
f = waitbar(0,['Please Wait..',num2str(counter(1)),'/',num2str(counter(2))]);
xy(:,1) = data.x_data;
xy(:,2) = data.y_data;
pix2nm = pixVals(1);
finalpix = pixVals(2);
waitbar(0.1,f,['Calculating Monte Carlo Histograms---',num2str(counter(1)),'/',num2str(counter(2))]);
[Histograms, ~, xy, ~, mask, ~, ~, ~, Varea_rnd] = VoronoiMonteCarlo_JO(xy,iter,signif,pixVals);
unithresh = 2*((finalpix/pix2nm)^2)*mask.Area/size(xy,1);
waitbar(0.3,f,['Calculating Monte Carlo Thresholds---',num2str(counter(1)),'/',num2str(counter(2))]);
Allthresholds = iterativeVoronoiSegmentation(xy,Varea_rnd,maxloop,signif,unithresh,0);
plotVoronoiMCdat(Histograms, Allthresholds(:,1), signif);
waitbar(0.6,f,['Constructing Voronoi Clusters---',num2str(counter(1)),'/',num2str(counter(2))]);
data_to_send.vor = loc_list_construct_voronoi_structure(xy(:,1),xy(:,2),[1,1]);
data_to_send.name = data.name;
data_to_send.type = 'voronoi_data';
for j = 1:size(Allthresholds,1)
    counter(1) = j;
    counter(2) = size(Allthresholds,1);    
    [data_clustered{j},data_not_clustered{j}] = construct_clusters(data_to_send,Allthresholds(j,1),min_number_of_localizations,1,counter);
end
data_clustered =  data_clustered(~cellfun('isempty',data_clustered));
data_not_clustered =  data_not_clustered(~cellfun('isempty',data_clustered));
waitbar(1,f,'Constructing Voronoi Clusters');
close(f)
end