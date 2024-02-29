function spt_tracks_convert_tracks_to_image(data)
input_values = inputdlg({'pixel size:','image width:','image height:'},'',1,{'0.117','419','680'});
if isempty(input_values)==1
    return
else
    pixel_size = str2double(input_values{1});
    width = str2double(input_values{2});
    heigts = str2double(input_values{3});
    f = waitbar(0,'Converting Tracks to Image');
    for i = 1:length(data)        
        tracks = data{i}.tracks;
        image = zeros(heigts,width);
        [tracks_image,~] = spt_convert_tracks_to_image(tracks,image,pixel_size);
        data_to_send{i}.image{1} = tracks_image;
        data_to_send{i}.name = [data{i}.name,'_image'];
        data_to_send{i}.type = 'image';
        data_to_send{i}.info = 'NaN';
        clear tracks image tracks_image
        waitbar(i/length(data),f,'Converting Tracks to Image');
    end
    close(f)
    image_plot(data_to_send)    
end
end