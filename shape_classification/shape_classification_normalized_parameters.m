function parameters = shape_classification_normalized_parameters(classes)
parameters = classes(:,3);
parameters = vertcat(parameters{:});
parameters = zscore(parameters);
end