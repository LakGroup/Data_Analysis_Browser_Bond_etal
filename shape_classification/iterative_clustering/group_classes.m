function classes_new = group_classes(idx,classes)
idx_classes = classes(idx,:);

temp = idx_classes(:,1);
classes_new{1,1} = vertcat(temp{:});

temp = idx_classes(:,2);
classes_new{1,2} = vertcat(temp{:});

classes_new{1,3} = mean(classes_new{1,2},1);

temp = idx_classes(:,4);
classes_new{1,4} = vertcat(temp{:});    
end