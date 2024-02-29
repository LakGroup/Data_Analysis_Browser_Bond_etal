function loc_list_add_scale_bar(data)
subplot = @(m,n,p) subtightplot (m, n, p, [0 0], [0 0], [0 0]);  
answer = inputdlg({'Pixel Size (nm per pixel):','Scale Bar Size (x-axis um):','Scale Bar Size (y axis um):'},'Input',[1 50],{'117','2','0.5'});
if isempty(answer)~=1
    pixel_size = str2double(answer{1});
    scale_bar_size_x = str2double(answer{2});
    scale_bar_size_y = str2double(answer{3});
    for k = 1:length(data)
        subplot(1,length(data),k)
        x = data{k}.x_data;
        y = data{k}.y_data;
        pixels_um_x = scale_bar_size_x/(pixel_size/1000);
        pixels_um_y = scale_bar_size_y/(pixel_size/1000);
        rectangle('Position',[min(x) max(y) pixels_um_x pixels_um_y],'facecolor','w')
        clear x y
    end
end
end