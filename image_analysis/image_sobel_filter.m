function image_sobel_filter(data)
h = fspecial('sobel');
for k=1:length(data)
    data{k}.image = imfilter(data{k}.image,h);
end
image_plot(data)
end