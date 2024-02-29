function loc_list_density_plot_delauny_triangulation(data)
answer = inputdlg({'Maximum Number of Localizations for Down Sampling'},'Input',1,{'1000'});
if isempty(answer)~=1    
    num_points = str2double(answer{1});
    f=waitbar(0,'Please wait...');
    for i=1:length(data)
        m = length(data{i}.x_data);
        data_sample(:,1) = data{i}.x_data;
        data_sample(:,2) = data{i}.y_data;
        if m>num_points
            data_sample = datasample(data_sample,num_points);
        end
        data_sample = unique(data_sample,'rows');
        if size(data_sample,1)>2
            [area_zeroth_rank,~] = delauny_triangulation_areas(data_sample(:,1),data_sample(:,2));
        else
            area_zeroth_rank = 0;
        end
        
        delauny_data{i}.x_data = data_sample(:,1);
        delauny_data{i}.y_data = data_sample(:,2);
        delauny_data{i}.name = [data{i}.name,'_density_plot_delauny_area'];        
        delauny_data{i}.color = area_zeroth_rank;
        delauny_data{i}.type = data{i}.type;
        clear data_sample area_zeroth_rank         
        waitbar(i/length(data),f,'Please wait...');       
    end
    close(f)
    loc_list_plot(delauny_data)
end
end

function [delauny_area_zeroth_rank,delauny_area_first_rank] = delauny_triangulation_areas(x,y)
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
delauny_area_zeroth_rank = delauny_area_zeroth_rank./(delauny_area_zeroth_rank+1);

% disp('calculating first rank areas')
% neighbors = cellfun(@(x) connectivity_list(x,:),attached_triangles,'UniformOutput',false);
% neighbors = cellfun(@(x) unique(x),neighbors,'uniformoutput',false);
% delauny_area_first_rank = cellfun(@(x) delauny_area_zeroth_rank(x),neighbors,'UniformOutput',false);
% delauny_area_first_rank = cellfun(@sum,delauny_area_first_rank);
delauny_area_first_rank = [];
end