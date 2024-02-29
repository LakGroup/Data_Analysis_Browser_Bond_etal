function [classes,classes_grouped] = classify_clusters(classes,coefficient_of_variation,method)
if isequal(method,'linkage')
    parameters = classes(:,3);
    parameters = vertcat(parameters{:});
    normalized_parameters = zscore(parameters);
    [link,~,~] = shape_classification_finding_linkage(normalized_parameters);
    [complete_linkage,~] = find_complete_linkage(link,size(classes,1));
    to_group = find_groups(classes,parameters,complete_linkage,coefficient_of_variation);
    classes_grouped = group_classes(to_group,classes);
    classes(to_group,:) = [];
    %[classes,classes_grouped] = check_classes_in_bubble(classes,classes_grouped);
    %plot_classes_to_group(f,classes_grouped)
    %drawnow()
elseif isequal(method,'distance')
    parameters = classes(:,3);
    parameters = vertcat(parameters{:});
    normalized_parameters = zscore(parameters);
    distance = pdist2(normalized_parameters,normalized_parameters);
    nearest_neighbors = find_neigherst_negighbor(distance);
    to_group = find_groups(classes,parameters,nearest_neighbors,coefficient_of_variation);    
    classes_grouped = group_classes(to_group,classes);
    classes(to_group,:) = [];
    %[classes,classes_grouped] = check_classes_in_bubble(classes,classes_grouped);    
    %plot_classes_to_group(f,classes_grouped)
    %drawnow()
end
end

function nearest_neighbors = find_neigherst_negighbor(distance)
distance(distance==0) = Inf;
[M,ii] = min(distance);
[~,jj] = min(M);
M = M(jj);
ii = ii(jj);
distance = distance(ii,:);
[~,jj] = mink(distance,length(distance));
nearest_neighbors = [ii,jj];
end