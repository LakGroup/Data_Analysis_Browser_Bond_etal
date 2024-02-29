function shape_classification_iterative_linkage_clustering(data)
coefficient_of_variation = shape_classification_iterative_clustering_input_coeff_var(data.classes);
if isempty(coefficient_of_variation)~=1
    [classes,size_classes] = shape_classification_iterative_clustering(data.classes,coefficient_of_variation,'linkage');
    data_classified.classes = classes;
    data_classified.name = [data.name,'iterative_clustering_linkage'];
    data_classified.type = 'shape_class';
    shape_classification_plot(data_classified)
    plot_size_clusters_iteraion(size_classes)   
end
end