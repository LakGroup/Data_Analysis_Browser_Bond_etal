function shape_classification_iterative_pairwise_clustering(data)
input_values = inputdlg({'Mass Coeff. of Variation Threshold:','Lengh Coeff. of Variation Threshold:','Width Coeff. of Variation Threshold:'},'',1,{'10000000','0.15','0.15'});
if isempty(input_values)~=1
    coefficient_of_variation = [str2double(input_values{1}),Inf,Inf,Inf,Inf,Inf,str2double(input_values{2}),str2double(input_values{3})];
    classes = data.classes;
    
    while true
        disp(['number of clusters to classify = ',num2str(size(classes,1))])
        row_col = find_nearest_neighbors_pairwise(classes);
        
        result = check_variation(classes,row_col,coefficient_of_variation);
        
        idx = row_col(result,:);
        if isempty(idx)~=1
            classes = cluster_pairwise(classes,idx);
        else
            break
        end        
    end
    data_to_plot.classes = classes;
    data_to_plot.type = 'shape_class';
    data_to_plot.name = data.name;
    shape_classification_plot(data_to_plot);    
end
end

function row_col = find_nearest_neighbors_pairwise(classes)
disp('finding neighbors -- pairwise')
parameters = classes(:,3);
parameters = vertcat(parameters{:});
parameters = zscore(parameters);
m = size(parameters,1);
for i = 1:floor(m/2)
    [idx,d] = knnsearch(parameters,parameters,'K',2);
    [~,I] = min(d(:,2));
    row_col(i,:) = idx(I,:);
    parameters(row_col(i,:),:) = Inf;
end
end

function result = check_variation(classes,row_col,coeff_of_var)
for i = 1:size(row_col,1)
    to_check = [classes(row_col(i,1),2);classes(row_col(i,2),2)];
    to_check = vertcat(to_check{:});
    variation = std(to_check,0,1)./mean(to_check,1);
    if any(variation>coeff_of_var)
        result(i,1) = false;
    else
        result(i,1) = true;
    end
    clear to_check variation
end
end

function classes_new = cluster_pairwise(classes,idx)
for i = 1:size(idx,1)
    classes_to_pair{i} = [classes(idx(i,1),:);classes(idx(i,2),:)];
end
idx_not_to_pair = sort(reshape(idx,[size(idx,1)*2,1]));
idx_not_to_pair = setdiff((1:size(classes,1))',idx_not_to_pair);
classes_not_to_pair = classes(idx_not_to_pair,:);
paired_classes = cellfun(@(x) pair_classes(x),classes_to_pair,'UniformOutput',false);
paired_classes = vertcat(paired_classes{:});
if isempty(classes_not_to_pair)
    classes_new = paired_classes;
else
    classes_new = [paired_classes;classes_not_to_pair];
end
end

function classes_new = pair_classes(classes)
shapes = classes(:,1);
para = classes(:,2);
colors = classes(:,4);
shapes = vertcat(shapes{:});
para = vertcat(para{:});
colors = vertcat(colors{:});
classes_new{1,1} = shapes;
classes_new{1,2} = para;
classes_new{1,3} = mean(para,1);
classes_new{1,4} = colors;
end