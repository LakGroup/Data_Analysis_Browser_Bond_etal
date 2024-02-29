function shape_classification_filter_aspect_ratio(data)
classes = data.classes;
input_values = inputdlg({'Major Axis to Minor Axis Aspect Ratio Threshold:'},'',1,{'1.5'});
if isempty(input_values)~=1
    min_aspect_ratio = str2double(input_values{1});    
    for i=1:size(classes,1)
        for j = 1:length(classes{i})
            major_axis_length = classes{i,2}(j,7);
            minor_axis_length = classes{i,2}(j,8);
            max_val = max(major_axis_length,minor_axis_length);
            min_val = min(major_axis_length,minor_axis_length);
            aspect_ratio(j,1) = max_val/min_val;            
        end
        I = aspect_ratio>=min_aspect_ratio;
        
        classes{i,1} = classes{i,1}(I);
        classes{i,2} = classes{i,2}(I,:);
        classes{i,3} = mean(classes{i,2},1);
        classes{i,4} = classes{i,4}(I);
        clear aspect_ratio I
    end   
    classes = classes(~cellfun(@isempty,classes(:,1)),:);
    if isempty(classes)~=1
        data.classes = classes;
        shape_classification_plot(data)
    end
end
end