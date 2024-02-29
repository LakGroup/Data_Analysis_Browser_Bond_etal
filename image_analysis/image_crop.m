function image_crop(data)
rec_coordinates=getrect;
if isempty(rec_coordinates)
    return
else
    x1 = round(rec_coordinates(1));
    x2 = round(x1+rec_coordinates(3));
    y1 = round(rec_coordinates(2));
    y2 = round(y1+rec_coordinates(4));
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
    image_plot(data)
end
end