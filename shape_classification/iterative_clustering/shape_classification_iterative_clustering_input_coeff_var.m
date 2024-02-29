function coefficient_of_variation = shape_classification_iterative_clustering_input_coeff_var(classes)
input_values = inputdlg({'Lengh Coeff. of Variation Threshold:','Width Coeff. of Variation Threshold:'},'',1,{'0.15','0.15'});
if isempty(input_values)~=1
    size_c_o_v = size(classes{1,3},2);
    coefficient_of_variation = Inf*ones(1,size_c_o_v);    
    coefficient_of_variation(7)  = str2double(input_values{1});
    coefficient_of_variation(8)  = str2double(input_values{2});
else
    coefficient_of_variation = [];
end
end