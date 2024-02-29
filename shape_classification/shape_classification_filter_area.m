function shape_classification_filter_area(data)
classes = data.classes;
input_values = inputdlg({'Area Filter Value:'},'',1,{'10'});
if isempty(input_values)~=1
    min_area = str2double(input_values{1});
    for i=1:size(classes,1)
        for j = 1:length(classes{i})
            area(j,1) = classes{i,2}(j,2);
        end
        I = area>=min_area;
        classes_above{i,1} = classes{i,1}(I);
        classes_above{i,2} = classes{i,2}(I,:);
        classes_above{i,3} = mean(classes{i,2},1);
        classes_above{i,4} = classes{i,4}(I);
        
        classes_below{i,1} = classes{i,1}(~I);
        classes_below{i,2} = classes{i,2}(~I,:);
        classes_below{i,3} = mean(classes{i,2},1);
        classes_below{i,4} = classes{i,4}(~I);
        clear area I
    end
    classes_above = classes_above(~cellfun(@isempty,classes_above(:,1)),:);
    classes_below = classes_below(~cellfun(@isempty,classes_below(:,1)),:);
    if isempty(classes_above)~=1
        data_above.classes = classes_above;
        data_above.name = [data.name,'_above_filter'];
        data_above.type = 'shape_class';
        shape_classification_plot(data_above)
    end
    if isempty(classes_below)~=1
        data_below.classes = classes_below;
        data_below.name = [data.name,'_above_filter'];
        data_below.type = 'shape_class';
        shape_classification_plot(data_below)
    end
end
end