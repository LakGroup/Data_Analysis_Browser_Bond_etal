function image_prewitt_filter(data)
h = fspecial('prewitt');
for k=1:length(data)
    data{k}.image = imfilter(data{k}.image,h);
end
image_plot(data)
end