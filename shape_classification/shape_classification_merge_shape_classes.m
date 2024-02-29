function shape_classification_merge_shape_classes(data)
for i = 1:length(data)
    classes{i} = open_classes(data{i}.classes);
end
classes = vertcat(classes{:});
data_to_plot.classes = classes;
data_to_plot.name = 'merged_classes';
data_to_plot.type = 'shape_class';
shape_classification_plot(data_to_plot);
end

function classes_new = open_classes(classes)
shapes = classes(:,1);
shapes = vertcat(shapes{:});

parameters = classes(:,2);
parameters = vertcat(parameters{:});

class_num = classes(:,4);
class_num = vertcat(class_num{:});

for i = 1:length(class_num)
    classes_new{i,1}{1} = shapes{i};
    classes_new{i,2} = parameters(i,:);
    classes_new{i,3} = parameters(i,:);
    classes_new{i,4}{1} = class_num{i};
end
end