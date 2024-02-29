function image_crop_enter_values(data)
for i=1:length(data)
    max_x(i) = max(size(data{i}.image,2));
    max_y(i) = max(size(data{i}.image,1));    
end
input_values = inputdlg({'X1:','X2:','Y1:','Y2:'},'',1, {num2str(1),num2str(max(max_x)),num2str(1),num2str(max(max_y))});
if isempty(input_values)==1
    return
else
    x1=str2double(input_values{1});
    x2=str2double(input_values{2});
    y1=str2double(input_values{3});
    y2=str2double(input_values{4});    
    for k=1:length(data)
        x_data = 1:size(data{k}.image{1},2);
        y_data = 1:size(data{k}.image{1},1);        
        [~,XI1]=min(abs(x_data-x1));
        [~,XI2]=min(abs(x_data-x2));
        [~,YI1]=min(abs(y_data-y1));
        [~,YI2]=min(abs(y_data-y2));
        I1=min(XI1,XI2);
        I2=max(XI1,XI2);
        I3=min(YI1,YI2);
        I4=max(YI1,YI2);
        if I1==I2 || I3==I4
            return
        else
            for j = 1:length(data{k}.image)
                data{k}.image{j} = data{k}.image{j}(I3:I4,I1:I2);
            end
        end
        clear I1 I2 I3 I4 x_data y_data image
    end
end
    image_plot(data)
end