function image_flip_lr(data)
for k=1:length(data)
    for j = 1:length(data{k}.image)
        data{k}.image{j} = fliplr(data{k}.image{j});
    end
end
image_plot(data)
end