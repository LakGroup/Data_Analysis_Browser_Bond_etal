function shape_classification_kmeans(data)
input_values = inputdlg({'k-means k value:'},'',1,{'10'});
if isempty(input_values)~=1
    parameters = shape_classification_normalized_parameters(data.classes);     
    kmeans_k = str2double(input_values{1});
    idx = kmeans(parameters,kmeans_k);
    classes = cluster_classes(idx,data.classes);
    
    mass = classes(:,3);
    mass = cell2mat(cellfun(@(x) x(1,1), mass,'UniformOutput',false));
    [~,I] = sort(mass);
    classes = classes(I,:);    
    
    data_to_send.classes = classes;
    data_to_send.name = [data.name,'_kmeans_',input_values{1}];
    data_to_send.type = 'shape_class';    
    shape_classification_plot(data_to_send)
end
end