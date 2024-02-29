function loc_list_delauny_segmentation(data)
answer = inputdlg({'maximum number of localizations for down sampling'},'Input',1,{'1000'});
if isempty(answer)~=1    
    num_points = str2double(answer{1});    
    for i=1:length(data)
        m = length(data{i}.x_data);
        data_sample(:,1) = data{i}.x_data;
        data_sample(:,2) = data{i}.y_data;
        if m>num_points
            data_sample = datasample(data_sample,num_points);
        end
        data_sample = unique(data_sample,'rows');
        if size(data_sample,1)>2
            [delauny_area_zeroth_rank,delauny_area_first_rank,neighbors] = delauny_triangulation_areas(data_sample(:,1),data_sample(:,2));
            [cluster, fig_h, xy, areaThresh, repidx] = clusterVoronoi(data_sample,0.01,[],5,[],true);
        end
    end
end
end

function [delauny_area_zeroth_rank,delauny_area_first_rank,neighbors] = delauny_triangulation_areas(x,y)
disp('calculating delauny triangulation')
delauny_triangulation = delaunayTriangulation(x,y);
connectivity_list = delauny_triangulation.ConnectivityList;
attached_triangles = vertexAttachments(delauny_triangulation);

disp('calculating delauny areas')
xx = x(connectivity_list)';
yy = y(connectivity_list)';
delauny_area = abs(sum( (xx([2:end 1],:) - xx).*(yy([2:end 1],:) + yy))*0.5);

disp('calculating zeroth rank areas')
delauny_area_zeroth_rank = cellfun(@(x) delauny_area(x),attached_triangles,'UniformOutput',false);
delauny_area_zeroth_rank = cellfun(@sum,delauny_area_zeroth_rank);

disp('calculating first rank areas')
neighbors = cellfun(@(x) connectivity_list(x,:),attached_triangles,'UniformOutput',false);
neighbors = cellfun(@(x) unique(x),neighbors,'uniformoutput',false);
delauny_area_first_rank = cellfun(@(x) delauny_area_zeroth_rank(x),neighbors,'UniformOutput',false);
delauny_area_first_rank = cellfun(@sum,delauny_area_first_rank);
end