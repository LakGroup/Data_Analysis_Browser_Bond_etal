function shape_classification_iterative_linkage_coeff_var_clustering(data)
input_values = inputdlg({'Length and Width Coeff. of Variation Threshold Variation:'},'',1,{'0.05:0.01:0.17'});
if isempty(input_values)~=1
    coeff_var = eval(input_values{1});
    size_c_o_v = size(data.classes{1,3},2);
    coefficient_of_variation = Inf*ones(1,size_c_o_v);
    classes = data.classes; 
    for i = 1:length(coeff_var)        
        coefficient_of_variation(7)  = coeff_var(i);
        coefficient_of_variation(8)  = coeff_var(i);
        [classes,size_classes{i}] = shape_classification_iterative_clustering(classes,coefficient_of_variation,'linkage');
    end
    size_classes = horzcat(size_classes{:});   
    data_classified.classes = classes;
    data_classified.name = [data.name,'iterative_clustering_distance_coeff_var'];
    data_classified.type = 'shape_class';   
    shape_classification_plot(data_classified)
    plot_size_clusters_iteraion(size_classes)          
end
end