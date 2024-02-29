function image_motion_filter(data)
InputValues = inputdlg({'length:','theta:'},'',1,{'2','10'});
if isempty(InputValues)==1
    return
else
    len = str2double(InputValues{1});  
    theta = str2double(InputValues{2}); 
    h = fspecial('motion',len,theta);
    for k=1:length(data)
        data{k}.image = imfilter(data{k}.image,h);
    end
    image_plot(data)
end
end