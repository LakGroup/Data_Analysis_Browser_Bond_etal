function data = shape_classification_set_class_color(data)
input_values = inputdlg({'Class Number:'},'',1,{'1'});
if isempty(input_values)~=1
    class_number = str2double(input_values{1});
    for i = 1:length(data)
        data{i}.classes = open_classes(data{i}.classes,class_number);
    end    
end
end

function classes_new = open_classes(classes,class_number)
shapes = classes(:,1);
shapes = vertcat(shapes{:});

parameters = classes(:,2);
parameters = vertcat(parameters{:});

class_num = classes(:,4);
class_num = vertcat(class_num{:});

for i = 1:length(class_num)
    class_num_num{i,1}{1} = class_number;
end

for i = 1:length(class_num)
    classes_new{i,1}{1} = shapes{i};
    classes_new{i,2} = parameters(i,:);
    classes_new{i,3} = parameters(i,:);
end
classes_new(:,4) = class_num_num;
end