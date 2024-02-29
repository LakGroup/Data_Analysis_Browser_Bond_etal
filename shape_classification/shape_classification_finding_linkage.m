function [link,distance,cophenet_value] = shape_classification_finding_linkage(parameters)
disp('Calculating Linkage')
distance = pdist(parameters);
link = linkage(distance,'average');
cophenet_value = cophenet(link,distance);
disp(['Cophenet Value = ',num2str(cophenet_value)]);
end