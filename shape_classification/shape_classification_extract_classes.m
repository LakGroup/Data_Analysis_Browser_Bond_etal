function shape_classification_extract_classes(data)
number_of_classes = size(data.classes,1);
if number_of_classes == 1
    input_values = inputdlg({'Classes to Exctract:'},'',1,{'1'});
else
    input_values = inputdlg({'Classes to Exctract:'},'',1,{['1:',num2str(number_of_classes)]});
end

if isempty(input_values)~=1
    classes_to_extract = eval(input_values{1});
    for i = 1:length(classes_to_extract)
        data_to_send{1,i}.name = [data.name,'_class_',num2str(classes_to_extract(i))];
        data_to_send{1,i}.type = 'shape_class';
        classes = data.classes(classes_to_extract(i),:);
        for k = 1:length(classes{1})
            data_classes{k,1} = {classes{1,1}{k}};
            data_classes{k,2} = classes{1,2}(k,:);
            data_classes{k,3} = classes{1,2}(k,:);
            data_classes{k,4} = {classes{1,4}{k}};
        end
        data_to_send{1,i}.classes = data_classes;
        clear classes data_classes
    end
    send_data_to_workspace(data_to_send)
end
end