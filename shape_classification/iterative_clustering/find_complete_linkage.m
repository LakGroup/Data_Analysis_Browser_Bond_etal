function [complete_linkage,complete_distances] = find_complete_linkage(link,no_of_files)
clear global complete_data complete_dist
global complete_data complete_dist
distances = link(:,3);
complete_distances = distances(1);
complete_distances(2) = complete_distances(1);
distances(1) = [];

link(:,3) = [];
link(:,3) = (no_of_files+1:no_of_files+size(link,1))';
complete_linkage = link(1,1:2);
link(1,:) = [];

to_look_function(link,no_of_files+1,no_of_files,distances);
complete_linkage = [complete_linkage, complete_data]; 
complete_distances = [complete_distances, complete_dist];
clear global complete_data complete_dist
end

function to_look_function(link,to_look,no_of_files,distances)
global complete_data complete_dist
[idx,~] = find(link==to_look);
complete_dist = [complete_dist,distances(idx)];
distances(idx) = [];
search_var = setdiff(link(idx,:),to_look);
link(idx,:) = [];
for i = 1:length(search_var)
    if search_var(i)<=no_of_files
        complete_data = [complete_data,search_var(i)];
    else
        to_look_function(link,search_var(i),no_of_files,distances);
    end
end
end