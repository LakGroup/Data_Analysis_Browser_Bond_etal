function classes_new = cluster_classes(idx,classes)
for i=1:length(unique(idx))
    classes_new{i,1} = classes(idx==i,1);
    classes_new{i,1} = vertcat(classes_new{i,1}{:});
    
    classes_new{i,2} = classes(idx==i,2);
    classes_new{i,2} = vertcat(classes_new{i,2}{:});    
    if size(classes_new{i,2},1)>1
        classes_new{i,3} = mean(classes_new{i,2});        
    else
        classes_new{i,3} = classes_new{i,2};
    end
    
    classes_new{i,4} = classes(idx==i,4);
    classes_new{i,4} = vertcat(classes_new{i,4}{:});
end
end