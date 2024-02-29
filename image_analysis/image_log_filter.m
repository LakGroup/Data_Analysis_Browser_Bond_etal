function image_log_filter(data)
InputValues = inputdlg({'filter size:','sigma value:'},'',1,{'2','1'});
if isempty(InputValues)==1
    return
else
    hsize = str2double(InputValues{1}); 
    sigma = str2double(InputValues{2}); 
    h = fspecial('log',hsize,sigma);
    for k=1:length(data)
        data{k}.image = imfilter(data{k}.image,h);
    end
    image_plot(data)
end
end